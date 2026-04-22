# Tools Arsenal

> All tools used in this methodology. Organized by phase.

---

## Reconnaissance & OSINT

| Tool | Purpose | Install |
|------|---------|---------|
| [Amass](https://github.com/owasp-amass/amass) | Subdomain enum + ASN | `go install github.com/owasp-amass/amass/v4/...@master` |
| [Subfinder](https://github.com/projectdiscovery/subfinder) | Passive subdomain enum | `go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest` |
| [Assetfinder](https://github.com/tomnomnom/assetfinder) | Fast subdomain enum | `go install github.com/tomnomnom/assetfinder@latest` |
| [Shodan CLI](https://cli.shodan.io/) | Search Shodan | `pip3 install shodan` |
| [theHarvester](https://github.com/laramies/theHarvester) | Email/subdomain OSINT | `git clone https://github.com/laramies/theHarvester` |
| [Spiderfoot](https://github.com/smicallef/spiderfoot) | Automated OSINT | `git clone https://github.com/smicallef/spiderfoot` |
| [GitDorker](https://github.com/obheda12/GitDorker) | GitHub dork automation | `git clone https://github.com/obheda12/GitDorker` |
| [truffleHog](https://github.com/trufflesecurity/trufflehog) | Secret scanning | `pip3 install trufflehog3` |
| [GitLeaks](https://github.com/gitleaks/gitleaks) | Git secret detection | `go install github.com/gitleaks/gitleaks/v8@latest` |
| [GAU](https://github.com/lc/gau) | Get All URLs | `go install github.com/lc/gau/v2/cmd/gau@latest` |
| [Waybackurls](https://github.com/tomnomnom/waybackurls) | Wayback Machine URLs | `go install github.com/tomnomnom/waybackurls@latest` |

---

## Subdomain Enumeration & DNS

| Tool | Purpose | Install |
|------|---------|---------|
| [PureDNS](https://github.com/d3mondev/puredns) | DNS brute force + resolve | `go install github.com/d3mondev/puredns/v2@latest` |
| [ShuffleDNS](https://github.com/projectdiscovery/shuffledns) | DNS resolution | `go install github.com/projectdiscovery/shuffledns/cmd/shuffledns@latest` |
| [DNSX](https://github.com/projectdiscovery/dnsx) | DNS toolkit | `go install github.com/projectdiscovery/dnsx/cmd/dnsx@latest` |
| [MassDNS](https://github.com/blechschmidt/massdns) | High-speed resolver | `git clone https://github.com/blechschmidt/massdns` |
| [Gotator](https://github.com/Josue87/gotator) | Subdomain permutations | `go install github.com/Josue87/gotator@latest` |
| [Ripgen](https://github.com/resyncgg/ripgen) | Subdomain permutations | `cargo install ripgen` |

---

## HTTP Probing & Scanning

| Tool | Purpose | Install |
|------|---------|---------|
| [HTTPX](https://github.com/projectdiscovery/httpx) | HTTP toolkit | `go install github.com/projectdiscovery/httpx/cmd/httpx@latest` |
| [httprobe](https://github.com/tomnomnom/httprobe) | HTTP probing | `go install github.com/tomnomnom/httprobe@latest` |
| [Nuclei](https://github.com/projectdiscovery/nuclei) | Vulnerability scanner | `go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest` |
| [Nmap](https://nmap.org/) | Port scanning | `apt install nmap` |
| [Masscan](https://github.com/robertdavidgraham/masscan) | Fast port scanning | `apt install masscan` |

---

## Web Application Testing

| Tool | Purpose | Install |
|------|---------|---------|
| [Burp Suite](https://portswigger.net/burp) | Web proxy / testing | Download from PortSwigger |
| [FFUF](https://github.com/ffuf/ffuf) | Web fuzzing | `go install github.com/ffuf/ffuf/v2@latest` |
| [Feroxbuster](https://github.com/epi052/feroxbuster) | Recursive dir brute | `cargo install feroxbuster` |
| [Dirsearch](https://github.com/maurosoria/dirsearch) | Directory discovery | `git clone https://github.com/maurosoria/dirsearch` |
| [Gobuster](https://github.com/OJ/gobuster) | Directory brute | `go install github.com/OJ/gobuster/v3@latest` |
| [Katana](https://github.com/projectdiscovery/katana) | Web crawler | `go install github.com/projectdiscovery/katana/cmd/katana@latest` |
| [GoSpider](https://github.com/jaeles-project/gospider) | Web spider | `go install github.com/jaeles-project/gospider@latest` |
| [Hakrawler](https://github.com/hakluke/hakrawler) | Web crawler | `go install github.com/hakluke/hakrawler@latest` |
| [LinkFinder](https://github.com/GerbenJavado/LinkFinder) | JS endpoint extract | `git clone https://github.com/GerbenJavado/LinkFinder` |
| [Subdomainizer](https://github.com/nsonaniya2010/SubDomainizer) | JS subdomain hunt | `git clone https://github.com/nsonaniya2010/SubDomainizer` |

---

## Parameter Discovery

| Tool | Purpose | Install |
|------|---------|---------|
| [Arjun](https://github.com/s0md3v/Arjun) | HTTP parameter discovery | `pip3 install arjun` |
| [ParamSpider](https://github.com/devanshbatham/ParamSpider) | URL parameter mining | `git clone https://github.com/devanshbatham/ParamSpider` |
| [x8](https://github.com/Sh1Yo/x8) | Hidden param discovery | `cargo install x8` |
| [Burp Param Miner](https://github.com/PortSwigger/param-miner) | Burp extension | Install via BApp Store |

---

## Vulnerability Testing

| Tool | Purpose | Install |
|------|---------|---------|
| [Dalfox](https://github.com/hahwul/dalfox) | XSS scanner | `go install github.com/hahwul/dalfox/v2@latest` |
| [SQLMap](https://github.com/sqlmapproject/sqlmap) | SQL injection | `git clone https://github.com/sqlmapproject/sqlmap` |
| [Ghauri](https://github.com/r0oth3x49/ghauri) | SQLi (modern) | `pip3 install ghauri` |
| [Corsy](https://github.com/s0md3v/Corsy) | CORS scanner | `git clone https://github.com/s0md3v/Corsy` |
| [CORScanner](https://github.com/chenjj/CORScanner) | CORS scanner | `git clone https://github.com/chenjj/CORScanner` |
| [tplmap](https://github.com/epinna/tplmap) | SSTI detection | `git clone https://github.com/epinna/tplmap` |
| [Gopherus](https://github.com/tarunkant/Gopherus) | SSRF gopher payloads | `git clone https://github.com/tarunkant/Gopherus` |
| [Interactsh](https://github.com/projectdiscovery/interactsh) | OOB callback server | `go install github.com/projectdiscovery/interactsh/cmd/interactsh-client@latest` |
| [jwt_tool](https://github.com/ticarpi/jwt_tool) | JWT testing | `git clone https://github.com/ticarpi/jwt_tool` |
| [Smuggler](https://github.com/defparam/smuggler) | HTTP smuggling | `git clone https://github.com/defparam/smuggler` |
| [Kiterunner](https://github.com/assetnote/kiterunner) | API discovery | `go install github.com/assetnote/kiterunner/cmd/kr@latest` |

---

## Screenshotting & Visualization

| Tool | Purpose | Install |
|------|---------|---------|
| [Gowitness](https://github.com/sensepost/gowitness) | Screenshots | `go install github.com/sensepost/gowitness@latest` |
| [EyeWitness](https://github.com/RedSiege/EyeWitness) | Screenshots + report | `git clone https://github.com/RedSiege/EyeWitness` |
| [Aquatone](https://github.com/michenriksen/aquatone) | Screenshots + HTML report | Download binary from releases |

---

## Cloud Enumeration

| Tool | Purpose | Install |
|------|---------|---------|
| [CloudEnum](https://github.com/initstring/cloud_enum) | Cloud bucket enum | `git clone https://github.com/initstring/cloud_enum` |
| [S3Scanner](https://github.com/sa7mon/S3Scanner) | AWS S3 bucket scan | `pip3 install s3scanner` |
| [AWSBucketDump](https://github.com/jordanpotti/AWSBucketDump) | S3 data exfil | `git clone https://github.com/jordanpotti/AWSBucketDump` |

---

## GF Patterns

```bash
# Install gf
go install github.com/tomnomnom/gf@latest

# Install patterns
git clone https://github.com/1ndianl33t/Gf-Patterns ~/.gf

# Usage
cat urls.txt | gf xss
cat urls.txt | gf sqli
cat urls.txt | gf ssrf
cat urls.txt | gf redirect
cat urls.txt | gf lfi
cat urls.txt | gf rce
cat urls.txt | gf idor
```

---

## Wordlists (SecLists)

```bash
git clone https://github.com/danielmiessler/SecLists /usr/share/seclists

# Key wordlists:
# /usr/share/seclists/Discovery/DNS/subdomains-top1million-110000.txt
# /usr/share/seclists/Discovery/Web-Content/raft-large-words.txt
# /usr/share/seclists/Discovery/Web-Content/common.txt
# /usr/share/seclists/Fuzzing/LFI/LFI-Jhaddix.txt
# /usr/share/seclists/Passwords/Common-Credentials/10k-most-common.txt
# /usr/share/seclists/Usernames/top-usernames-shortlist.txt
```

---

## Assetnote Wordlists

```bash
# Best wordlists for modern apps
# https://wordlists.assetnote.io/

wget https://wordlists-cdn.assetnote.io/data/manual/best-dns-wordlist.txt
wget https://wordlists-cdn.assetnote.io/data/automated/httparchive_apiroutes_2024_11_28.txt
```
