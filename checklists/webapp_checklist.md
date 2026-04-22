# Web Application Testing Checklist

Based on jhaddix tbhm + OWASP Testing Guide + sehno's checklist

---

## Application Recon

- [ ] Map visible content manually (browse all pages)
- [ ] Identify hidden/default content (dir brute force)
- [ ] Test for debug parameters
- [ ] Identify all data entry points
- [ ] Identify technologies used (Wappalyzer)
- [ ] Research known CVEs for identified technologies
- [ ] Gather tech-specific wordlists (Assetnote)
- [ ] Map attack surface (spider / crawl)
- [ ] Identify all JS files for later analysis
- [ ] Review robots.txt and sitemap.xml
- [ ] Check source code comments for secrets/paths

## Authentication

- [ ] Test password quality rules
- [ ] Test for username enumeration
- [ ] Test resilience to password guessing (rate limiting)
- [ ] Test account recovery function
- [ ] Test "remember me" function
- [ ] Test impersonation function
- [ ] Test username uniqueness
- [ ] Check for unsafe distribution of credentials
- [ ] Test for fail-open conditions
- [ ] Test multi-stage mechanisms
- [ ] Test default credentials
- [ ] Test 2FA / MFA bypass

## Session Handling

- [ ] Test tokens for meaning (base64 decode, JWT decode)
- [ ] Test tokens for predictability
- [ ] Check for insecure transmission of tokens
- [ ] Check for disclosure of tokens in logs / URLs
- [ ] Check mapping of tokens to sessions
- [ ] Check session termination on logout
- [ ] Check for session fixation
- [ ] Check for CSRF
- [ ] Check cookie scope (domain, path)
- [ ] Check cookie flags (Secure, HttpOnly, SameSite)

## Access Controls

- [ ] Understand access control requirements
- [ ] Test effectiveness with multiple accounts
- [ ] Test for insecure access control methods (request params, Referer)
- [ ] Test IDOR on all object references
- [ ] Test privilege escalation (horizontal + vertical)
- [ ] Test HTTP method-based access control failures
- [ ] Test path traversal bypass (case, encoding, dots)

## Input Handling

- [ ] Fuzz all request parameters
- [ ] Test for SQL injection
- [ ] Identify all reflected data
- [ ] Test for reflected XSS
- [ ] Test for stored XSS
- [ ] Test for DOM XSS
- [ ] Test for HTTP header injection
- [ ] Test for arbitrary redirection
- [ ] Test for OS command injection
- [ ] Test for path traversal
- [ ] Test for file inclusion (LFI/RFI)
- [ ] Test for SSRF
- [ ] Test for XXE
- [ ] Test for SSTI
- [ ] Test for LDAP injection
- [ ] Test for XPath injection
- [ ] Test for SMTP injection
- [ ] Test for NoSQL injection
- [ ] Test for deserialization

## Application Logic Testing

- [ ] Identify logic attack surface
- [ ] Test transmission of data via client (hidden fields, cookies)
- [ ] Test reliance on client-side validation
- [ ] Test multi-step processes for logic flaws
- [ ] Test handling of incomplete input
- [ ] Test trust boundaries
- [ ] Test transaction logic (race conditions)
- [ ] Test for price/value manipulation
- [ ] Test for workflow bypass

## File Upload

- [ ] Test file extension validation
- [ ] Test Content-Type validation
- [ ] Test magic bytes validation
- [ ] Test for path traversal in filename
- [ ] Test for .htaccess upload
- [ ] Test SVG upload for XSS/XXE
- [ ] Test DOCX/XLSX upload for XXE

## Security Configuration

- [ ] Check Content Security Policy
- [ ] Check X-Frame-Options (Clickjacking)
- [ ] Check HSTS
- [ ] Check X-Content-Type-Options
- [ ] Check Referrer-Policy
- [ ] Check Permissions-Policy
- [ ] Check CORS configuration
- [ ] Check HTTP methods (OPTIONS, TRACE)
- [ ] Check SSL/TLS strength
- [ ] Check error pages (information leakage)
- [ ] Check for .git/.svn exposure
- [ ] Check for backup files (.bak, .old, ~)
- [ ] Check for exposed .env files
- [ ] Check for open redirect

## Miscellaneous

- [ ] Check for DOM-based attacks
- [ ] Check for clickjacking (frame injection)
- [ ] Check local storage for sensitive data
- [ ] Check for persistent cookies with sensitive data
- [ ] Check caching headers on sensitive pages
- [ ] Check for sensitive data in URL parameters
- [ ] Check forms with autocomplete enabled on sensitive fields
- [ ] Check for weak SSL ciphers
- [ ] Check CAPTCHA implementation
- [ ] Follow up on any information leakage found
