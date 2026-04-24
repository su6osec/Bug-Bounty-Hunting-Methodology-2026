# Changelog

All notable additions and updates to this methodology are documented here.

---

## [2.0.0] — 2026-04-22

### Added

**Mobile Testing**
- `mobile/android.md` — Full Android testing guide: APK decompilation, Frida/Objection, certificate pinning bypass, deep link testing, WebView analysis
- `mobile/ios.md` — Full iOS testing guide: IPA analysis, class-dump, Keychain analysis, SSL kill switch, runtime hooking

**Cloud Security**
- `cloud/aws.md` — AWS attack guide: S3 enumeration, IMDSv1 SSRF credential theft, IAM abuse, Secrets Manager, SSM Parameter Store
- `cloud/gcp.md` — GCP attack guide: GCS bucket testing, metadata token theft, service account key exploitation, privilege escalation
- `cloud/azure.md` — Azure attack guide: Blob storage, IMDS credential theft, SAS token abuse, Azure AD enumeration, Key Vault

**New Vulnerability Guides**
- `vulnerabilities/oauth.md` — OAuth 2.0 / OIDC: redirect_uri bypass, CSRF, code interception, implicit flow, account linking ATO chains
- `vulnerabilities/cors.md` — CORS misconfiguration: origin reflection, null origin, subdomain + CORS chain, exploitation PoC
- `vulnerabilities/prototype_pollution.md` — Client-side and server-side PP: gadget finding, XSS escalation, Node.js RCE
- `vulnerabilities/web3.md` — Smart contract security: reentrancy, access control, oracle manipulation, flash loans, Slither/Echidna

**Target-Specific Guides**
- `targets/fintech.md` — Payment manipulation, KYC bypass, webhook abuse, Open Banking API, race conditions
- `targets/saas.md` — Multi-tenant isolation, role escalation, API key abuse, feature flag bypass
- `targets/healthcare.md` — PHI exposure, FHIR API abuse, HIPAA severity escalation, medical device APIs
- `targets/ecommerce.md` — Price manipulation, coupon abuse, order IDOR, payment webhook bypass

**Recon**
- `recon/github_recon.md` — Complete GitHub recon guide: org enumeration, secret scanning, git history mining, CI/CD config analysis, developer personal accounts

**Tips**
- `tips/quick_wins.md` — 15 high-ROI techniques that take under 15 minutes each

**Setup**
- `setup/install.sh` — One-shot installer for all tools on Kali/Ubuntu

### Changed
- All markdown tables replaced with clean list-based formatting
- ASCII box diagrams replaced with plain-text descriptions
- README.md restructured with all new sections

---

## [1.0.0] — 2026-04-22

### Initial Release

**Core methodology** — 6-phase framework synthesized from jhaddix, R-s0n, amrelsagaei, blackhatethicalhacking, byoniq, sehno, n4itr0-07

**Phases**
- Phase 0: Scope & Program Analysis
- Phase 1: Passive Reconnaissance
- Phase 2: Active Enumeration
- Phase 3: Vulnerability Discovery (Ebb & Flow)
- Phase 4: Exploitation & PoC
- Phase 5: Reporting

**Vulnerability guides** — XSS, SQLi, IDOR, SSRF, CSRF, LFI/RFI, RCE, XXE, SSTI, Open Redirect, Subdomain Takeover, File Upload, HTTP Smuggling, Business Logic, Authentication, API Security

**Checklists** — Master, Recon, WebApp, API

**Tools reference** — 50+ tools with install commands

**Automation** — Full recon script, GF pipelines, 30+ one-liners

**Resources** — Payloads, wordlists, platforms, learning resources
