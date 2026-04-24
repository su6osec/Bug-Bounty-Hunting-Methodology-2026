# Web3 & Smart Contract Security

> Immunefi and similar platforms pay millions for smart contract bugs. A single reentrancy vulnerability can drain an entire protocol.

---

## Environment Setup

**[Foundry](https://getfoundry.sh)** — Solidity development and testing framework
`curl -L https://foundry.paradigm.xyz | bash && foundryup`

**[Slither](https://github.com/crytic/slither)** — Static analysis for Solidity
`pip3 install slither-analyzer`

**[Mythril](https://github.com/ConsenSys/mythril)** — Symbolic execution security scanner
`pip3 install mythril`

**[Echidna](https://github.com/crytic/echidna)** — Fuzzer for EVM smart contracts
Install via GitHub releases

**[Hardhat](https://hardhat.org)** — Ethereum dev environment
`npm install --save-dev hardhat`

**[Tenderly](https://tenderly.co)** — Transaction simulation and debugging

**[Etherscan](https://etherscan.io)** — Contract verification and analysis

---

## Phase 1 — Reconnaissance

### Finding the Contracts

```bash
# Check project documentation for contract addresses
# Check GitHub for deployed contract addresses
grep -r "0x[0-9a-fA-F]{40}" . -rn

# Get verified source from Etherscan
# https://etherscan.io/address/CONTRACT_ADDRESS#code

# Clone verified source
git clone https://github.com/protocol/contracts

# Check proxy pattern (most protocols use upgradeable proxies)
# EIP-1967 proxy: read implementation slot
cast storage CONTRACT_ADDRESS 0x360894a13ba1a3210667c828492db98dca3e2076
```

### Understanding the Protocol

```bash
# Read the docs and whitepaper first
# Understand:
# - What does the protocol do?
# - Where does money flow?
# - What are the trust assumptions?
# - What roles/permissions exist?
# - What are the invariants? (e.g., "total supply always equals sum of balances")

# Map all external function calls
slither . --print call-graph

# Find admin functions
slither . --print human-summary
grep -r "onlyOwner\|onlyAdmin\|require(msg.sender ==" contracts/ -n
```

---

## Phase 2 — Static Analysis

```bash
# Run Slither
slither . --detect all 2>&1 | tee slither_results.txt

# Key detectors to focus on:
# reentrancy-eth, reentrancy-no-eth
# uninitialized-storage
# arbitrary-send-eth
# controlled-delegatecall
# suicidal
# tx-origin
# unchecked-transfer
# tautology

# Run Mythril on a single contract
myth analyze contracts/Target.sol --solc-json config.json

# Run on deployed bytecode
myth analyze -a CONTRACT_ADDRESS --rpc https://mainnet.infura.io/v3/KEY
```

---

## Phase 3 — Manual Audit

### Reentrancy

```solidity
// VULNERABLE PATTERN
function withdraw(uint amount) external {
    require(balances[msg.sender] >= amount);
    (bool success,) = msg.sender.call{value: amount}("");  // external call BEFORE state update
    require(success);
    balances[msg.sender] -= amount;   // state update AFTER — too late
}

// ATTACK: Malicious contract calls back into withdraw() before balances[msg.sender] is updated
// Result: drain entire contract balance

// Check for:
// 1. ETH/token transfer before state update (CEI violation)
// 2. Missing reentrancy guard
// 3. Cross-function reentrancy (withdraw → deposit combination)
// 4. Cross-contract reentrancy (two contracts calling each other)
```

### Access Control

```solidity
// Check every privileged function
// - Is onlyOwner correct or should it be onlyRole(ADMIN_ROLE)?
// - Can ownership be renounced? (protocol becomes unusable)
// - Two-step ownership transfer? (typo = permanent loss)
// - Is the owner a multisig or a single EOA? (single = centralization risk)

// Missing access control example
function setFee(uint newFee) external {   // anyone can call this
    fee = newFee;
}

// Initialization vulnerability
function initialize(address owner) external {   // no initializer modifier
    admin = owner;
}
// Can be front-run: attacker calls initialize before the real deployer
```

### Integer Overflow/Underflow (pre-Solidity 0.8)

```solidity
// Before 0.8.0 without SafeMath:
uint256 balance = 0;
balance -= 1;   // wraps to 2^256 - 1

// Check for:
// Solidity version (if < 0.8, look for SafeMath usage)
// unchecked{} blocks in 0.8+ code
// Type casting: uint256 → uint128 truncation
```

### Flash Loan Attacks

```bash
# Flash loans allow borrowing unlimited funds in a single transaction
# This breaks many assumptions like "user must have collateral"

# Check for:
# - Price oracle manipulation via flash loan
# - Governance attacks (borrow tokens, vote, return)
# - Collateral ratio manipulation
# - AMM price manipulation

# Susceptible pattern:
# Protocol reads price from a DEX spot price → manipulable via flash loan

# Safe pattern: TWAP (Time Weighted Average Price) or Chainlink oracle
```

### Price Oracle Manipulation

```solidity
// VULNERABLE: spot price from Uniswap pool
function getPrice() external view returns (uint) {
    (uint112 reserve0, uint112 reserve1,) = pair.getReserves();
    return reserve1 / reserve0;   // can be manipulated in same transaction
}

// SAFE: Chainlink price feed or TWAP
function getPrice() external view returns (uint) {
    (, int price,,,) = priceFeed.latestRoundData();
    return uint(price);
}
```

### Signature Replay

```solidity
// VULNERABLE: no chain ID, no nonce, no expiry
function execute(bytes memory signature) external {
    address signer = recoverSigner(hash, signature);
    require(signer == owner);
    // execute action
}

// Attack: replay same signature on different chain, or replay multiple times

// Check for:
// - Missing nonce in signed data
// - Missing chain ID (cross-chain replay)
// - Missing expiry/deadline
// - Missing contract address in signed data (cross-contract replay)
```

### Dangerous Delegatecall

```solidity
// delegatecall executes in the CALLER's storage context
// If destination is attacker-controlled → storage manipulation → full takeover

function execute(address target, bytes calldata data) external {
    target.delegatecall(data);   // if target is attacker-controlled → game over
}
```

---

## Phase 4 — Fuzzing

```bash
# Echidna fuzzing
# Write invariants as Solidity functions that should never return false

// Invariant: total supply never decreases
function echidna_total_supply() public returns (bool) {
    return token.totalSupply() >= initialSupply;
}

# Run Echidna
echidna-test contracts/Token.sol --contract Token --config echidna.yaml

# Foundry fuzzing
function testFuzz_withdraw(uint256 amount) public {
    vm.assume(amount > 0 && amount <= 1 ether);
    vault.deposit{value: amount}();
    vault.withdraw(amount);
    assertEq(address(vault).balance, 0);
}

forge test --fuzz-runs 10000
```

---

## Common Vulnerability Checklist

- [ ] Reentrancy — ETH/token transfer before state update
- [ ] Access control — missing or wrong role on privileged functions
- [ ] Initialization — can initialize be called by anyone?
- [ ] Flash loan — price/balance assumptions exploitable in one tx
- [ ] Oracle manipulation — spot price used for decisions
- [ ] Signature replay — missing nonce, chainId, expiry
- [ ] Integer overflow — unchecked arithmetic in 0.8+ or pre-0.8 without SafeMath
- [ ] Dangerous delegatecall — user-controlled destination
- [ ] Front-running — transaction ordering attacks on DEX/auction
- [ ] Griefing — attacker can permanently break protocol for others
- [ ] Centralization risk — owner can rug / drain funds
- [ ] Logic errors — economic invariants that can be violated

---

## Reporting Web3 Bugs

**Protocol drain / theft of funds** → Critical (Immunefi: $1M–$10M+)

**Temporary freeze of funds** → High

**Governance manipulation** → High/Critical

**NFT/token price manipulation** → High

**Gas griefing / DoS** → Low–Medium

**Centralization risk (single admin key)** → Informational–Medium
