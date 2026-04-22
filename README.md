<div align="center">

```
██████╗ ██╗   ██╗ ██████╗     ██████╗  ██████╗ ██╗   ██╗███╗   ██╗████████╗██╗   ██╗
██╔══██╗██║   ██║██╔════╝     ██╔══██╗██╔═══██╗██║   ██║████╗  ██║╚══██╔══╝╚██╗ ██╔╝
██████╔╝██║   ██║██║  ███╗    ██████╔╝██║   ██║██║   ██║██╔██╗ ██║   ██║    ╚████╔╝ 
██╔══██╗██║   ██║██║   ██║    ██╔══██╗██║   ██║██║   ██║██║╚██╗██║   ██║     ╚██╔╝  
██████╔╝╚██████╔╝╚██████╔╝    ██████╔╝╚██████╔╝╚██████╔╝██║ ╚████║   ██║      ██║   
╚═════╝  ╚═════╝  ╚═════╝     ╚═════╝  ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝   ╚═╝      ╚═╝  
```

# Bug Bounty Hunting Methodology 2026

**A combat-tested, community-synthesized methodology for finding real vulnerabilities on real targets.**

[![Maintained](https://img.shields.io/badge/Maintained-2026-brightgreen?style=for-the-badge)](https://github.com/su6osec/Bug-Bounty-Hunting-Methodology-2026)
[![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)](LICENSE)
[![Stars](https://img.shields.io/github/stars/su6osec/Bug-Bounty-Hunting-Methodology-2026?style=for-the-badge&color=yellow)](https://github.com/su6osec/Bug-Bounty-Hunting-Methodology-2026/stargazers)
[![PRs Welcome](https://img.shields.io/badge/PRs-Welcome-orange?style=for-the-badge)](CONTRIBUTING.md)
[![Author](https://img.shields.io/badge/Author-su6osec-red?style=for-the-badge)](https://github.com/su6osec)

</div>

---

## What Is This?

This repository is a **synthesized, battle-ready bug bounty hunting methodology for 2026** — compiled from the best public methodologies (jhaddix, R-s0n, amrelsagaei, blackhatethicalhacking, byoniq, and more), updated with modern tooling, and structured for real-world use.

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
- [Checklists](#checklists)
- [Tools Arsenal](#tools-arsenal)
- [Automation & One-Liners](#automation--one-liners)
- [Resources](#resources)
- [Contributing](#contributing)

---

## Phases

- **[Phase 0 — Scope & Program Analysis](phases/01_scope_and_program_analysis.md)** — Understand rules, classify scope, plan attack
- **[Phase 1 — Passive Reconnaissance](phases/02_passive_reconnaissance.md)** — OSINT, ASN, acquisitions, cert logs, GitHub leaks
- **[Phase 2 — Active Enumeration](phases/03_active_enumeration.md)** — Subdomains, ports, live apps, JS analysis
- **[Phase 3 — Vulnerability Discovery](phases/04_vulnerability_discovery.md)** — Injection points, logic flaws, API abuse
- **[Phase 4 — Exploitation & PoC](phases/05_exploitation_and_poc.md)** — Bug chaining, severity escalation, PoC creation
- **[Phase 5 — Reporting](phases/06_reporting.md)** — Structure, CVSS, evidence, remediation

---

## Vulnerability Guides

- **[Cross-Site Scripting (XSS)](vulnerabilities/xss.md)** — Reflected, Stored, DOM, Blind; escalation to ATO
- **[SQL Injection](vulnerabilities/sqli.md)** — Error, Union, Boolean, Time-based, OOB; SQLMap + Ghauri
- **[IDOR](vulnerabilities/idor.md)** — Numeric, UUID, encoded references; horizontal + vertical escalation
- **[SSRF](vulnerabilities/ssrf.md)** — Cloud metadata theft, blind SSRF, Gopherus chains
- **[CSRF](vulnerabilities/csrf.md)** — Token bypass, SameSite abuse, CSRF+XSS chain
- **[LFI / RFI](vulnerabilities/lfi_rfi.md)** — Path traversal, PHP wrappers, log poisoning → RCE
- **[RCE](vulnerabilities/rce.md)** — Command injection, deserialization, SSTI, webshells
- **[XXE](vulnerabilities/xxe.md)** — File read, SSRF, OOB exfil, SVG/DOCX upload vectors
- **[SSTI](vulnerabilities/ssti.md)** — Jinja2, Twig, Freemarker, ERB; engine-specific RCE payloads
- **[Open Redirect](vulnerabilities/open_redirect.md)** — Bypass techniques, OAuth token theft chain
- **[Subdomain Takeover](vulnerabilities/subdomain_takeover.md)** — Fingerprints for 10+ services, claiming PoC
- **[File Upload](vulnerabilities/file_upload.md)** — Extension bypass, magic bytes, .htaccess, ImageMagick
- **[HTTP Request Smuggling](vulnerabilities/http_smuggling.md)** — CL.TE, TE.CL, TE.TE; access control bypass
- **[Business Logic](vulnerabilities/business_logic.md)** — Race conditions, price manipulation, workflow bypass
- **[Authentication Flaws](vulnerabilities/authentication.md)** — Enum, brute force, JWT attacks, OAuth, 2FA bypass
- **[API Security](vulnerabilities/api_security.md)** — OWASP API Top 10, GraphQL, REST testing checklist

---

## Checklists

- **[Master Bug Bounty Checklist](checklists/master_checklist.md)** — Full end-to-end checklist covering all phases
- **[Recon Checklist](checklists/recon_checklist.md)** — Every recon command and output file to maintain
- **[Web Application Checklist](checklists/webapp_checklist.md)** — Based on jhaddix tbhm + OWASP Testing Guide
- **[API Testing Checklist](checklists/api_checklist.md)** — OWASP API Security Top 10 mapped to test cases

---

## Tools Arsenal

- **[Complete Tools Reference](tools/README.md)** — 50+ tools organized by phase, with install commands and purpose

---

## Automation & One-Liners

- **[Recon Automation Scripts](automation/recon_automation.md)** — Full bash recon script + GF pipelines + XSS/SQLi automation
- **[Power One-Liners](automation/oneliners.md)** — 30+ copy-paste ready one-liners for every phase

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

Pull requests are welcome. If you have:
- A new technique that worked in 2025/2026
- A better one-liner for a phase
- A bug fix in a checklist

Open a PR or issue. See [CONTRIBUTING.md](CONTRIBUTING.md).

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
