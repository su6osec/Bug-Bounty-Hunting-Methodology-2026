# Quick Wins — High ROI Techniques

> These techniques take 5–15 minutes each and have a disproportionately high hit rate. Run them on every new target before going deep.

---

## 1. Check security.txt

```bash
curl -s https://target.com/.well-known/security.txt
curl -s https://target.com/security.txt

# Often reveals:
# - Acknowledgement page (shows they have an active program)
# - Contact email for disclosure
# - Scope hints
# - PGP key for encrypted reporting
```

---

## 2. Old APK Versions on APKPure

Developers patch bugs in new versions but old APKs stay public forever.

```bash
# Search APKPure / APKMirror for older versions
# https://apkpure.com/search?q=company+app

# Download version 2 releases back
# Decompile with jadx
jadx -d output/ old_version.apk

# Look for:
# Hardcoded endpoints from dev environment
# Debug features removed in newer versions
# Weaker SSL pinning
# Old API version still running on server
```

---

## 3. Staging Subdomains First

```bash
# Staging environments have the same features as production
# but with weaker WAF, debug mode on, and less monitoring

# Check these before touching production:
staging.target.com
uat.target.com
dev.target.com
test.target.com
preprod.target.com
qa.target.com

# Staging often:
# Trusts user-installed SSL certs → no certificate pinning bypass needed
# Has debug headers enabled
# Has verbose error messages
# Has test accounts with predictable passwords (admin/admin, test/test)
# Has weaker rate limiting
```

---

## 4. Check Every Subdomain for Default Credentials

```bash
# Run after screenshot phase — look at screenshots for known software UIs
# Grafana: admin/admin
# Jenkins: admin + read /secrets/initialAdminPassword
# Kibana: elastic/changeme
# Tomcat: tomcat/tomcat, admin/admin
# RabbitMQ: guest/guest
# Webmin: admin/admin
# phpMyAdmin: root/(empty)
# Jupyter: (no auth by default)
# Portainer: admin/admin
# ArgoCD: admin + pod name as password

cat live_urls.txt | httpx -title -silent | grep -iE "grafana|jenkins|kibana|jupyter|portainer"
```

---

## 5. Google Dorking Before Anything Else

```bash
# Do this in the first 10 minutes on any new target

site:target.com inurl:admin
site:target.com inurl:login
site:target.com inurl:dashboard
site:target.com inurl:api
site:target.com filetype:pdf
site:target.com filetype:xlsx OR filetype:csv
site:target.com inurl:backup OR inurl:bak
site:target.com "index of /"     # open directories
site:target.com "parent directory"
site:target.com error
site:target.com "sql syntax"
site:target.com "stack trace"

# Find subdomains Google has indexed
site:*.target.com -www -mail -smtp
```

---

## 6. Wayback Machine Parameter Mining

```bash
# Parameters from years ago still work today
gau target.com | grep "?" | uro | sort -u > params.txt

# Filter for interesting params
cat params.txt | grep -iE "(redirect|url|file|path|page|id|user|admin|debug|cmd|exec|shell)"

# Old admin/debug endpoints
cat params.txt | grep -iE "(admin|debug|test|internal|old|legacy|v1|backup)"

# Parameters removed from UI but still in backend
cat params.txt | grep -v "static\|css\|js\|img\|font" | head -100
```

---

## 7. Check for robots.txt and Sitemap

```bash
curl -s https://target.com/robots.txt
curl -s https://target.com/sitemap.xml
curl -s https://target.com/sitemap_index.xml

# robots.txt Disallow entries = paths worth checking
# Often reveals: /admin/, /internal/, /api/, /backup/

# Extract all URLs from sitemap
curl -s https://target.com/sitemap.xml | grep -oP 'https?://[^<]+'
```

---

## 8. JS File Hunting on First Visit

