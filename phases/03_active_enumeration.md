# Phase 2 — Active Enumeration

> Turn passive intelligence into a live attack surface map. Subdomains → IPs → Ports → Live Apps → Entry Points.

---

## 2.1 Subdomain Enumeration

### Passive Tools (No Direct Target Interaction)
```bash
# Subfinder (Project Discovery) — fastest passive enum
subfinder -d target.com -o subs_passive.txt -all -recursive

# Amass passive
amass enum -passive -d target.com -o subs_amass_passive.txt

# Assetfinder
assetfinder --subs-only target.com >> subs_passive.txt

# GAU for subdomain extraction
echo "target.com" | gau --subs | grep -oP '(?<=\.)[\w-]+\.target\.com' | sort -u

# crt.sh scraping
curl -s "https://crt.sh/?q=%25.target.com&output=json" | \
  jq -r '.[].name_value' | \
  sed 's/\*\.//g' | sort -u >> subs_passive.txt
```

### Active DNS Brute-Force
```bash
# PureDNS with SecLists wordlist
puredns bruteforce /usr/share/seclists/Discovery/DNS/subdomains-top1million-110000.txt target.com \
  -r resolvers.txt -o subs_brute.txt

# ShuffleDNS
shuffledns -d target.com -w wordlist.txt -r resolvers.txt -o subs_shuffle.txt

# Gotator (permutations on found subdomains)
gotator -sub subs_passive.txt -perm permutations.txt -depth 1 -numbers 3 | \
  puredns resolve -r resolvers.txt -o subs_permutations.txt
```

### JavaScript-Based Subdomain Discovery
```bash
# Subdomainizer
python3 SubDomainizer.py -u https://target.com -o subdomainizer.txt

# GoSpider for JS crawling
gospider -s "https://target.com" -o output/ -c 10 -d 3 --js --sitemap

# Katana (Project Discovery)
katana -u https://target.com -d 5 -jc -o katana_urls.txt
```

### Consolidate & Deduplicate
```bash
# Merge all sources
cat subs_passive.txt subs_amass_passive.txt subs_brute.txt subs_permutations.txt | \
  sort -u > all_subs_raw.txt

# Resolve to remove dead entries
puredns resolve all_subs_raw.txt -r resolvers.txt -o all_subs_resolved.txt

echo "[*] Total resolved subdomains: $(wc -l < all_subs_resolved.txt)"
```

---

## 2.2 HTTP Probing — Find Live Applications

```bash
# httpx — comprehensive probing
httpx -l all_subs_resolved.txt \
  -ports 80,443,8080,8443,8000,8888,3000,5000,9000 \
  -title -status-code -tech-detect -follow-redirects \
  -o live_apps.txt

# httprobe (fast)
cat all_subs_resolved.txt | httprobe -c 50 | tee live_urls.txt

# Extract just domains that are alive
cat live_apps.txt | grep "200\|301\|302\|403\|401" | awk '{print $1}' > live_200_403.txt
```

---

## 2.3 Port Scanning

```bash
# Fast masscan on all resolved IPs
# First: resolve subs to IPs
cat all_subs_resolved.txt | dnsx -a -resp-only | sort -u > ips.txt

# Masscan (fast wide scan)
masscan -iL ips.txt -p 1-65535 --rate 10000 -oG masscan_out.txt

# Nmap service/version detection on interesting ports
nmap -sV -sC -iL ips.txt -p 80,443,8080,8443,8000,3000,4000,5000,9000,9090,10000 \
  --open -oN nmap_web_ports.txt

# DNMasscan (combines DNS + masscan)
# https://github.com/MonolithicMonk/dnsmassdns
```

**Look for applications on:**
- `8080`, `8443` — alternative HTTP/S
- `3000` — Node.js/Grafana
- `4000` — dev servers
- `5000` — Flask/dev
- `8888` — Jupyter notebooks
- `9090` — Prometheus
- `10000` — Webmin

---

## 2.4 Screenshots & Visual Recon

```bash
# EyeWitness
python3 EyeWitness.py --web -f live_urls.txt --threads 20 --prepend-https

# Gowitness
gowitness file -f live_urls.txt --threads 20 --delay 2

# Aquatone
cat live_urls.txt | aquatone -out ./aquatone_output/ -threads 20

# Nuclei headless for screenshots
nuclei -l live_urls.txt -t technologies/tech-detect.yaml -screenshot
```

**What to look for in screenshots:**
- Login pages (credential testing opportunity)
- Error messages (version disclosure, path leakage)
- Default "Apache/nginx" pages on subdomains
- Admin interfaces
- Development/staging banners
- Blank pages (may have JS-rendered content)

---

## 2.5 Technology Stack Analysis

