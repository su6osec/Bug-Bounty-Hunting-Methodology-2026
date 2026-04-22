# Phase 1 — Passive Reconnaissance

> Gather intelligence without touching the target. Every request you skip here is a chance to avoid detection and find assets others missed.

---

## 1.1 ASN & IP Range Discovery

Autonomous System Numbers (ASNs) map companies to entire IP blocks — yours to probe.

```bash
# Find ASN by company name
amass intel -org "Target Company"
asnlookup -o "Target Company"

# Metabigor ASN lookup
echo "Target Company" | metabigor net --org

# BGP.he.net (manual)
# Visit: https://bgp.he.net → search company name

# Convert ASN to IP ranges
whois -h whois.radb.net -- '-i origin AS12345' | grep route
```

**What to do with IP ranges:**
- Scan SSL certs on every IP for company domain references
- Run `masscan` or `nmap` against ranges for open web ports
- Look for admin panels on non-standard ports

---

## 1.2 Apex Domain Discovery

Find ALL domains owned by the company — not just the obvious ones.

### Certificate Transparency Logs
```bash
# crt.sh (passive)
curl -s "https://crt.sh/?q=%25.TARGET.com&output=json" | jq -r '.[].name_value' | sort -u

# certspotter
curl -s "https://certspotter.com/api/v0/issuances?domain=target.com&include_subdomains=true&expand=dns_names" | jq -r '.[].dns_names[]'

# Amass intel mode
amass intel -d target.com -whois
```

### WHOIS / Reverse WHOIS
```bash
# Find all domains registered by same registrant email
# Tools: ViewDNS.info, DomainTools, WhoisXML API
viewdns.info/reversewhois/?q=registrant@email.com

# Amass reverse whois
amass intel -whois -d target.com
```

### Google Dorking for Domains
```bash
# Find subdomains Google has indexed
site:*.target.com -www

# Find related domains via privacy policy / TOS
"target company" inurl:privacy site:*.com

# Find admin panels
site:target.com inurl:admin OR inurl:portal OR inurl:login
```

### Acquisition Tracking
```bash
# Manual: Check Crunchbase for acquisitions
# https://www.crunchbase.com/organization/TARGET/acquisitions

# News-based
# Google: "TARGET acquired" OR "TARGET acquisition" site:techcrunch.com OR site:businesswire.com
```

---

## 1.3 GitHub & Code Repository Reconnaissance

GitHub is where secrets go to die (accidentally).

```bash
# Search for company domain in code
site:github.com "target.com" password OR secret OR key OR token

# GitHub Dork patterns
org:targetcompany filename:.env
org:targetcompany filename:config.yaml
org:targetcompany filename:secrets.json
org:targetcompany DB_PASSWORD
org:targetcompany "api_key"

# GitDorker (automated)
python3 gitdorker.py -tf TOKENS -q target.com -d dorks/alldorks.txt

# truffleHog (secret scanning)
trufflehog github --org=targetcompany

# GitLeaks
gitleaks detect --source=/path/to/cloned/repo
```

**High-value targets in GitHub:**
- Developer personal repos referencing company domains
- Accidentally public company org repos
- CI/CD configuration files (`.github/workflows/`)
- Docker compose files, `.env` examples

---

## 1.4 Shodan / Censys / FOFA Reconnaissance

```bash
# Shodan queries
shodan search "org:Target Company" --fields ip_str,port,hostnames
shodan search 'ssl:"target.com"' --fields ip_str,port
shodan search 'http.title:"Target App" -site:target.com'

# Censys
# Search: parsed.names: target.com
# certificates.parsed.subject.organization: "Target Company"

# Favicon hash hunting (Shodan)
# 1. Get favicon hash with python
python3 -c "import mmh3,requests,base64; r=requests.get('https://target.com/favicon.ico'); h=mmh3.hash(base64.encodebytes(r.content)); print(h)"
# 2. Shodan search
shodan search "http.favicon.hash:HASH_VALUE"
```

---

## 1.5 Wayback Machine & URL Archives

```bash
# GAU - Get All URLs
gau target.com | tee urls.txt

# Waybackurls
echo "target.com" | waybackurls | tee wayback.txt

# Combine and deduplicate
cat urls.txt wayback.txt | sort -u > all_urls.txt

# Extract interesting patterns
cat all_urls.txt | grep -E "\.(json|xml|yaml|env|bak|old|sql|log|conf|config)" 
cat all_urls.txt | grep -E "admin|debug|internal|test|dev|staging|backup"
cat all_urls.txt | grep "?" | grep -E "id=|user=|file=|path=|url=|redirect="
```

---

## 1.6 LinkedIn & People Reconnaissance

```bash
# Find developers working at target
# LinkedIn: people search → "Target Company" → "Software Engineer"

# Then look at their GitHub profiles for:
# - Personal repos with company code
# - Technologies they use (stack clues)
# - Internal tool names / internal domain names

# Tech stack clues from job postings
# LinkedIn Jobs / Indeed → "Target Company Engineer"
# Look for: frameworks, languages, cloud providers, internal tools
```

---

## 1.7 Marketing & Tracking Pixel Analysis

```bash
# Find all apps with same Google Analytics / GTM ID
# 1. Visit main app → view source → find UA-XXXXXXXX or G-XXXXXXXX
# 2. Search Shodan/BuiltWith for that tracking ID
# BuiltWith: https://builtwith.com/relationships/tag/UA-XXXXXXXX

# Favicon hash correlation (see 1.4)
```

---

## 1.8 Passive Recon Output Checklist

Before moving to active enumeration, you should have:

- [ ] All ASN ranges and CIDR blocks
- [ ] All apex domains (via WHOIS, certs, Crunchbase)
- [ ] GitHub repos / exposed secrets list
- [ ] Wayback URLs for main domain
- [ ] Technology stack notes
- [ ] People/developer list with GitHub handles
- [ ] Shodan/Censys hits on company IP ranges

---

## Next Step

→ [Phase 2: Active Enumeration](03_active_enumeration.md)
