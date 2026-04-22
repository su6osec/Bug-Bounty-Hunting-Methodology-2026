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

```
┌─────────────────────────────────────────────────────────────────────┐
│                   BUG BOUNTY HUNTING FLOW 2026                       │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  [0] Scope & Program Analysis                                         │
│       └─► Read scope rules, classify (wide/medium/narrow)            │
│                                                                       │
│  [1] Passive Reconnaissance                                           │
│       └─► OSINT, ASN, acquisitions, GitHub, certificates             │
│                                                                       │
│  [2] Active Enumeration                                               │
│       └─► Subdomains → IPs → Ports → Live apps → Screenshots         │
│                                                                       │
│  [3] Vulnerability Discovery (Ebb & Flow)                             │
│       └─► Inject ↔ Recon ↔ Inject ↔ Recon (iterate always)          │
│                                                                       │
│  [4] Exploitation & PoC                                               │
│       └─► Reproduce, escalate severity, chain bugs                   │
│                                                                       │
│  [5] Reporting                                                         │
│       └─► CVSS scoring, evidence, remediation, business impact       │
│                                                                       │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Table of Contents

- [Phases](#-phases)
- [Vulnerability Guides](#-vulnerability-guides)
- [Checklists](#-checklists)
- [Tools Arsenal](#-tools-arsenal)
- [Automation & One-Liners](#-automation--one-liners)
- [Resources](#-resources)
- [Contributing](#-contributing)

---

## Phases

| # | Phase | Description |
|---|-------|-------------|
| 0 | [Scope & Program Analysis](phases/01_scope_and_program_analysis.md) | Understand rules, classify scope, plan attack |
| 1 | [Passive Reconnaissance](phases/02_passive_reconnaissance.md) | OSINT, ASN, acquisitions, cert logs, GitHub leaks |
| 2 | [Active Enumeration](phases/03_active_enumeration.md) | Subdomains, ports, live apps, JS analysis |
| 3 | [Vulnerability Discovery](phases/04_vulnerability_discovery.md) | Injection points, logic flaws, API abuse |
| 4 | [Exploitation & PoC](phases/05_exploitation_and_poc.md) | Bug chaining, severity escalation, PoC creation |
| 5 | [Reporting](phases/06_reporting.md) | Structure, CVSS, evidence, remediation |

---

## Vulnerability Guides

| Vulnerability | Guide |
|--------------|-------|
| Cross-Site Scripting (XSS) | [xss.md](vulnerabilities/xss.md) |
| SQL Injection | [sqli.md](vulnerabilities/sqli.md) |
| IDOR | [idor.md](vulnerabilities/idor.md) |
| SSRF | [ssrf.md](vulnerabilities/ssrf.md) |
| CSRF | [csrf.md](vulnerabilities/csrf.md) |
| LFI / RFI | [lfi_rfi.md](vulnerabilities/lfi_rfi.md) |
| RCE | [rce.md](vulnerabilities/rce.md) |
| XXE | [xxe.md](vulnerabilities/xxe.md) |
| SSTI | [ssti.md](vulnerabilities/ssti.md) |
| Open Redirect | [open_redirect.md](vulnerabilities/open_redirect.md) |
| Subdomain Takeover | [subdomain_takeover.md](vulnerabilities/subdomain_takeover.md) |
| File Upload | [file_upload.md](vulnerabilities/file_upload.md) |
| HTTP Request Smuggling | [http_smuggling.md](vulnerabilities/http_smuggling.md) |
| Business Logic | [business_logic.md](vulnerabilities/business_logic.md) |
| Authentication Flaws | [authentication.md](vulnerabilities/authentication.md) |
| API Security | [api_security.md](vulnerabilities/api_security.md) |

---

## Checklists

| Checklist | Link |
|-----------|------|
| Master Bug Bounty Checklist | [master_checklist.md](checklists/master_checklist.md) |
| Recon Checklist | [recon_checklist.md](checklists/recon_checklist.md) |
| Web Application Checklist | [webapp_checklist.md](checklists/webapp_checklist.md) |
| API Testing Checklist | [api_checklist.md](checklists/api_checklist.md) |

---

## Tools Arsenal

| Category | Guide |
|----------|-------|
| Complete Tools Reference | [tools/README.md](tools/README.md) |

---

## Automation & One-Liners

| Topic | Guide |
|-------|-------|
| Recon Automation Scripts | [automation/recon_automation.md](automation/recon_automation.md) |
| Power One-Liners | [automation/oneliners.md](automation/oneliners.md) |

---

## Resources

| Resource | Link |
|----------|------|
| Payloads Collection | [resources/payloads.md](resources/payloads.md) |
| Wordlists Reference | [resources/wordlists.md](resources/wordlists.md) |
| Learning Resources | [resources/learning_resources.md](resources/learning_resources.md) |
| Bug Bounty Platforms | [resources/platforms.md](resources/platforms.md) |

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
