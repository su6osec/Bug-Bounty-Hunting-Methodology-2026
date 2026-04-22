# API Security Testing

**OWASP API Security Top 10 (2023)**

---

## API Discovery

```bash
# Find API documentation
/api-docs, /swagger.json, /openapi.json
/swagger-ui.html, /swagger/index.html
/api/v1, /api/v2, /v1, /v2
/graphql, /graphiql
/rest, /api, /ws

# Kiterunner — API route brute force
kr scan https://target.com -w routes-large.kite -t 30 -o kr_results.txt

# FFUF with API-specific wordlists
ffuf -u https://target.com/api/v1/FUZZ \
  -w /usr/share/seclists/Discovery/Web-Content/api/objects.txt \
  -mc 200,201,204,400,401,403

# Parse Swagger/OpenAPI for all endpoints
python3 swagger_parser.py swagger.json
```

---

## OWASP API Top 10 Testing

### API1: Broken Object Level Authorization (BOLA/IDOR)
```bash
# Test every ID in API responses
GET /api/v1/users/1001    # your account
GET /api/v1/users/1002    # another user → BOLA if accessible
```

### API2: Broken Authentication
```bash
# JWT attacks (see authentication.md)
# Lack of token expiration
# API keys in URLs (logged in proxy/server logs)
# Test endpoints without Authorization header
```

### API3: Broken Object Property Level Authorization
```bash
# Mass assignment — send extra fields
POST /api/user/update
{"name": "test", "role": "admin", "verified": true, "credits": 9999}

# Over-fetching — API returns too many fields
GET /api/user/me → returns password hash, internal fields?
```

### API4: Unrestricted Resource Consumption (Rate Limiting)
```bash
# Test rate limits on sensitive endpoints
# Password reset, OTP, login, expensive queries

# Bypass rate limit headers
X-Forwarded-For: [rotating IPs]
X-Real-IP: [rotating IPs]

# Race conditions at rate limits
# Burst 100 requests in 1 second
```

### API5: Broken Function Level Authorization
```bash
# Test admin-level HTTP methods on user accounts
GET /api/users        → 200 (your data)
GET /api/admin/users  → 403
DELETE /api/users/999 → 403 normally → test anyway

# Try undocumented admin endpoints
/api/v1/admin/
/api/internal/
/api/debug/
/api/test/
```

### API6: Unrestricted Access to Sensitive Business Flows
```bash
# Bulk data access
GET /api/export?type=all_users
GET /api/reports?start=2020-01-01&end=2026-01-01

# Automated abuse of business flows
# Mass account creation
# Automated scraping via API
```

### API7: Server-Side Request Forgery
```bash
# Look for URL parameters in API requests
POST /api/webhook
{"url": "http://169.254.169.254/latest/meta-data/"}

# Image processing APIs
POST /api/image/process
{"source": "http://internal-server/sensitive-data"}
```

### API8: Security Misconfiguration
```bash
# CORS misconfiguration
curl -H "Origin: https://evil.com" https://api.target.com/user/data -v
# Check: Access-Control-Allow-Origin: https://evil.com + credentials

# Verbose errors exposing internals
# HTTP methods: OPTIONS, TRACE enabled
# Debug mode active in production

# GraphQL introspection enabled
curl -X POST https://target.com/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"{ __schema { types { name } } }"}'
```

### API9: Improper Inventory Management
```bash
# Older API versions may have fewer security controls
/api/v1/ → deprecated, less secure than /api/v3/
/api/beta/ → testing version, fewer protections
/api/internal/ → not meant to be public

# Test version downgrade attacks
```

### API10: Unsafe Consumption of APIs
```bash
# If target integrates with third-party APIs,
# can you inject malicious data that gets processed?
# SQL/SSTI/XSS in data sent to integrated APIs
```

---

## GraphQL-Specific Testing

```bash
# Introspection (reveals all queries/mutations)
{"query":"{ __schema { queryType { fields { name } } } }"}

# Batch query abuse (rate limit bypass)
[
  {"query": "{ user(id: 1) { email } }"},
  {"query": "{ user(id: 2) { email } }"},
  ...×1000
]

# Field suggestion (even without introspection)
{"query": "{ usr { email } }"}
# Response: "Did you mean user?"

# InQL (Burp extension) for automated GraphQL recon
# Clairvoyance for schema extraction without introspection
python3 clairvoyance.py -o schema.json https://target.com/graphql
```

---

## REST API Quick Checklist

```bash
# For each endpoint:
[ ] Test all HTTP methods (GET, POST, PUT, PATCH, DELETE, OPTIONS)
[ ] Test without authentication
[ ] Test with another user's auth token
[ ] Test with expired/invalid tokens
[ ] Test with admin-level endpoints using user token
[ ] Test IDs: numeric, UUID, username-based
[ ] Test for mass assignment (send extra JSON fields)
[ ] Test for verbose error messages
[ ] Check rate limiting on sensitive operations
[ ] Check for CORS misconfiguration
[ ] Test API versioning (v1 vs v2 security differences)
```
