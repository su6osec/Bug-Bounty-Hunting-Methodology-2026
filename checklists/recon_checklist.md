# Recon Checklist

---

## Passive Recon

- [ ] `subfinder -d target.com -all -recursive`
- [ ] `amass enum -passive -d target.com`
- [ ] `assetfinder --subs-only target.com`
- [ ] `curl -s "https://crt.sh/?q=%.target.com&output=json" | jq -r '.[].name_value'`
- [ ] `gau target.com`
- [ ] `waybackurls target.com`
- [ ] `shodan search ssl:"target.com"`
- [ ] GitHub dorking: `org:target filename:.env`
- [ ] Crunchbase acquisitions check
- [ ] ASN lookup: `amass intel -org "Company"`
- [ ] ViewDNS reverse WHOIS

## Active Recon

- [ ] `puredns bruteforce wordlist.txt target.com`
- [ ] `gotator -sub subs.txt -perm perms.txt`
- [ ] `httpx -l subs.txt -ports 80,443,8080,8443 -title -tech-detect`
- [ ] `masscan -iL ips.txt -p 1-65535`
- [ ] `nmap -sV -sC -p 80,443,8080,8443 -iL ips.txt`
- [ ] `gowitness file -f live_urls.txt`
- [ ] `nuclei -l live_urls.txt -t takeovers/`
- [ ] `nuclei -l live_urls.txt -t technologies/`
- [ ] `katana -u https://target.com -jc -d 5`
- [ ] `python3 linkfinder.py -i https://target.com -d`
- [ ] `arjun -u https://target.com/api/endpoint`
- [ ] `gf xss urls.txt`, `gf sqli urls.txt`, `gf ssrf urls.txt`
- [ ] `ffuf -u https://target.com/FUZZ -w common.txt`
- [ ] `python3 cloud_enum.py -k targetcompany`
- [ ] `nuclei -l subs.txt -t cves/ -t exposures/`

## Output Files to Maintain

```
target/
├── subs_all.txt
├── subs_live.txt
├── ips.txt
├── ports.txt
├── urls_all.txt
├── js_files.txt
├── js_endpoints.txt
├── params.txt
├── dirs_found.txt
├── screenshots/
├── nuclei_results.txt
└── notes.md
```
