# iOS Bug Bounty Testing

> iOS is harder to test than Android but programs pay more because fewer hunters do it. A jailbroken device unlocks the full attack surface.

---

## Setup

**Required tools:**

**[Frida](https://frida.re)** — Dynamic instrumentation for runtime hooking
`pip3 install frida-tools`

**[Objection](https://github.com/sensepost/objection)** — Runtime mobile exploration
`pip3 install objection`

**[MobSF](https://github.com/MobSF/Mobile-Security-Framework-MobSF)** — Static analysis framework
`docker run -it -p 8000:8000 opensecurity/mobile-security-framework-mobsf`

**[class-dump](https://github.com/nygard/class-dump)** — Extract Objective-C class headers from binaries
`brew install class-dump`

**[Hopper](https://hopperapp.com) / [Ghidra](https://ghidra-sre.org)** — Binary disassembly and analysis

**[iProxy / libimobiledevice](https://libimobiledevice.org)** — USB tunneling for Burp proxy without Wi-Fi
`apt install libimobiledevice-utils`

**Jailbroken device** — Recommended. Checkra1n (A11 and below), Unc0ver, Dopamine (iOS 16+)

---

## Phase 1 — Static Analysis

### Extract and Analyze the IPA

```bash
# Get IPA from a jailbroken device
# Install frida-ios-dump on device via Cydia/Sileo
python3 dump.py com.target.app

# Or download from AppStore with Apple Configurator 2 (Mac)

# Extract IPA
unzip target.ipa -d target_extracted/
cd target_extracted/Payload/Target.app/

# List contents
ls -la
```

### Binary Analysis

```bash
# Check binary protections
otool -l Target | grep -A4 LC_ENCRYPTION     # encrypted binary
otool -hv Target                              # architecture
checksec --file=Target                        # PIE, stack canary, ARC

# Extract Obj-C headers
class-dump -H Target -o headers/

# Search headers for sensitive methods
grep -r "password\|token\|secret\|key\|auth\|login" headers/ -i
```

### Hunt for Hardcoded Secrets

```bash
# Strings in binary
strings Target | grep -iE "api[_-]?key|secret|token|password|http|https"

# In plist files
find . -name "*.plist" | xargs -I{} plutil -p {}
grep -r "key\|secret\|token\|password" . --include="*.plist" -i

# In JavaScript bundles (React Native apps)
find . -name "*.js" | xargs grep -iE "api_key|secret|token|password"

# AWS keys pattern
grep -r "AKIA[0-9A-Z]{16}" . -rn

# Firebase
grep -r "AIzaSy" . -rn
```

### Info.plist Audit

```bash
plutil -p Info.plist

# Key things to check:
# NSAllowsArbitraryLoads: true  → ATS disabled, HTTP allowed
# NSExceptionDomains              → custom SSL exceptions per domain
# CFBundleURLTypes                → URL scheme handlers (deep links)
# NSCameraUsageDescription        → over-privileged permissions
# NSLocationAlwaysUsageDescription → background location
```

---

## Phase 2 — Traffic Interception

### Burp Proxy Setup (Wi-Fi)

```bash
# 1. Settings → Wi-Fi → [Network] → Configure Proxy → Manual
#    Server: [your IP], Port: 8080

# 2. Install Burp CA on device
# Safari → http://burpsuite/ → download certificate
# Settings → General → VPN & Device Management → Install

# 3. Trust it
# Settings → General → About → Certificate Trust Settings → Enable
```

### Burp Proxy via USB (no Wi-Fi needed)

```bash
# Forward device port to Mac/Linux
iproxy 8080 8080 &

# Configure proxy to 127.0.0.1:8080 on device
```

### SSL Pinning Bypass

```bash
# Method 1: Objection (fastest)
objection -g com.target.app explore
# In objection shell:
ios sslpinning disable

# Method 2: Frida script
frida -U -f com.target.app \
  -l ios-ssl-kill-switch.js --no-pause

# Method 3: SSL Kill Switch 2 (Cydia tweak) — installs system-wide bypass

# Method 4: Repack IPA with modified SSL validation
# Edit AppDelegate.m or use iSpy tweak
```

---

## Phase 3 — Dynamic Analysis on Device

### File System Analysis

```bash
# Via objection (no jailbreak for some paths)
objection -g com.target.app explore

# In objection shell:
env                          # show all app directories
ls /var/mobile/Containers/Data/Application/[UUID]/Documents/
ls /var/mobile/Containers/Data/Application/[UUID]/Library/

# Read files
file read /path/to/file

# Find SQLite databases
find /var/mobile/Containers/Data/Application/ -name "*.sqlite" 2>/dev/null
find /var/mobile/Containers/Data/Application/ -name "*.db" 2>/dev/null

# Read DB
sqlite3 /path/to/database.sqlite .dump
```

### Keychain Analysis

```bash
# Dump keychain via objection
objection -g com.target.app explore
ios keychain dump

# What to look for:
# - Tokens stored with kSecAttrAccessibleAlways (accessible without unlock)
# - Passwords stored in keychain accessible to other apps
# - Sensitive data that should not persist after logout
```

### Runtime Manipulation with Frida

```bash
# List all classes
frida -U -f com.target.app -l list-classes.js

# Hook Objective-C method
frida -U -f com.target.app -l hook-objc.js
```

```javascript
// hook-objc.js — hook login method
var resolver = new ApiResolver('objc');
resolver.enumerateMatches('*[*login*]', {
    onMatch: function(match) {
        console.log(match.name);
        Interceptor.attach(match.address, {
            onEnter: function(args) {
                console.log('[*] Called: ' + match.name);
                console.log('[*] Arg0: ' + ObjC.Object(args[2]).toString());
            }
        });
    },
    onComplete: function() {}
});
```

---

## Phase 4 — Deep Link Testing

```bash
# Trigger deep link from terminal
xcrun simctl openurl booted "targetapp://reset?token=test"

# On physical device (via Frida)
# Or via Safari: navigate to targetapp://path

# Test inputs
targetapp://reset?token=<script>alert(1)</script>
targetapp://redirect?url=https://evil.com
targetapp://user?id=12345   # IDOR via deep link
```

---

## Phase 5 — WebView Testing

```bash
# Find WebViews in headers
grep -r "WKWebView\|UIWebView\|loadRequest\|loadHTMLString" headers/ -i

# Key issues:
# UIWebView (deprecated but still found) — less secure than WKWebView
# loadHTMLString with user data — XSS
# allowsInlineMediaPlayback + JS = attack surface
# shouldStartLoadWithRequest not validating scheme = open redirect

# Test JS execution in WKWebView
objection -g com.target.app explore
ios ui webview exec "document.cookie"
```

---

## Top Vulnerabilities in iOS

**Hardcoded secrets** — API keys, tokens in binary or plist files

**Insecure data storage** — Sensitive data in NSUserDefaults, plaintext files, or over-permissioned Keychain

**Weak ATS (App Transport Security)** — `NSAllowsArbitraryLoads: true` allows HTTP

**Improper certificate validation** — Custom delegate accepting invalid certs

**Insecure deep links** — URL scheme handlers not validating input

**Jailbreak detection bypass** — Weak jailbreak checks that Frida/Objection bypass trivially

**Sensitive data in screenshots** — App doesn't set `ignoreSnapshotOnNextApplicationLaunch`

**Clipboard exposure** — Passwords copied to clipboard readable by any app

---

## Tools Installed via Cydia / Sileo (Jailbroken)

- **SSL Kill Switch 2** — System-wide SSL pinning bypass
- **Filza File Manager** — GUI file system browser
- **Frida** — Dynamic instrumentation (via Frida repo)
- **iSpy** — Class/method hooking GUI
- **AppSync Unified** — Install unsigned IPAs
