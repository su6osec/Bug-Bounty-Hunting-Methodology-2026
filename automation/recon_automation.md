# Recon Automation Scripts

---

## Full Recon One-Shot Script

```bash
#!/bin/bash
# Usage: ./recon.sh target.com

TARGET=$1
OUTPUT="recon/${TARGET}"
mkdir -p "$OUTPUT"/{subs,urls,js,screenshots,nuclei}

echo "[*] Starting recon for $TARGET"
echo "[*] Output directory: $OUTPUT"

# ─── Phase 1: Passive Subdomain Enum ──────────────────────────────────────────
echo "[+] Passive subdomain enumeration..."
subfinder -d "$TARGET" -all -recursive -silent -o "$OUTPUT/subs/passive.txt"
assetfinder --subs-only "$TARGET" >> "$OUTPUT/subs/passive.txt"
amass enum -passive -d "$TARGET" -o "$OUTPUT/subs/amass_passive.txt" 2>/dev/null
curl -s "https://crt.sh/?q=%25.$TARGET&output=json" | \
  jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u >> "$OUTPUT/subs/passive.txt"

# ─── Phase 2: Deduplicate ─────────────────────────────────────────────────────
cat "$OUTPUT/subs/"*.txt | sort -u > "$OUTPUT/subs/all_raw.txt"

# ─── Phase 3: DNS Resolution ──────────────────────────────────────────────────
echo "[+] Resolving subdomains..."
puredns resolve "$OUTPUT/subs/all_raw.txt" \
  -r /usr/share/seclists/Miscellaneous/dns-resolvers.txt \
  -o "$OUTPUT/subs/resolved.txt" -q

echo "[*] Resolved: $(wc -l < "$OUTPUT/subs/resolved.txt") subdomains"

# ─── Phase 4: HTTP Probing ────────────────────────────────────────────────────
echo "[+] HTTP probing..."
httpx -l "$OUTPUT/subs/resolved.txt" \
  -ports 80,443,8080,8443,8000,8888,3000,5000,9000 \
  -title -status-code -tech-detect -follow-redirects -silent \
  -o "$OUTPUT/live_apps.txt"

grep -oP 'https?://\S+' "$OUTPUT/live_apps.txt" | sort -u > "$OUTPUT/live_urls.txt"
echo "[*] Live applications: $(wc -l < "$OUTPUT/live_urls.txt")"

# ─── Phase 5: URL Collection ──────────────────────────────────────────────────
echo "[+] Collecting URLs from archives..."
cat "$OUTPUT/live_urls.txt" | gau --subs 2>/dev/null | sort -u >> "$OUTPUT/urls/gau.txt"
cat "$OUTPUT/subs/resolved.txt" | waybackurls 2>/dev/null | sort -u >> "$OUTPUT/urls/wayback.txt"
cat "$OUTPUT/urls/"*.txt | sort -u > "$OUTPUT/urls/all.txt"
echo "[*] Total URLs: $(wc -l < "$OUTPUT/urls/all.txt")"

# ─── Phase 6: Screenshots ─────────────────────────────────────────────────────
echo "[+] Taking screenshots..."
gowitness file -f "$OUTPUT/live_urls.txt" \
  --screenshot-path "$OUTPUT/screenshots/" --threads 20 -q 2>/dev/null

# ─── Phase 7: Nuclei Scanning ─────────────────────────────────────────────────
echo "[+] Nuclei scanning (takeovers, CVEs, exposures)..."
nuclei -l "$OUTPUT/live_urls.txt" \
  -t takeovers/ -t exposures/ -t vulnerabilities/ -t technologies/ \
  -severity critical,high,medium \
  -o "$OUTPUT/nuclei/results.txt" -silent

# ─── Phase 8: JS Analysis ────────────────────────────────────────────────────
echo "[+] JavaScript analysis..."
katana -list "$OUTPUT/live_urls.txt" -jc -d 3 -silent | \
  grep "\.js$" | sort -u > "$OUTPUT/js/files.txt"

cat "$OUTPUT/js/files.txt" | while read jsurl; do
  curl -sk "$jsurl" | \
    grep -oP '(?<=")[/][a-zA-Z0-9_/\-\.]+(?=")' 
done | sort -u > "$OUTPUT/js/endpoints.txt"

echo "[+] Done! Results in $OUTPUT/"
echo "    Subdomains: $(wc -l < "$OUTPUT/subs/resolved.txt")"
echo "    Live URLs:  $(wc -l < "$OUTPUT/live_urls.txt")"
echo "    Total URLs: $(wc -l < "$OUTPUT/urls/all.txt")"
echo "    Nuclei:     $(wc -l < "$OUTPUT/nuclei/results.txt") findings"
```

---

## GF Pattern Pipeline

```bash
#!/bin/bash
# Usage: ./gf_scan.sh urls.txt
URLS=$1

echo "[+] Running GF patterns on $URLS"
mkdir -p gf_results

cat "$URLS" | gf xss       | sort -u > gf_results/xss_params.txt
cat "$URLS" | gf sqli      | sort -u > gf_results/sqli_params.txt
cat "$URLS" | gf ssrf      | sort -u > gf_results/ssrf_params.txt
cat "$URLS" | gf redirect  | sort -u > gf_results/redirect_params.txt
cat "$URLS" | gf lfi       | sort -u > gf_results/lfi_params.txt
cat "$URLS" | gf rce       | sort -u > gf_results/rce_params.txt
cat "$URLS" | gf idor      | sort -u > gf_results/idor_params.txt

for f in gf_results/*.txt; do
  count=$(wc -l < "$f")
  echo "  $f: $count URLs"
done
```

---

## Quick XSS Pipeline

```bash
#!/bin/bash
TARGET=$1

# Collect params → filter with GF → test with Dalfox
echo "[+] XSS pipeline for $TARGET"

gau "$TARGET" | \
  grep "=" | \
  gf xss | \
  sort -u | \
  dalfox pipe --follow-redirects --silence -o xss_results.txt

echo "[*] XSS results: $(wc -l < xss_results.txt) findings"
```

---

## Quick SQLi Pipeline

```bash
#!/bin/bash
TARGET=$1

echo "[+] SQLi pipeline for $TARGET"

# Collect URLs with params
gau "$TARGET" | grep "=" | sort -u > /tmp/sqli_urls.txt

# Test with sqlmap in batch mode
cat /tmp/sqli_urls.txt | while read url; do
  sqlmap -u "$url" --batch --level 1 --risk 1 \
    --forms --crawl=1 -q 2>/dev/null | \
    grep -E "injectable|Parameter"
done
```

---

## Subdomain Takeover Pipeline

```bash
#!/bin/bash
TARGET=$1

echo "[+] Subdomain takeover check for $TARGET"

# Enumerate
subfinder -d "$TARGET" -all -silent | \
  puredns resolve -r resolvers.txt -q | \
  nuclei -t takeovers/ -silent -o takeover_results.txt

echo "[*] Potential takeovers: $(wc -l < takeover_results.txt)"
cat takeover_results.txt
```
