# API Testing Checklist

Based on OWASP API Security Top 10 (2023)

---

## Discovery

- [ ] Find API documentation (Swagger, OpenAPI, Postman collections)
- [ ] Enumerate API endpoints with Kiterunner
- [ ] Check versioned endpoints (v1, v2, v3, beta)
- [ ] Check internal/debug endpoints
- [ ] Check for GraphQL endpoint
- [ ] Parse all JS files for API endpoint references
- [ ] Check mobile app traffic for undocumented APIs

## Authentication

- [ ] Test endpoints without auth token
- [ ] Test with expired token
- [ ] Test with invalid token format
- [ ] Test JWT algorithm confusion (none / RS→HS)
- [ ] Test JWT weak secret
- [ ] Test API key in different positions (header, param, body)
- [ ] Test for API key in URL parameters (get logged)

## Authorization (BOLA / IDOR)

- [ ] Test all IDs with another account's IDs
- [ ] Test numeric IDs sequentially
- [ ] Test UUID-based references
- [ ] Test encoded/hashed references
- [ ] Test object ownership on PUT/PATCH/DELETE
- [ ] Test with different user roles

## Mass Assignment

- [ ] Send extra fields in POST/PUT/PATCH body
- [ ] Try: `"role": "admin"`, `"verified": true`, `"credits": 99999`
- [ ] Check GET response for fields not documented
- [ ] Try arrays, nested objects, unexpected types

## Rate Limiting

- [ ] Test login endpoint
- [ ] Test password reset endpoint
- [ ] Test OTP/2FA endpoint
- [ ] Test search/export endpoints (expensive operations)
- [ ] Test with X-Forwarded-For rotation
- [ ] Test with concurrent requests

## CORS

- [ ] Send `Origin: https://evil.com` to API
- [ ] Check `Access-Control-Allow-Origin` response
- [ ] Check if `null` origin accepted
- [ ] Check if wildcard with credentials
- [ ] Test with authenticated cookies

## HTTP Methods

- [ ] Test OPTIONS on all endpoints
- [ ] Test undocumented methods (PUT, PATCH, DELETE)
- [ ] Test method override headers: `X-HTTP-Method-Override: DELETE`

## GraphQL Specific

- [ ] Test introspection query
- [ ] Test batch query abuse (rate limit bypass)
- [ ] Test for field suggestion (schema leakage)
- [ ] Test mutations for mass assignment
- [ ] Test for nested query abuse (DoS)
- [ ] Test for IDOR via node IDs

## Error Handling

- [ ] Trigger errors with invalid input (SQL chars, special chars)
- [ ] Trigger errors with wrong content types
- [ ] Trigger errors with missing required fields
- [ ] Check if stack traces exposed
- [ ] Check if database queries exposed

## SSRF via API

- [ ] Test webhook URL parameters
- [ ] Test image/PDF/file URL parameters
- [ ] Test import/export by URL features
- [ ] Test metadata URL access
