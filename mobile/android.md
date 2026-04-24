# Android Bug Bounty Testing

> Mobile apps expose a different attack surface than web. The APK is your source of truth — start there.

---

## Setup

**Required tools:**

**[MobSF](https://github.com/MobSF/Mobile-Security-Framework-MobSF)** — Automated static + dynamic analysis framework
`docker run -it -p 8000:8000 opensecurity/mobile-security-framework-mobsf`

**[Apktool](https://apktool.org)** — Decompile APK to smali and resources
`apt install apktool`

**[jadx](https://github.com/skylot/jadx)** — Decompile APK to readable Java/Kotlin
`apt install jadx`

**[Frida](https://frida.re)** — Dynamic instrumentation toolkit (hook functions at runtime)
`pip3 install frida-tools`

**[Objection](https://github.com/sensepost/objection)** — Runtime mobile exploration powered by Frida
`pip3 install objection`

**[Burp Suite](https://portswigger.net/burp)** — Intercept HTTPS traffic from the device

**[ADB](https://developer.android.com/studio/command-line/adb)** — Android Debug Bridge for device interaction
`apt install adb`

---

## Phase 1 — Static Analysis

### Decompile the APK

```bash
# Download APK from device
adb shell pm list packages | grep target
adb shell pm path com.target.app
adb pull /data/app/com.target.app-1/base.apk target.apk

# Or grab from APKPure / APKMirror for older versions

# Decompile with apktool
apktool d target.apk -o target_decoded/

# Decompile to Java with jadx
jadx -d target_java/ target.apk
jadx-gui target.apk   # GUI version
```

### Hunt for Hardcoded Secrets

```bash
# In decompiled source
grep -r "api_key\|apikey\|secret\|password\|token\|ACCESS_KEY\|firebase" target_java/ -i

# In resources and configs
grep -r "http\|https\|ftp" target_decoded/res/ -i
grep -r "key\|secret\|credential" target_decoded/res/values/ -i

# In AndroidManifest.xml
cat target_decoded/AndroidManifest.xml

# Find Firebase config
grep -r "google-services\|firebase\|AIza" target_decoded/ -i

# Find AWS keys
grep -r "AKIA[0-9A-Z]{16}" target_decoded/ -rn
```

### AndroidManifest.xml Audit

```bash
cat target_decoded/AndroidManifest.xml
```

Look for:

**`android:debuggable="true"`** — Debug mode in production build, allows code execution via ADB

**`android:allowBackup="true"`** — App data can be extracted without root via `adb backup`

**Exported components** — Activities, services, receivers with `android:exported="true"` or missing `android:permission`

**Deep links** — Intent filters with `<data android:scheme="...">` that accept external input

**Custom permissions** — Improperly defined permissions that other apps can use

```bash
# Quick checks
grep "debuggable" AndroidManifest.xml
grep "allowBackup" AndroidManifest.xml
grep "exported=\"true\"" AndroidManifest.xml
grep "android:scheme" AndroidManifest.xml
```

### Network Security Config

```bash
# Find network security config
cat target_decoded/res/xml/network_security_config.xml

# Look for:
# <domain-config cleartextTrafficPermitted="true"> — allows HTTP
# <trust-anchors> with <certificates src="user"> — trusts user-installed certs
# <pin-set> — certificate pinning (you'll need to bypass this)
```

---

## Phase 2 — Traffic Interception

### Set Up Burp Proxy

```bash
# 1. Set proxy on Android device: Wi-Fi → Modify Network → Proxy Manual
#    Host: [your IP], Port: 8080

# 2. Install Burp CA certificate on device
# Download from http://burpsuite/ while proxied
# Settings → Security → Install from storage

# For Android 7+, app must trust user certs:
# Check res/xml/network_security_config.xml for <certificates src="user">
# If absent, patch the APK (see Certificate Pinning Bypass below)
```

### Certificate Pinning Bypass

```bash
# Method 1: Objection (easiest)
objection -g com.target.app explore
# In objection shell:
android sslpinning disable

# Method 2: Frida script
frida -U -f com.target.app -l universal-ssl-unpin.js --no-pause

# Method 3: Patch APK with apktool
# Edit network_security_config.xml to add:
# <certificates src="user" />
# Repack: apktool b target_decoded/ -o patched.apk
# Sign: apksigner sign --ks debug.keystore patched.apk

# Method 4: Xposed + TrustMeAlready / SSLUnpinning module
```

---

## Phase 3 — Dynamic Analysis

### ADB Interaction

```bash
# List installed packages
adb shell pm list packages | grep target

# Launch activity
adb shell am start -n com.target.app/.MainActivity

# Trigger exported activity
adb shell am start -n com.target.app/.AdminActivity

# Send intent to exported receiver
adb shell am broadcast -a com.target.ACTION -n com.target.app/.MyReceiver

# Read local storage
adb shell run-as com.target.app ls /data/data/com.target.app/

# Pull app data
adb pull /data/data/com.target.app/ ./app_data/
```

### Local Storage Analysis

```bash
# After pulling app data
ls -la app_data/

# SQLite databases
find app_data/ -name "*.db" | xargs -I{} sqlite3 {} .dump

# Shared preferences (XML)
cat app_data/shared_prefs/*.xml

# Files directory
ls app_data/files/

# Cache
ls app_data/cache/

# Look for: tokens, session data, PII stored insecurely
```

### Runtime Manipulation with Frida

```bash
# Enumerate loaded classes
frida -U -f com.target.app -l enumerate-classes.js

# Hook a specific method
frida -U -f com.target.app --codeshare pcipolloni/universal-android-ssl-pinning-bypass-with-frida

# Custom hook to dump function args
frida -U -f com.target.app -l hook.js
```

```javascript
// hook.js — hook a login function
Java.perform(function() {
    var Login = Java.use("com.target.app.LoginActivity");
    Login.authenticate.implementation = function(user, pass) {
        console.log("[*] Username: " + user);
        console.log("[*] Password: " + pass);
        return this.authenticate(user, pass);
    };
});
```

---

## Phase 4 — Deep Link & Intent Testing

```bash
# Test deep link handlers
adb shell am start \
  -a android.intent.action.VIEW \
  -d "targetapp://reset-password?token=INJECT" \
  com.target.app

# Test for open redirect via deep link
adb shell am start \
  -a android.intent.action.VIEW \
  -d "targetapp://redirect?url=https://evil.com"

# Test for XSS via deep link into WebView
adb shell am start \
  -a android.intent.action.VIEW \
  -d "targetapp://page?content=<script>alert(1)</script>"
```

---

## Phase 5 — WebView Testing

```bash
# Find WebViews in decompiled code
grep -r "WebView\|loadUrl\|evaluateJavascript\|addJavascriptInterface" target_java/ -rn

# Key checks:
# setJavaScriptEnabled(true) + addJavascriptInterface = RCE risk
# loadUrl with user-controlled input = XSS risk
# setAllowFileAccess(true) + file:// URLs = local file read
# shouldOverrideUrlLoading not implemented = open redirect risk
```

---

## Top Vulnerabilities in Android

**Hardcoded secrets** — API keys, tokens, Firebase credentials in APK source

**Insecure data storage** — PII in SharedPreferences, SQLite, or external storage

**Improper certificate validation** — Custom TrustManager accepting all certs

**Exported components** — Activities/services accessible without permission

**Insecure deep links** — Deep link handlers trusting unvalidated input

**JavaScript Interface abuse** — `addJavascriptInterface` exposing Java methods to JS

**Insecure logging** — Sensitive data written to Logcat

**Backup abuse** — `allowBackup=true` exposing app data

---

## Next Step

→ [iOS Testing](ios.md)
