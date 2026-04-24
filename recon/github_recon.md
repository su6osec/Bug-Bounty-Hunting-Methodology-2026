# GitHub Recon — Deep Dive

> GitHub is the single most productive passive recon source. Developers accidentally commit secrets, internal domain names, infrastructure details, and API keys every day. This guide alone has led to Critical findings on major programs.

---

## Why GitHub Recon Works

- Developers push `.env` files, config files, and test credentials
- Git history retains secrets even after deletion
- Third-party forks may contain sensitive branches the main repo deleted
- Internal tooling repos leaked by employees
- CI/CD workflow files reveal internal infrastructure

---

## Phase 1 — Organization Recon

```bash
# Find company's GitHub organization
# Google: site:github.com "company.com" OR "target company"
# Check LinkedIn engineers' GitHub profiles
# Check job postings mentioning GitHub handle

# API: list all repos in an org
curl -s -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/orgs/TARGET_ORG/repos?per_page=100&type=all" | \
  jq -r '.[].clone_url'

# Include private repos if org is set to public
# Check: are any repos accidentally public?

# List all org members
curl -s -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/orgs/TARGET_ORG/members?per_page=100" | \
  jq -r '.[].login'

# For each member, get their repos
curl -s -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/users/EMPLOYEE/repos?per_page=100" | \
  jq -r '.[].clone_url'
```

---

## Phase 2 — Code Search for Secrets

### GitHub Search API
```bash
# Search for secrets referencing target domain
curl -s -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/search/code?q=target.com+password&per_page=100" | \
  jq -r '.items[].html_url'

# Automated with GitDorker
python3 gitdorker.py \
  -tf tokens.txt \
  -q target.com \
  -d dorks/alldorks.txt \
  -o results/

# Manual GitHub search queries (use at github.com/search)
"target.com" password
"target.com" secret
"target.com" api_key
"target.com" token
"target.com" .env
"target.com" credential
"target.com" BEGIN RSA PRIVATE KEY
"target.com" AWS_SECRET_ACCESS_KEY
"target.com" firebase
"target.com" DB_PASSWORD
```

### High-Value Dork Patterns
```bash
# AWS credentials
"AKIA" "target.com"
filename:.env "AWS_SECRET"
org:TARGET_ORG AWS_ACCESS_KEY_ID

# Private keys
"BEGIN RSA PRIVATE KEY"
"BEGIN EC PRIVATE KEY"
"BEGIN OPENSSH PRIVATE KEY"
org:TARGET_ORG filename:id_rsa

# Database credentials
org:TARGET_ORG filename:.env DB_PASSWORD
org:TARGET_ORG filename:database.yml password
org:TARGET_ORG filename:config.php DB_PASS

# API keys
org:TARGET_ORG api_key
org:TARGET_ORG apikey
org:TARGET_ORG secret_key
org:TARGET_ORG "Authorization: Bearer"

# Internal infrastructure
org:TARGET_ORG filename:docker-compose.yml
org:TARGET_ORG filename:.travis.yml
org:TARGET_ORG filename:Jenkinsfile
org:TARGET_ORG filename:.circleci

# Slack tokens
"xoxb-" OR "xoxp-" "target.com"

# Stripe keys
"sk_live_" "target.com"
"pk_live_" "target.com"

# SendGrid
"SG." org:TARGET_ORG

# Twilio
"AC" auth_token "target.com"

# JWT secrets
org:TARGET_ORG JWT_SECRET
org:TARGET_ORG "jwt.secret"
```

---

## Phase 3 — Git History Mining

```bash
# Clone a target repo (even public ones have deleted secrets in history)
git clone https://github.com/TARGET_ORG/TARGET_REPO
cd TARGET_REPO

# Search entire git history for secrets
git log -p --all | grep -iE "password|secret|token|api_key|credential" | head -100

# View all commits that touched a specific file
git log --all --full-history -- .env
git log --all --full-history -- config/secrets.yml

# Show file content at a specific commit
git show COMMIT_HASH:path/to/file

# Search for specific patterns in all commits
git grep -n "password" $(git rev-list --all)

# Automated: truffleHog
trufflehog git https://github.com/TARGET_ORG/TARGET_REPO

# Automated: gitLeaks
gitleaks detect --source . --report-path leaks.json

# Check all branches
git branch -a
git checkout BRANCH_NAME
git log --oneline
```

---

## Phase 4 — CI/CD Configuration Mining

```bash
# GitHub Actions workflows
find . -path "./.github/workflows/*.yml" | xargs cat

# Look for:
# - Hardcoded credentials in workflow files
# - Secrets referenced: ${{ secrets.DB_PASSWORD }}
#   (these are stored secrets, but leaked secret names = social engineering)
# - Internal URLs and endpoints
# - Commands that reveal infrastructure: kubectl, aws, terraform

# Jenkins
cat Jenkinsfile

# CircleCI
cat .circleci/config.yml

# Travis CI
cat .travis.yml

# Patterns to look for in all CI files
grep -r "password\|secret\|token\|key\|AWS\|GCP\|AZURE\|http://\|https://" .github/ .circleci/ -i
```

---

## Phase 5 — Fork & Branch Analysis

```bash
# List all forks of a public repo
curl -s -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/repos/TARGET_ORG/TARGET_REPO/forks?per_page=100" | \
  jq -r '.[].full_name'

# Forks may contain:
# - Unmerged feature branches with sensitive code
# - Old branches the maintainer deleted but fork still has
# - Employee's personal fork with test credentials

# Check all branches of the main repo
curl -s -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/repos/TARGET_ORG/TARGET_REPO/branches?per_page=100" | \
  jq -r '.[].name'

# Check deleted branches via PR references
# PRs often reference branches that were deleted after merge
# The code is still there in the PR
```

---

## Phase 6 — Personal Developer Accounts

```bash
# Find developers via LinkedIn or company GitHub org
# Search their personal repos for:
# - Side projects using company infrastructure
# - Old projects from their time at the company
# - Dotfiles with credentials (.bashrc, .zshrc, .gitconfig)

# Check if developer has any public gists
curl -s -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/users/DEVELOPER/gists?per_page=100" | \
  jq -r '.[].html_url'

# Gists are often forgotten — check for:
grep -r "password\|api_key\|secret\|token" gist_content -i
```

---

## Automated Tools

```bash
# GitDorker — automated GitHub dorking
git clone https://github.com/obheda12/GitDorker
python3 gitdorker.py -tf token.txt -q target.com -d dorks/alldorks.txt

# truffleHog — deep git history secret scanning
trufflehog github --org=TARGET_ORG
trufflehog git https://github.com/TARGET_ORG/REPO

# gitLeaks — comprehensive secret detection
gitleaks detect --source . -v
gitleaks detect --source . --report-path leaks.json

# github-dorks — collection of dorks
# https://github.com/techgaun/github-dorks

# Gitrob — finds sensitive files in GitHub repos
gitrob TARGET_ORG

# Gitleaks CI integration
gitleaks protect --staged   # runs as pre-commit hook
```

---

## Responsible Handling

When you find credentials or secrets via GitHub:

1. **Do not use them** to access systems beyond confirming they work
2. **Document the finding** — URL to commit/file, what the secret grants access to
3. **Test validity safely** — `aws sts get-caller-identity` to confirm AWS key works, then stop
4. **Report immediately** — GitHub secrets have a short window before they're rotated
5. **Note the severity** — Active credentials = Critical, check program policy on secret findings
