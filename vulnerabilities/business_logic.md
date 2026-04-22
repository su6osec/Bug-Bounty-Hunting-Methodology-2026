# Business Logic Flaws

**CWE:** CWE-840 | **OWASP:** A04:2021

---

## What Are Business Logic Flaws?

Vulnerabilities arising from the **design** of an application's logic rather than implementation bugs. No tool can fully find them — they require deep understanding of what the app is supposed to do.

---

## Categories

### 1. Price & Value Manipulation
```bash
# Test:
- Intercept cart checkout, modify price to 0 or negative
- Change currency code
- Modify quantity to negative (credit yourself)
- Apply expired discount codes
- Stack discount codes beyond allowed limit
- Apply coupon for product A to product B

# Burp Intercept → modify:
POST /checkout
{"item_id": "123", "price": "0.01", "qty": "1"}
```

### 2. Multi-Step Process Bypass
```bash
# Test:
- Skip step 2 of 4-step checkout
- Access step 4 URL directly without completing prior steps
- Bypass email verification by directly hitting /verify?token=
- Skip 2FA step by jumping to post-auth page directly

# How:
# Complete process once, record all request URLs
# Replay out of order or skip steps
```

### 3. Race Conditions
```bash
# Test on:
- Coupon/voucher code redemption
- Credit/points withdrawal
- Gift card balance usage
- Concurrent account actions
- Password reset token usage
- Limited-quantity purchases

# Tools:
# Burp Turbo Intruder (race tab)
# Python threading
import concurrent.futures, requests

def redeem_coupon():
    return requests.post('https://target.com/coupon',
                         data={'code': 'SAVE50'},
                         cookies={'session': 'VICTIM_SESSION'})

with concurrent.futures.ThreadPoolExecutor(max_workers=20) as ex:
    futures = [ex.submit(redeem_coupon) for _ in range(20)]
    for f in futures:
        print(f.result().text)
```

### 4. Account/Privilege Logic
```bash
# Test:
- Can free-tier user access paid features via direct URL?
- Can user re-activate expired subscription by replaying a request?
- Does role change take effect immediately or only after session refresh?
- Can you register with admin@target.com to get admin privileges?
- Does deleting account also delete associated API keys?
```

### 5. Trust Boundary Violations
```bash
# Test:
- Does the app trust hidden form fields (price, role, discount)?
- Are client-side validations the only enforcement?
- Can you pass arrays instead of strings to trigger unexpected behavior?
- Does changing Accept-Language break access control?
- Does the app behave differently behind different X-Forwarded-For values?
```

### 6. State Machine Flaws
```bash
# Test:
- Can you use a "password reset" token after resetting?
- Can you process the same webhook event twice?
- Does the system handle concurrent modifications to the same resource?
- Can you complete a KYC bypass by reordering verification steps?
```

---

## Mindset for Logic Flaws

```
Ask yourself at every feature:
  "What would happen if I...
   ...did this out of order?"
   ...sent this twice?"
   ...used this for a different purpose?"
   ...modified this client-side value?"
   ...did this very fast / concurrently?"
   ...did this as a different user?"
   ...did this after I shouldn't be able to?"
```

---

## High-Value Logic Flaw Areas

- Payment flows
- Subscription management
- Role/permission assignment
- Password reset / account recovery
- OAuth / SSO flows
- API rate limiting logic
- File access / download controls
- Administrative functions
