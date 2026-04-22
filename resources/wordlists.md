# Wordlists Reference

---

## SecLists (Primary)

```bash
git clone https://github.com/danielmiessler/SecLists /usr/share/seclists
```

| Path | Use Case |
|------|----------|
| `Discovery/DNS/subdomains-top1million-110000.txt` | Subdomain brute force |
| `Discovery/DNS/bitquark-subdomains-top100000.txt` | Fast subdomain enum |
| `Discovery/Web-Content/raft-large-words.txt` | Directory brute force |
| `Discovery/Web-Content/common.txt` | Common directories |
| `Discovery/Web-Content/api/objects.txt` | API endpoint discovery |
| `Discovery/Web-Content/swagger.txt` | Swagger/API docs paths |
| `Fuzzing/LFI/LFI-Jhaddix.txt` | LFI path traversal |
| `Fuzzing/XSS/*.txt` | XSS payloads |
| `Fuzzing/SQLi/*.txt` | SQLi payloads |
| `Passwords/Common-Credentials/10k-most-common.txt` | Password brute force |
| `Passwords/Leaked-Databases/rockyou.txt` | Password cracking |
| `Usernames/top-usernames-shortlist.txt` | Username enumeration |

---

## Assetnote Wordlists (Modern, High Quality)

```bash
# Download specific wordlists
wget https://wordlists-cdn.assetnote.io/data/manual/best-dns-wordlist.txt
wget https://wordlists-cdn.assetnote.io/data/automated/httparchive_apiroutes_2024_11_28.txt
wget https://wordlists-cdn.assetnote.io/data/automated/httparchive_directories_2024_11_28.txt
wget https://wordlists-cdn.assetnote.io/data/automated/httparchive_php_2024_11_28.txt
```

---

## DNS Resolvers

```bash
# High-quality public resolvers list
wget https://raw.githubusercontent.com/janmasarik/resolvers/master/resolvers.txt

# Validate resolvers before use
puredns resolve test.com -r resolvers.txt --validate-resolvers
```

---

## Custom Wordlist Generation

```bash
# CeWL — generate wordlist from target website
cewl https://target.com -d 2 -m 5 -w custom_wordlist.txt

# Use for subdomain permutations
puredns bruteforce custom_wordlist.txt target.com -r resolvers.txt

# Gotator permutations
gotator -sub subs.txt -perm permutations.txt -depth 1 -numbers 3

# Common permutation base words
dev, test, staging, prod, admin, api, internal, mail, vpn, 
remote, jenkins, gitlab, jira, confluence, grafana, kibana
```

---

## Technology-Specific Wordlists

```bash
# WordPress
/usr/share/seclists/Discovery/Web-Content/CMS/wordpress.fuzz.txt

# Drupal
/usr/share/seclists/Discovery/Web-Content/CMS/drupal.txt

# Tomcat / Java
/usr/share/seclists/Discovery/Web-Content/tomcat.txt

# Spring Boot actuators
/actuator, /actuator/health, /actuator/env, /actuator/metrics,
/actuator/mappings, /actuator/threaddump, /actuator/heapdump
```
