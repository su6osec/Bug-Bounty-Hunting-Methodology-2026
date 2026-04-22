# Phase 0 — Scope & Program Analysis

> Before touching a single tool, understand what you're allowed to test, what pays well, and where others have NOT looked.

---

## 0.1 Program Selection

**Scope width** — Wide scopes (`*.example.com`) beat narrow ones. More surface = more bugs.

**Payout table** — Check max bounties for RCE, SQLi, Auth bypass before investing time.

**Recent scope additions** — Newly added domains are less tested. Watch changelogs.

**Response time** — Fast triagers keep you motivated. Check Disclosure program stats on HackerOne.

**No-duplicates rate** — Low duplicate rates = uncrowded attack surface.

> Recommended platforms: HackerOne, Bugcrowd, Intigriti, Synack, YesWeHack, Immunefi (Web3)

---

## 0.2 Scope Classification

Classify the scope before touching any tool:

**Wide Scope** — `*.company.com` + IP ranges + mobile apps
- Enumerate all apex domains via ASN, acquisitions, cert logs
- Expect 100s of subdomains — automation is mandatory
- Focus: forgotten infrastructure, dev/staging environments

**Medium Scope** — single domain
- Deep subdomain enumeration on one domain
- Heavy JS analysis and parameter discovery
- Focus: complex business logic, API abuse

**Narrow Scope** — single URL or app
- No subdomain hunting needed
- Deep manual testing on a confined surface
- Focus: authentication flows, access control, logic flaws

---

## 0.3 Rules of Engagement Audit

Read the program policy carefully and note:

- [ ] Which domains/IPs are **explicitly in scope**
- [ ] Which are **explicitly out of scope** (CDN edges, third-party, etc.)
- [ ] **Testing restrictions** (no automated scanning, no DoS, no phishing)
- [ ] **Credential requirements** (self-registered accounts only, no test accounts provided)
- [ ] **Disclosure policy** (coordinated 90-day, immediate, etc.)
- [ ] **Bonus payout conditions** (chain bugs, business impact required)

---

## 0.4 Target Profiling (Before Recon)

Gather this information manually before automation:

```
Company:         ___________________
Main domain:     ___________________
Scope type:      Wide / Medium / Narrow
Tech stack:      ___________________
Industry:        ___________________
Publicly known CVEs: _______________
Key competitors: ___________________
Recent news:     ___________________
GitHub org:      ___________________
LinkedIn:        ___________________
```

---

## 0.5 Mental Model: What Makes a Good Target?

**High-value attack surface:**
- Recently acquired domains
- Mobile/API endpoints not in main app
- Staging / dev / internal portals
- Legacy applications (old tech = old vulns)
- Third-party integrations
- SSO / OAuth flows
- Admin panels on non-standard ports
- Microservices / internal APIs exposed

**Overworked, low-yield surface:**
- Main marketing pages (tested by everyone)
- Login page of flagship product
- Static landing pages

---

## Next Step

→ [Phase 1: Passive Reconnaissance](02_passive_reconnaissance.md)