```bash
# Wappalyzer CLI
wappalyzer https://target.com --output json

# whatweb
whatweb -a 3 https://target.com

# httpx tech detect
httpx -u https://target.com -tech-detect -json

# BuiltWith (manual) — https://builtwith.com/target.com

# Check security headers
curl -sI https://target.com | grep -iE "server:|x-powered-by:|x-aspnet-version:"
```

---

## 2.6 JavaScript File Analysis

```bash
# Gather all JS files
katana -u https://target.com -jc -d 5 | grep "\.js$" | sort -u > js_files.txt

# getJS
getJS -url https://target.com -complete > js_files.txt

# Extract endpoints from JS
cat js_files.txt | while read url; do
  curl -sk "$url" | grep -oP '(?:"|'"'"')[/][a-zA-Z0-9_/\-\.]+(?:"|'"'"')' 
done | sort -u > js_endpoints.txt

# LinkFinder
python3 linkfinder.py -i https://target.com -d -o cli > linkfinder_out.txt

# subjs (subdomain discovery from JS)
cat live_urls.txt | subjs | sort -u

# Search for secrets in JS
cat js_files.txt | while read url; do
  curl -sk "$url" | grep -iE "(api[_-]?key|secret|token|password|credential|aws|access_key)" 
done

# SecretFinder
python3 SecretFinder.py -i https://target.com -e
```

---

## 2.7 Content Discovery

```bash
# FFUF directory brute force
ffuf -u https://target.com/FUZZ \
  -w /usr/share/seclists/Discovery/Web-Content/raft-large-words.txt \
  -mc 200,201,204,301,302,307,401,403 \
  -ac -t 50 -o ffuf_dirs.json

# Feroxbuster (recursive)
feroxbuster -u https://target.com \
  -w /usr/share/seclists/Discovery/Web-Content/common.txt \
  --depth 3 --threads 50 --auto-tune

# Dirsearch
python3 dirsearch.py -u https://target.com -e php,asp,aspx,jsp,json,xml,conf -t 40

# Common interesting paths to check manually
/.git/config
/.env
/robots.txt
/sitemap.xml
/api/v1/
/swagger.json
/api-docs
/openapi.json
/graphql
/console
/actuator
/metrics
/.well-known/
/backup/
```

---

## 2.8 Parameter Discovery

```bash
# Arjun — parameter fuzzing
arjun -u https://target.com/api/endpoint -m GET
arjun -u https://target.com/api/endpoint -m POST

# ParamSpider
python3 paramspider.py -d target.com --exclude jpg,png,gif,svg,css

# Burp Suite Param Miner (manual)
# Extensions → Param Miner → Guess params

# x8 (hidden parameter discovery)
x8 -u "https://target.com/page?FUZZ=test" -w params_wordlist.txt

# Mine params from Wayback
cat all_urls.txt | grep "?" | unfurl --unique keys | sort -u > discovered_params.txt
```

---

## 2.9 Cloud Asset Enumeration

```bash
# CloudEnum
python3 cloud_enum.py -k targetcompany -l mutations.txt

# S3 bucket enumeration
# Check common naming patterns
aws s3 ls s3://targetcompany --no-sign-request
aws s3 ls s3://target-company-backup --no-sign-request
aws s3 ls s3://targetcompany-dev --no-sign-request

# S3Scanner
python3 s3scanner.py --buckets-file bucket_names.txt

# AWSBucketDump
python3 AWSBucketDump.py -l bucket_names.txt

# GCP bucket
gsutil ls gs://targetcompany

# Azure blob
# https://targetcompany.blob.core.windows.net/
```

---

## 2.10 Subdomain Takeover Detection

```bash
# Nuclei subdomain takeover templates
nuclei -l all_subs_resolved.txt -t takeovers/ -o takeovers.txt

# Subjack
./subjack -w all_subs_resolved.txt -t 100 -timeout 30 -o subjack_results.txt -ssl

# Check manually for common fingerprints:
# "There is no app configured at that hostname" → Heroku
# "NoSuchBucket" → AWS S3
# "Repository not found" → GitHub Pages
# "The request could not be satisfied" → CloudFront
```

---

## Enumeration Output Summary

After this phase you should have:

```
all_subs_resolved.txt     — All resolved subdomains
live_apps.txt             — Live HTTP applications with tech stack
ips.txt                   — All IP addresses
nmap_web_ports.txt        — Open ports + services
js_endpoints.txt          — API endpoints extracted from JS
js_secrets.txt            — Potential secrets from JS
ffuf_dirs.json            — Hidden directories
discovered_params.txt     — Parameters to test
screenshots/              — Visual map of the attack surface
takeovers.txt             — Potential subdomain takeovers
```

---

## Next Step

→ [Phase 3: Vulnerability Discovery](04_vulnerability_discovery.md)
