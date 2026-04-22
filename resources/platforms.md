# Bug Bounty Platforms

---

## Major Platforms

| Platform | Focus | URL |
|----------|-------|-----|
| HackerOne | Web, Mobile, API | hackerone.com |
| Bugcrowd | Web, IoT, Mobile | bugcrowd.com |
| Intigriti | Web, API (EU-focused) | intigriti.com |
| Synack | Invite-only, high-pay | synack.com |
| YesWeHack | European programs | yeswehack.com |
| Immunefi | Web3, Smart contracts | immunefi.com |
| HackenProof | Blockchain, Web | hackenproof.com |
| Cobalt | Pentest + bounty | cobalt.io |

---

## Self-Hosted Programs (MEGA List)

Many companies run their own programs. Check:
- `https://company.com/.well-known/security.txt`
- `https://company.com/security`
- `https://company.com/bug-bounty`
- `https://company.com/responsible-disclosure`

---

## Scope Discovery Tips

```bash
# Check security.txt on targets
curl -s "https://target.com/.well-known/security.txt"
curl -s "https://target.com/security.txt"

# HackerOne public programs via API
curl "https://api.hackerone.com/v1/hackers/programs" \
  -H "Authorization: Basic BASE64_CREDENTIALS" | \
  jq -r '.data[].attributes | "\(.handle) - \(.submission_state)"'
```

---

## Choosing the Right Program

```
HIGH REWARD programs:
  ✓ Finance/Banking apps
  ✓ Healthcare platforms
  ✓ Cloud infrastructure providers
  ✓ Crypto/Web3 protocols

GOOD FOR LEARNING:
  ✓ Wide scope wildcards (*.company.com)
  ✓ Programs with fast response times
  ✓ Programs with clear scope docs

AVOID (as beginner):
  ✗ VDP (no bounty) unless practicing
  ✗ Very narrow scopes (single login page)
  ✗ Programs with 90+ day response time
```

---

## Tracking Submissions

```markdown
| Date       | Program       | Bug Type  | Severity | Status   | Payout |
|------------|---------------|-----------|----------|----------|--------|
| 2026-01-01 | HackerOne/X   | XSS       | High     | Resolved | $500   |
| 2026-01-15 | Bugcrowd/Y    | IDOR      | Medium   | Triaged  | TBD    |
| 2026-02-01 | Intigriti/Z   | SSRF      | Critical | Open     | -      |
```
