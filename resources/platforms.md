# Bug Bounty Platforms

---

## Major Platforms

**[HackerOne](https://hackerone.com)** — Largest platform. Strong enterprise programs. Best public hacktivity feed for learning.

**[Bugcrowd](https://bugcrowd.com)** — Strong US/AU presence. Good for IoT, mobile, and web programs.

**[Intigriti](https://intigriti.com)** — EU-focused, fast response times, strong European programs.

**[Synack](https://synack.com)** — Invite-only. Higher payouts, vetted researchers, controlled environment.

**[YesWeHack](https://yeswehack.com)** — European platform, growing fast, solid program variety.

**[Immunefi](https://immunefi.com)** — Web3/crypto focus. Highest payouts in the industry (millions for critical DeFi bugs).

**[HackenProof](https://hackenproof.com)** — Blockchain and web application programs.

**[Cobalt](https://cobalt.io)** — Pentest-as-a-service hybrid model, invite-only researcher community.

---

## Self-Hosted Programs

Many companies run their own programs. Check these paths on any target:

```bash
https://company.com/.well-known/security.txt
https://company.com/security
https://company.com/bug-bounty
https://company.com/responsible-disclosure
```

---

## Choosing the Right Program

**High reward potential:**
- Finance / banking applications
- Healthcare platforms with PHI
- Cloud infrastructure providers
- Crypto and Web3 protocols
- Programs with wide wildcard scope

**Good for building experience:**
- Wide scope (`*.company.com`) — more surface, more opportunities
- Programs with fast average response times
- Programs with clear, well-documented scope

**Worth avoiding early on:**
- VDP (no bounty) until you're comfortable with the process
- Very narrow scopes (single login page only)
- Programs with 90+ day average response time

---

## Tracking Submissions

```
Date       | Program       | Bug Type  | Severity | Status   | Payout
-----------|---------------|-----------|----------|----------|--------
2026-01-01 | HackerOne/X   | XSS       | High     | Resolved | $500
2026-01-15 | Bugcrowd/Y    | IDOR      | Medium   | Triaged  | TBD
2026-02-01 | Intigriti/Z   | SSRF      | Critical | Open     | -
```
