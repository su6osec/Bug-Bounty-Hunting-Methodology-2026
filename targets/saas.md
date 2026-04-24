# SaaS Platforms — Target Guide

> SaaS is the most common bug bounty target type. Multi-tenancy isolation is the core attack surface — break the walls between tenants and you have Critical.

---

## High-Value Attack Surface

**Multi-tenancy isolation** — Can tenant A access tenant B's data?

**Subdomain-per-tenant model** — `customer.app.com` → subdomain takeover, CORS abuse

**Admin panel** — Usually at `admin.app.com` or `/admin`, often less tested

**API keys and webhooks** — Team members creating/reading each other's keys

**Third-party integrations** — Slack, GitHub, Salesforce, Zapier OAuth connections

**Role-based access control** — Member vs. Admin vs. Owner privilege boundaries

**Billing and subscription** — Feature access tied to plan level

---

## Phase 1 — Recon Focus

```bash
# Subdomain patterns to target
api., admin., dashboard., app., dev., staging., uat., beta.,
webhooks., hooks., status., docs., help., support.,
customer., my., portal., [CUSTOMER_NAME].app.com

# Find customer subdomains (often wildcard)
# *.app.com → any customer can have a subdomain
# Subdomain takeover risk if customers can choose subdomain names

# API versioning
/api/v1/, /api/v2/, /v1/, /v2/, /api/, /rest/

# GraphQL endpoint
/graphql, /api/graphql, /gql

# Admin interfaces
/admin, /superadmin, /internal, /staff, /ops, /manage
```

---

## Phase 2 — High-Impact Tests

### Tenant Isolation (Most Important)
```bash
# Create two accounts in different organizations/workspaces
# Account A: attacker@attacker-org.com
# Account B: victim@victim-org.com

# Test cross-tenant resource access:
# Get resource ID from tenant B
# Access it using tenant A's credentials

GET /api/projects/TENANT_B_PROJECT_ID
Authorization: Bearer TENANT_A_TOKEN

# Test: workspace/org parameter manipulation
GET /api/workspaces/ORG_A_ID/members
→ try GET /api/workspaces/ORG_B_ID/members  # different org

# Test: path-based tenant isolation
# /org/{orgId}/settings — can you change orgId to another org's?
```

### Team Permission Escalation
```bash
# Test each role boundary
# Viewer, Member, Admin, Owner — each should have strict limits

# Can a Member perform Admin actions?
POST /api/settings/delete-workspace   # with Member token

# Can a removed member still access data?
# 1. Invite attacker, get token
# 2. Admin removes attacker from workspace
# 3. Can attacker still read data with old token?

# Can you invite yourself to admin role?
POST /api/invites
{"email": "attacker@evil.com", "role": "admin"}

# Mass assignment on role
PUT /api/users/me
{"role": "admin", "name": "test"}   # does role get updated?
```

### API Key Abuse
```bash
# API keys often have insufficient scope validation
# Test if a read-only API key can perform write operations
# Test if one workspace's API key works on another workspace

# Key enumeration
# If API keys are sequential or predictable

# Key rotation bypass
# Create key → rotate key → is old key still valid for some grace period?
```

### Subdomain-Tenant CORS Abuse
```bash
# SaaS platforms often allow all *.app.com origins
# Take over an abandoned subdomain
# Make cross-origin requests to api.app.com using abandoned subdomain origin
# Access data of legitimate users

curl -H "Origin: https://abandoned-tenant.app.com" \
  "https://api.app.com/v1/me" \
  -H "Authorization: Bearer VICTIM_TOKEN"
```

### Feature Flag / Plan Bypass
```bash
# Test if free plan features can access paid features

# Common patterns:
# Downgrade account → still access premium API endpoints?
# Modify plan parameter in request
{"plan": "enterprise"}

# Check if feature gates are client-side only
# Intercept request and look for plan checks in JS
grep -r "isPremium\|isEnterprise\|canAccess\|hasFeature" js/ -n
```

---

## Phase 3 — Business Logic

```bash
# Invitation link abuse
# Can you reuse an invitation link after joining?
# Can you modify the role in the invitation URL?

# Import/export functionality
# XXE in CSV/XML imports
# Path traversal in export filename
# SSRF in import-from-URL features

# Webhook SSRF
# Webhooks that fetch URLs → SSRF
POST /api/webhooks
{"url": "http://169.254.169.254/latest/meta-data/"}

# Integration OAuth abuse
# SaaS apps often re-implement OAuth for third-party integrations
# Test redirect_uri, state, token leakage in each integration

# Audit log tampering
# Can you suppress or modify audit trail entries?
# Especially relevant in compliance-focused SaaS
```

---

## Phase 4 — Admin Panel Testing

```bash
# Find admin panel
/admin, /superadmin, /internal, /ops, /staff, /console

# Test admin endpoints with regular user token
GET /admin/users
Authorization: Bearer REGULAR_USER_TOKEN

# Check if admin panel has weaker security controls
# Often less tested, may lack:
# - Rate limiting on admin actions
# - CSRF tokens
# - 2FA requirements

# Mass user actions
POST /admin/users/bulk-delete
POST /admin/users/export-all
```

---

## Severity in SaaS Context

**Cross-tenant data access (PII, API keys, source code)** → Critical

**Cross-tenant account takeover** → Critical

**Admin panel access as regular user** → Critical

**Cross-workspace API key usage** → High

**Role escalation within workspace** → High

**Feature flag bypass** → Medium (depends on feature)

**Audit log manipulation** → Medium–High (compliance impact)
