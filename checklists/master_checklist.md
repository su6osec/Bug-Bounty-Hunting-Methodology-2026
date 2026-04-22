# Master Bug Bounty Checklist

> Use this as your main tracking sheet for each target. Check off items as you complete them.

---

## Phase 0: Scope & Setup

- [ ] Read program policy completely
- [ ] Note in-scope domains, IPs, apps
- [ ] Note out-of-scope items
- [ ] Note testing restrictions (no DoS, no phishing, etc.)
- [ ] Create two test accounts (attacker + victim)
- [ ] Set up Burp Suite proxy
- [ ] Configure scope in Burp
- [ ] Set up interactsh / Burp Collaborator for OOB callbacks

---

## Phase 1: Passive Recon

- [ ] ASN / IP range enumeration
- [ ] Apex domain discovery (WHOIS, cert logs)
- [ ] Crunchbase / acquisition research
- [ ] Google dorking for domains and login pages
- [ ] GitHub / GitLab code search for secrets
- [ ] Shodan / Censys for exposed assets
- [ ] Favicon hash correlation
- [ ] Wayback Machine URL collection (`gau`, `waybackurls`)
- [ ] Job posting analysis for tech stack clues

---

## Phase 2: Active Enumeration

- [ ] Passive subdomain enumeration (subfinder, amass)
- [ ] Active subdomain brute force (puredns)
- [ ] Subdomain permutations (gotator)
- [ ] HTTP probing (httpx)
- [ ] Port scanning (nmap / masscan)
- [ ] Screenshots (gowitness / aquatone)
- [ ] Technology detection (wappalyzer / httpx)
- [ ] JavaScript file collection
- [ ] Endpoint extraction from JS (linkfinder, katana)
- [ ] Secret scanning in JS
- [ ] Content / directory discovery (ffuf, feroxbuster)
- [ ] Parameter discovery (arjun, paramspider)
- [ ] Cloud asset enumeration
- [ ] Subdomain takeover check (nuclei)

---

## Phase 3: Authentication & Session

- [ ] Username enumeration test
- [ ] Password brute force (with rate limit check)
- [ ] Default credentials check
- [ ] Password reset: Host header injection
- [ ] Password reset: Token entropy
- [ ] Password reset: Token expiry
- [ ] Password reset: Token reuse
- [ ] 2FA: Bypass via direct URL
- [ ] 2FA: Response manipulation
- [ ] 2FA: Brute force (if no rate limit)
- [ ] Session cookie flags (Secure, HttpOnly, SameSite)
- [ ] JWT: Algorithm confusion
- [ ] JWT: Weak secret brute force
- [ ] OAuth: redirect_uri manipulation
- [ ] OAuth: state CSRF
- [ ] OAuth: Implicit flow token theft

---

## Phase 4: Access Control

- [ ] IDOR: numeric IDs on all object endpoints
- [ ] IDOR: UUID-based references
- [ ] IDOR: Encoded/hashed references
- [ ] IDOR: HTTP method switching (GET→DELETE)
- [ ] Horizontal privilege escalation
- [ ] Vertical privilege escalation
- [ ] Path-based access control bypass (case, encoding)
- [ ] IP spoofing header bypass (X-Forwarded-For)
- [ ] BFLA: POST/PUT/DELETE on other users' resources

---

## Phase 5: Injection

- [ ] XSS: Reflected (all input params)
- [ ] XSS: Stored (bio, comments, messages)
- [ ] XSS: DOM-based (JS sink analysis)
- [ ] XSS: Blind (admin-viewed pages)
- [ ] SQLi: GET/POST parameters
- [ ] SQLi: Login fields
- [ ] SQLi: Search boxes
- [ ] SQLi: Order by / sort params
- [ ] SSRF: URL params with interactsh
- [ ] SSRF: Image/PDF/webhook URLs
- [ ] Command injection: File name fields, system params
- [ ] SSTI: Template fields, names, email subjects
- [ ] XXE: XML upload fields, SOAP endpoints
- [ ] LFI: File/page/path parameters
- [ ] LDAP injection: Login / search
- [ ] NoSQL injection: MongoDB operators ($where, $gt)

---

## Phase 6: Business Logic

- [ ] Price manipulation in cart
- [ ] Coupon/discount code reuse
- [ ] Race condition on critical operations
- [ ] Multi-step process bypass
- [ ] Client-side validation bypass
- [ ] Role/permission mass assignment
- [ ] Account enumeration via password reset timing

---

## Phase 7: File Upload

- [ ] Extension blacklist bypass
- [ ] Content-Type bypass
- [ ] Magic bytes bypass
- [ ] Double extension (.php.jpg)
- [ ] Path traversal in filename
- [ ] .htaccess upload (Apache)
- [ ] SVG XSS via upload
- [ ] XXE via SVG/DOCX upload

---

## Phase 8: Security Configuration

- [ ] CORS misconfiguration
- [ ] Security headers audit
- [ ] SSL/TLS configuration (testssl.sh)
- [ ] HTTP methods (OPTIONS, TRACE, PUT)
- [ ] Error page information leakage
- [ ] Source code disclosure (.git, .svn)
- [ ] Backup file disclosure (.bak, .old, ~)
- [ ] Admin panel discovery
- [ ] API documentation exposure

---

## Phase 9: Reporting

- [ ] Bug reproduced reliably
- [ ] Severity assessed with CVSS
- [ ] PoC screenshots/video captured
- [ ] Full request/response documented
- [ ] Business impact written
- [ ] Remediation suggested
- [ ] Report draft written
- [ ] Report submitted to platform
