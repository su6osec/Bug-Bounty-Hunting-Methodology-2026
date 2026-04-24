<div align="center">

```
██╗  ██╗██╗   ██╗███╗   ██╗████████╗██████╗  ██████╗  ██████╗ ██╗  ██╗
██║  ██║██║   ██║████╗  ██║╚══██╔══╝██╔══██╗██╔═══██╗██╔═══██╗██║ ██╔╝
███████║██║   ██║██╔██╗ ██║   ██║   ██████╔╝██║   ██║██║   ██║█████╔╝
██╔══██║██║   ██║██║╚██╗██║   ██║   ██╔══██╗██║   ██║██║   ██║██╔═██╗
██║  ██║╚██████╔╝██║ ╚████║   ██║   ██████╔╝╚██████╔╝╚██████╔╝██║  ██╗
╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚═════╝  ╚═════╝  ╚═════╝ ╚═╝  ╚═╝
```

# HuntBook — Bug Bounty Hunting Methodology 2026

**A combat-tested, community-synthesized operational playbook for finding real vulnerabilities on real targets.**

[![Maintained](https://img.shields.io/badge/Maintained-2026-brightgreen?style=for-the-badge)](https://github.com/su6osec/Bug-Bounty-Hunting-Methodology-2026)
[![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)](LICENSE)
[![Stars](https://img.shields.io/github/stars/su6osec/Bug-Bounty-Hunting-Methodology-2026?style=for-the-badge&color=yellow)](https://github.com/su6osec/Bug-Bounty-Hunting-Methodology-2026/stargazers)
[![PRs Welcome](https://img.shields.io/badge/PRs-Welcome-orange?style=for-the-badge)](CONTRIBUTING.md)
[![Author](https://img.shields.io/badge/Author-su6osec-red?style=for-the-badge)](https://github.com/su6osec)

</div>

---

## What Is This?

**HuntBook** is a synthesized, battle-ready bug bounty hunting methodology compiled from the best public methodologies — jhaddix, R-s0n, amrelsagaei, blackhatethicalhacking, byoniq, and more — updated with modern tooling and structured for real-world use across web, mobile, cloud, and Web3 targets.

> **Recon is 90% of the work. Attacks are the remaining 10%.** — BHEH Framework

This is not a beginner tutorial. This is an **operational playbook**.

---

## Methodology Flow

**Phase 0 — Scope & Program Analysis**
Read scope rules, classify target (wide / medium / narrow), plan attack surface before touching any tool.

**Phase 1 — Passive Reconnaissance**
OSINT, ASN enumeration, acquisitions, GitHub code search, certificate logs — zero interaction with target.

**Phase 2 — Active Enumeration**
Subdomains → resolve to IPs → port scan → live HTTP apps → JS analysis → screenshots.

**Phase 3 — Vulnerability Discovery** *(Ebb & Flow)*
Identify 3–5 attack vectors → test briefly → return to recon to expand surface → repeat until done.

**Phase 4 — Exploitation & PoC**
Reproduce reliably, escalate severity, chain bugs for maximum impact, document everything.

**Phase 5 — Reporting**
CVSS scoring, structured evidence, remediation recommendations, business impact articulation.

---

## Table of Contents

- [Phases](#phases)
- [Vulnerability Guides](#vulnerability-guides)
- [Mobile Testing](#mobile-testing)
- [Cloud Security](#cloud-security)
- [Target-Specific Guides](#target-specific-guides)
- [Recon Deep Dives](#recon-deep-dives)
- [Checklists](#checklists)
- [Tools Arsenal](#tools-arsenal)
- [Quick Wins](#quick-wins)
- [Automation & One-Liners](#automation--one-liners)
- [Setup](#setup)
- [Resources](#resources)
- [Contributing](#contributing)

---

## Phases

- **[Phase 0 — Scope & Program Analysis](phases/01_scope_and_program_analysis.md)** — Understand rules, classify scope, identify high-value targets before any tool runs
- **[Phase 1 — Passive Reconnaissance](phases/02_passive_reconnaissance.md)** — OSINT, ASN, acquisitions, cert logs, GitHub leaks, Shodan, Wayback
- **[Phase 2 — Active Enumeration](phases/03_active_enumeration.md)** — Subdomains, ports, live apps, JS analysis, parameter discovery, cloud assets
- **[Phase 3 — Vulnerability Discovery](phases/04_vulnerability_discovery.md)** — Ebb & Flow model, injection points, logic flaws, API abuse, full testing coverage
- **[Phase 4 — Exploitation & PoC](phases/05_exploitation_and_poc.md)** — Bug chaining, severity escalation paths, PoC creation standards
- **[Phase 5 — Reporting](phases/06_reporting.md)** — Report template, CVSS scoring, CWE reference, title guide, communication tips

---

## Vulnerability Guides

- **[Cross-Site Scripting (XSS)](vulnerabilities/xss.md)** — Reflected, Stored, DOM, Blind; ATO escalation; filter bypass payloads
- **[SQL Injection](vulnerabilities/sqli.md)** — Error, Union, Boolean, Time-based, OOB; SQLMap, Ghauri; WAF bypass
- **[IDOR](vulnerabilities/idor.md)** — Numeric, UUID, encoded references; horizontal + vertical escalation; HTTP method abuse
- **[SSRF](vulnerabilities/ssrf.md)** — Cloud metadata theft, blind OOB detection, Gopherus chains, filter bypasses
- **[CSRF](vulnerabilities/csrf.md)** — Token bypass, SameSite abuse, CSRF+XSS chain; PoC HTML template
- **[LFI / RFI](vulnerabilities/lfi_rfi.md)** — Path traversal, PHP wrappers, log poisoning → RCE
- **[RCE](vulnerabilities/rce.md)** — Command injection, deserialization (Java/PHP/Python), SSTI, webshells, reverse shells
- **[XXE](vulnerabilities/xxe.md)** — File read, SSRF, OOB exfil via DTD, SVG/DOCX upload vectors
- **[SSTI](vulnerabilities/ssti.md)** — Jinja2, Twig, Freemarker, ERB, Velocity; engine-specific RCE payloads; tplmap
- **[Open Redirect](vulnerabilities/open_redirect.md)** — Bypass techniques, OAuth token theft chain
- **[Subdomain Takeover](vulnerabilities/subdomain_takeover.md)** — Fingerprints for 12+ services, Nuclei detection, responsible PoC claiming
- **[File Upload](vulnerabilities/file_upload.md)** — Extension bypass, magic bytes, Content-Type, .htaccess, ImageMagick
- **[HTTP Request Smuggling](vulnerabilities/http_smuggling.md)** — CL.TE, TE.CL, TE.TE; access control bypass; automated detection
- **[Business Logic](vulnerabilities/business_logic.md)** — Race conditions, price manipulation, workflow bypass, trust boundary violations
- **[Authentication Flaws](vulnerabilities/authentication.md)** — Enumeration, brute force, JWT attacks, OAuth flows, 2FA bypass techniques
- **[API Security](vulnerabilities/api_security.md)** — OWASP API Top 10, GraphQL introspection abuse, REST checklist
- **[OAuth 2.0 / OIDC](vulnerabilities/oauth.md)** — redirect_uri bypass, CSRF, code interception, account linking ATO, token theft chains
- **[CORS Misconfiguration](vulnerabilities/cors.md)** — Origin reflection, null origin, subdomain chain, exploitation PoC
- **[Prototype Pollution](vulnerabilities/prototype_pollution.md)** — Client-side XSS gadgets, server-side Node.js RCE, automated detection
- **[Web3 / Smart Contracts](vulnerabilities/web3.md)** — Reentrancy, access control, oracle manipulation, flash loans, Slither, Echidna

---

## Mobile Testing

- **[Android](mobile/android.md)** — APK decompilation, secret hunting, certificate pinning bypass, Frida/Objection, deep links, WebView
- **[iOS](mobile/ios.md)** — IPA analysis, class-dump, Keychain dumping, SSL Kill Switch, runtime hooking, Frida

---

## Cloud Security

- **[AWS](cloud/aws.md)** — S3 bucket enumeration, IMDSv1 SSRF credential theft, IAM abuse, Secrets Manager, stolen credential usage
- **[GCP](cloud/gcp.md)** — GCS bucket testing, metadata token theft, service account key files, privilege escalation paths
- **[Azure](cloud/azure.md)** — Blob storage, IMDS credential theft, SAS token abuse, Azure AD enumeration, Key Vault access

---

## Target-Specific Guides

- **[Fintech & Banking](targets/fintech.md)** — Payment manipulation, KYC bypass, webhook signature abuse, Open Banking API, HIPAA/PCI severity escalation
- **[SaaS Platforms](targets/saas.md)** — Multi-tenancy isolation, role escalation, API key abuse, subdomain CORS chain, feature flag bypass
- **[Healthcare & MedTech](targets/healthcare.md)** — PHI exposure, FHIR API abuse, HIPAA compliance severity escalation, medical device APIs
- **[E-Commerce](targets/ecommerce.md)** — Price manipulation, coupon race conditions, order IDOR, payment webhook bypass, gift card abuse

---

## Recon Deep Dives

- **[GitHub Recon](recon/github_recon.md)** — Org enumeration, secret scanning dorks, git history mining, CI/CD config analysis, developer personal accounts, automated tools

---

## Checklists

- **[Master Bug Bounty Checklist](checklists/master_checklist.md)** — Full end-to-end checklist covering all phases
- **[Recon Checklist](checklists/recon_checklist.md)** — Every recon command and output file to maintain
- **[Web Application Checklist](checklists/webapp_checklist.md)** — Based on jhaddix tbhm + OWASP Testing Guide
- **[API Testing Checklist](checklists/api_checklist.md)** — OWASP API Security Top 10 mapped to test cases

---

## Tools Arsenal

- **[Complete Tools Reference](tools/README.md)** — 50+ tools organized by phase with install commands and purpose

---

## Quick Wins

- **[15 High-ROI Techniques](tips/quick_wins.md)** — Techniques that take under 15 minutes each and have a disproportionately high hit rate on every target

---

## Automation & One-Liners

- **[Recon Automation Scripts](automation/recon_automation.md)** — Full bash recon script, GF pipelines, XSS and SQLi automation
- **[Power One-Liners](automation/oneliners.md)** — 30+ copy-paste ready one-liners for every phase

---

## Setup

- **[One-Shot Installer](setup/install.sh)** — Installs all tools on Kali Linux or Ubuntu 22.04+

```bash
chmod +x setup/install.sh && sudo ./setup/install.sh
```

---

## Resources

- **[Payloads Collection](resources/payloads.md)** — XSS, SQLi, SSRF, LFI, Command Injection, SSTI, XXE, Open Redirect
- **[Wordlists Reference](resources/wordlists.md)** — SecLists, Assetnote, DNS resolvers, custom generation
- **[Learning Resources](resources/learning_resources.md)** — Labs, books, YouTube channels, key talks, write-ups
- **[Bug Bounty Platforms](resources/platforms.md)** — HackerOne, Bugcrowd, Intigriti, Immunefi and more

---

## Philosophy

```
"The real challenge lies in identifying high-impact vulnerabilities
 through your own skills and creativity."
                                        — Amr Elsagaei

"Find 3–5 attack vectors, test briefly, return to recon,
 expand the surface. Repeat. This is the Ebb & Flow."
                                        — R-s0n (DEF CON 32)

"The goal isn't to find every bug. It's to find the right bug."
                                        — Jason Haddix
```

---

## Contributing

Pull requests are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

If you have a technique that worked in 2025/2026, a better one-liner, or a bug fix — open a PR.

---

## Acknowledgements

This methodology stands on the shoulders of giants:

- **Jason Haddix** — [The Bug Hunter's Methodology](https://github.com/jhaddix/tbhm)
- **R-s0n** — [DEF CON 32 Bug Bounty Village Workshop](https://github.com/R-s0n/bug-bounty-village-defcon32-workshop)
- **Amr Elsagaei** — [Bug-Bounty-Hunting-Methodology-2025](https://github.com/amrelsagaei/Bug-Bounty-Hunting-Methodology-2025)
- **BlackHat Ethical Hacking** — [Bug_Bounty_Tools_and_Methodology](https://github.com/blackhatethicalhacking/Bug_Bounty_Tools_and_Methodology)
- **byoniq** — [BugBountyMethod](https://github.com/byoniq/BugBountyMethod)
- **sehno** — [Bug-bounty checklist](https://github.com/sehno/Bug-bounty)
- **n4itr0-07** — [SecToolkit](https://github.com/n4itr0-07/SecToolkit)

---

<div align="center">

**Made with** ❤️ **by** [su6osec](https://github.com/su6osec) | **2026**

*If this helped you find a bug — drop a ⭐*

</div>
