# Tools Arsenal

> All tools used in this methodology, organized by phase with install commands.

---

## Reconnaissance & OSINT

**[Amass](https://github.com/owasp-amass/amass)** — Subdomain enum + ASN lookup
`go install github.com/owasp-amass/amass/v4/...@master`

**[Subfinder](https://github.com/projectdiscovery/subfinder)** — Passive subdomain enumeration
`go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest`

**[Assetfinder](https://github.com/tomnomnom/assetfinder)** — Fast subdomain enum from multiple sources
`go install github.com/tomnomnom/assetfinder@latest`

**[Shodan CLI](https://cli.shodan.io/)** — Search internet-exposed assets
`pip3 install shodan`

**[theHarvester](https://github.com/laramies/theHarvester)** — Email and subdomain OSINT
`git clone https://github.com/laramies/theHarvester`

**[Spiderfoot](https://github.com/smicallef/spiderfoot)** — Automated multi-source OSINT
`git clone https://github.com/smicallef/spiderfoot`

**[GitDorker](https://github.com/obheda12/GitDorker)** — GitHub dork automation for secrets
`git clone https://github.com/obheda12/GitDorker`

**[truffleHog](https://github.com/trufflesecurity/trufflehog)** — Secret scanning in git history
`pip3 install trufflehog3`

**[GitLeaks](https://github.com/gitleaks/gitleaks)** — Git secret detection with rule-based patterns
`go install github.com/gitleaks/gitleaks/v8@latest`

**[GAU](https://github.com/lc/gau)** — Get All URLs from Wayback, AlienVault, URLScan
`go install github.com/lc/gau/v2/cmd/gau@latest`

**[Waybackurls](https://github.com/tomnomnom/waybackurls)** — Wayback Machine URL extraction
`go install github.com/tomnomnom/waybackurls@latest`

---

## Subdomain Enumeration & DNS

**[PureDNS](https://github.com/d3mondev/puredns)** — DNS brute force + mass resolution
`go install github.com/d3mondev/puredns/v2@latest`

**[ShuffleDNS](https://github.com/projectdiscovery/shuffledns)** — DNS resolution at scale
`go install github.com/projectdiscovery/shuffledns/cmd/shuffledns@latest`

**[DNSX](https://github.com/projectdiscovery/dnsx)** — DNS toolkit for probing and enumeration
`go install github.com/projectdiscovery/dnsx/cmd/dnsx@latest`

**[MassDNS](https://github.com/blechschmidt/massdns)** — High-speed stub resolver
`git clone https://github.com/blechschmidt/massdns`

**[Gotator](https://github.com/Josue87/gotator)** — Subdomain permutation generator
`go install github.com/Josue87/gotator@latest`

**[Ripgen](https://github.com/resyncgg/ripgen)** — High-performance subdomain permutations
`cargo install ripgen`

---

## HTTP Probing & Scanning

**[HTTPX](https://github.com/projectdiscovery/httpx)** — Multi-purpose HTTP toolkit with tech detection
`go install github.com/projectdiscovery/httpx/cmd/httpx@latest`

**[httprobe](https://github.com/tomnomnom/httprobe)** — Simple, fast HTTP/S probing
`go install github.com/tomnomnom/httprobe@latest`

**[Nuclei](https://github.com/projectdiscovery/nuclei)** — Template-based vulnerability scanner
`go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest`

**[Nmap](https://nmap.org/)** — Port scanning and service detection
`apt install nmap`

**[Masscan](https://github.com/robertdavidgraham/masscan)** — Fastest internet-scale port scanner
`apt install masscan`

---

## Web Application Testing

**[Burp Suite](https://portswigger.net/burp)** — Industry-standard web proxy and testing platform
Download from PortSwigger

**[FFUF](https://github.com/ffuf/ffuf)** — Web fuzzer for directories, parameters, and endpoints
`go install github.com/ffuf/ffuf/v2@latest`

**[Feroxbuster](https://github.com/epi052/feroxbuster)** — Recursive directory brute force
`cargo install feroxbuster`

**[Dirsearch](https://github.com/maurosoria/dirsearch)** — Web path scanner with large wordlists
`git clone https://github.com/maurosoria/dirsearch`

**[Gobuster](https://github.com/OJ/gobuster)** — Directory, DNS, and vhost brute force
`go install github.com/OJ/gobuster/v3@latest`

**[Katana](https://github.com/projectdiscovery/katana)** — Next-gen web crawler with JS parsing
`go install github.com/projectdiscovery/katana/cmd/katana@latest`

**[GoSpider](https://github.com/jaeles-project/gospider)** — Fast web spider
`go install github.com/jaeles-project/gospider@latest`

**[Hakrawler](https://github.com/hakluke/hakrawler)** — Fast web crawler for security testing
`go install github.com/hakluke/hakrawler@latest`

**[LinkFinder](https://github.com/GerbenJavado/LinkFinder)** — JavaScript endpoint extractor
`git clone https://github.com/GerbenJavado/LinkFinder`

**[Subdomainizer](https://github.com/nsonaniya2010/SubDomainizer)** — Find subdomains in JS files
`git clone https://github.com/nsonaniya2010/SubDomainizer`

---

## Parameter Discovery

**[Arjun](https://github.com/s0md3v/Arjun)** — HTTP parameter discovery for GET/POST/JSON
`pip3 install arjun`

**[ParamSpider](https://github.com/devanshbatham/ParamSpider)** — Mine parameters from Wayback Machine
`git clone https://github.com/devanshbatham/ParamSpider`

**[x8](https://github.com/Sh1Yo/x8)** — Hidden HTTP parameter discovery
`cargo install x8`

**[Burp Param Miner](https://github.com/PortSwigger/param-miner)** — Discover unlinked parameters in Burp
Install via BApp Store

---

## Vulnerability Testing

**[Dalfox](https://github.com/hahwul/dalfox)** — XSS scanner with DOM analysis
`go install github.com/hahwul/dalfox/v2@latest`

**[SQLMap](https://github.com/sqlmapproject/sqlmap)** — SQL injection detection and exploitation
`git clone https://github.com/sqlmapproject/sqlmap`

**[Ghauri](https://github.com/r0oth3x49/ghauri)** — Modern SQL injection tool
`pip3 install ghauri`

**[Corsy](https://github.com/s0md3v/Corsy)** — CORS misconfiguration scanner
`git clone https://github.com/s0md3v/Corsy`

**[CORScanner](https://github.com/chenjj/CORScanner)** — Advanced CORS scanner
`git clone https://github.com/chenjj/CORScanner`

**[tplmap](https://github.com/epinna/tplmap)** — SSTI detection and exploitation
`git clone https://github.com/epinna/tplmap`

**[Gopherus](https://github.com/tarunkant/Gopherus)** — Generate gopher:// payloads for SSRF
`git clone https://github.com/tarunkant/Gopherus`

**[Interactsh](https://github.com/projectdiscovery/interactsh)** — OOB interaction server for blind vulns
`go install github.com/projectdiscovery/interactsh/cmd/interactsh-client@latest`

**[jwt_tool](https://github.com/ticarpi/jwt_tool)** — JWT testing and exploitation toolkit
`git clone https://github.com/ticarpi/jwt_tool`

**[Smuggler](https://github.com/defparam/smuggler)** — HTTP request smuggling detection
`git clone https://github.com/defparam/smuggler`

**[Kiterunner](https://github.com/assetnote/kiterunner)** — API route discovery and brute force
`go install github.com/assetnote/kiterunner/cmd/kr@latest`

---

## Screenshotting & Visualization

**[Gowitness](https://github.com/sensepost/gowitness)** — Web screenshot tool with report
`go install github.com/sensepost/gowitness@latest`

**[EyeWitness](https://github.com/RedSiege/EyeWitness)** — Screenshots + HTML report + metadata
`git clone https://github.com/RedSiege/EyeWitness`

**[Aquatone](https://github.com/michenriksen/aquatone)** — Visual inspection of websites at scale
Download binary from releases

---

## Cloud Enumeration

**[CloudEnum](https://github.com/initstring/cloud_enum)** — Multi-cloud bucket and resource enumeration
`git clone https://github.com/initstring/cloud_enum`

**[S3Scanner](https://github.com/sa7mon/S3Scanner)** — Scan for open S3 buckets
`pip3 install s3scanner`

**[AWSBucketDump](https://github.com/jordanpotti/AWSBucketDump)** — Enumerate S3 bucket contents
`git clone https://github.com/jordanpotti/AWSBucketDump`

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
wget https://wordlists-cdn.assetnote.io/data/manual/best-dns-wordlist.txt
wget https://wordlists-cdn.assetnote.io/data/automated/httparchive_apiroutes_2024_11_28.txt
wget https://wordlists-cdn.assetnote.io/data/automated/httparchive_directories_2024_11_28.txt
```
