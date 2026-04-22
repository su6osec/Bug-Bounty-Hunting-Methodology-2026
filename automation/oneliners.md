# Power One-Liners

---

## Reconnaissance

```bash
# All subdomains in one shot
subfinder -d target.com -all -silent | anew subs.txt

# Passive → Resolve → Probe in one pipeline
subfinder -d target.com -all -silent | puredns resolve -r resolvers.txt -q | httpx -silent -o live.txt

# Quick wayback URL collection for domain
gau target.com | grep "=" | sort -u > params.txt

# Extract URLs with parameters from wayback
echo "target.com" | gau | grep "?" | uro | tee params.txt

# Subdomain enumeration from crt.sh
curl -s "https://crt.sh/?q=%.target.com&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u

# Find all live subdomains with status codes + titles
subfinder -d target.com -silent | httpx -title -status-code -silent

# Mass screenshot
cat live.txt | gowitness file -f - --threads 20

# Find subdomains via JS files
cat live.txt | subjs | sort -u

# Find all JS files on live hosts
cat live.txt | katana -jc -d 3 -silent | grep "\.js$" | sort -u
```

---

## Vulnerability Discovery

```bash
# XSS — quick scan
gau target.com | gf xss | dalfox pipe --silence

# Reflected XSS in all params
cat urls.txt | gf xss | sed 's/=.*/=/' | sort -u | \
  xargs -I{} curl -sk "{}XSSTEST" | grep -l "XSSTEST"

# SQLi detection (time-based blind)
cat params.txt | gf sqli | sqlmap --batch --level 1 --risk 1 -m -

# SSRF detection via interactsh
CALLBACK=$(interactsh-client -v 2>&1 | head -1 | awk '{print $NF}')
cat params.txt | gf ssrf | sed "s/=.*/=$CALLBACK/" | httpx -silent

# Open redirect detection
cat params.txt | gf redirect | \
  sed "s|=.*|=https://evil.com|" | \
  httpx -follow-redirects -silent -location | \
  grep "evil.com"

# LFI quick test
cat params.txt | gf lfi | \
  sed "s|=.*|=../../../../etc/passwd|" | \
  httpx -silent -match-string "root:x:"

# Nuclei on all live hosts
httpx -l subs.txt -silent | nuclei -t cves/ -t exposures/ -severity critical,high -silent

# Subdomain takeover
subfinder -d target.com -silent | nuclei -t takeovers/ -silent

# CORS misconfiguration
cat live.txt | while read url; do
  curl -sI -H "Origin: https://evil.com" "$url" | grep -i "access-control" && echo "$url"
done

# Sensitive file discovery
cat live.txt | while read url; do
  for path in /.git/config /.env /backup.zip /phpinfo.php /server-status; do
    code=$(curl -so /dev/null -w "%{http_code}" "${url}${path}")
    [[ "$code" == "200" ]] && echo "[+] ${url}${path}"
  done
done
```

---

## Data Extraction

```bash
# Extract all parameters from URLs
cat urls.txt | unfurl --unique keys | sort -u > all_params.txt

# Extract all domains from URLs
cat urls.txt | unfurl --unique domains | sort -u

# Find URLs with file extensions (interesting for download vulns)
cat urls.txt | grep -E "\.(pdf|docx|xlsx|csv|sql|bak|backup|zip|tar|gz)$"

# Find URLs with auth-like params
cat urls.txt | grep -iE "(token|api_key|key|secret|auth|credential|password)="

# Extract API paths only
cat urls.txt | grep -E "/api/v[0-9]+" | sort -u

# Find admin paths
cat urls.txt | grep -iE "/(admin|administrator|manage|management|dashboard|console|panel)" | sort -u
```

---

## GitHub Recon

```bash
# Search for secrets in GitHub (requires GITHUB_TOKEN)
curl -s -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/search/code?q=target.com+password" | \
  jq -r '.items[].html_url'

# Company repos
curl -s -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/orgs/COMPANY/repos?per_page=100" | \
  jq -r '.[].clone_url'

# Search for API keys in JS files
cat js_files.txt | while read url; do
  curl -sk "$url" | grep -oE "([A-Za-z0-9_\-]{32,})" | sort -u
done
```

---

## Port & Service Discovery

```bash
# Fast port scan then nmap on open ports
masscan -iL ips.txt -p 1-65535 --rate 5000 -oG /tmp/masscan.txt 2>/dev/null
grep "Ports:" /tmp/masscan.txt | \
  awk '{print $2":"$(NF-1)}' | \
  sed 's|/open.*||' | \
  sort -u | \
  nmap -sV -sC --open -iL - -oN services.txt

# Quick web port scan
nmap -p 80,443,8080,8443,8000,8888,3000,4000,5000,9000,9090,10000 \
  --open -iL ips.txt -oG web_ports.txt
grep "Ports:" web_ports.txt | awk '{print $2}' | \
  xargs -I{} echo "http://{}:80 https://{}:443" | httpx -silent
```

---

## Heartbleed Check

```bash
# Quick Heartbleed check on live HTTPS hosts
cat live_https.txt | while read url; do
  domain=$(echo "$url" | sed 's|https://||')
  echo "$domain" | xargs -I{} bash -c 'echo "Q" | \
    openssl s_client -connect {}:443 -tlsextdebug 2>&1 | \
    grep -i "heartbeat"' && echo "[+] $domain - Heartbleed?"
done
```

---

## Useful Combinations

```bash
# Recon → GF → Dalfox (full XSS pipeline)
subfinder -d target.com -silent | \
  httpx -silent | \
  katana -jc -d 3 -silent | \
  gf xss | \
  dalfox pipe --silence -o xss_results.txt

# Recon → Params → SQLMap
gau target.com | grep "=" | \
  gf sqli | \
  sort -u | head -50 | \
  sqlmap --batch --forms -m /dev/stdin 2>/dev/null | grep "injectable"

# All-in-one passive recon
domain="target.com"
{
  subfinder -d "$domain" -all -silent
  assetfinder --subs-only "$domain"
  curl -s "https://crt.sh/?q=%25.$domain&output=json" | jq -r '.[].name_value' | sed 's/\*\.//'
} | sort -u | puredns resolve -q | httpx -silent -o live_"$domain".txt
```