```bash
# Before any scanning, visit target.com and run in browser console:
# Extract all JS file URLs
Array.from(document.querySelectorAll('script[src]')).map(s => s.src)

# Or automate with:
katana -u https://target.com -jc -d 2 -silent | grep "\.js$"

# Search each JS file for:
grep -iE "api[_-]?key|secret|token|endpoint|internal|staging|debug" *.js

# Run SecretFinder
python3 SecretFinder.py -i https://target.com -e
```

---

## 9. Try HTTP Methods on Every Interesting Endpoint

```bash
# Many endpoints block GET but not PUT/DELETE
# Or accept POST on "GET-only" endpoints

for method in GET POST PUT PATCH DELETE OPTIONS TRACE; do
  echo -n "$method /api/admin/users: "
  curl -s -o /dev/null -w "%{http_code}" \
    -X "$method" https://target.com/api/admin/users \
    -H "Authorization: Bearer USER_TOKEN"
  echo
done

# Also test X-HTTP-Method-Override
curl -X POST https://target.com/api/admin/users \
  -H "X-HTTP-Method-Override: DELETE" \
  -H "Authorization: Bearer USER_TOKEN"
```

---

## 10. Check Old API Versions

```bash
# Most programs deploy v2 or v3 but v1 is still running with fewer controls

curl https://target.com/api/v1/users   # older, less secure
curl https://target.com/api/v2/users   # current version
curl https://target.com/v1/           # alternative path

# v1 often lacks:
# - Rate limiting added in v2
# - New access control checks
# - Input validation improvements
# - Authentication requirements on some endpoints
```

---

## 11. Check SSL Certificate for Extra Subdomains

```bash
# SSL certs often list SANs (Subject Alternative Names) with multiple domains
# This reveals subdomains not in DNS enumeration

openssl s_client -connect target.com:443 2>/dev/null | \
  openssl x509 -noout -text | \
  grep "DNS:" | tr ',' '\n' | sed 's/.*DNS://'

# Or use crt.sh for historical certs
curl -s "https://crt.sh/?q=%.target.com&output=json" | \
  jq -r '.[].name_value' | sort -u
```

---

## 12. Test Password Reset for Host Header Injection

```bash
# 30 seconds, Critical if it works
# Intercept POST /forgot-password
# Add/modify Host header

POST /forgot-password HTTP/1.1
Host: evil.com          ← change this

# Or add X-Forwarded-Host
X-Forwarded-Host: evil.com

# If the reset email sends a link to evil.com:
# You receive victim's reset token
# → Password reset on any account = ATO
```

---

## 13. Run Nuclei Templates Immediately

```bash
# First thing after building live host list
nuclei -l live.txt \
  -t cves/ \
  -t exposures/configs/ \
  -t exposures/files/ \
  -t takeovers/ \
  -t misconfiguration/ \
  -severity critical,high \
  -silent \
  -o nuclei_quick.txt

# Takes 5–15 minutes and finds low-hanging fruit automatically
```

---

## 14. Check for .git and .env Exposure

```bash
# 10 seconds per target, instant Critical if found
for target in $(cat live.txt); do
  code=$(curl -so /dev/null -w "%{http_code}" "${target}/.git/config")
  [[ "$code" == "200" ]] && echo "[GIT EXPOSED] $target"

  code=$(curl -so /dev/null -w "%{http_code}" "${target}/.env")
  [[ "$code" == "200" ]] && echo "[ENV EXPOSED] $target"
done
```

---

## 15. Always Check Mobile App on New Target

```bash
# Before going deep on web testing, download the app
# Run MobSF static analysis (takes 2 minutes)
docker run -it -p 8000:8000 opensecurity/mobile-security-framework-mobsf
# Upload APK at http://localhost:8000

# Check MobSF results for:
# - Hardcoded API keys/secrets
# - Cleartext API endpoints (non-production URLs)
# - Debug flags enabled
# - Firebase database URL (test for unauthorized access)
# - Deep link handlers (attack surface for web app)
```
