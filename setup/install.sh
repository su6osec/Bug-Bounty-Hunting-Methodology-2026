#!/bin/bash
# ──────────────────────────────────────────────────────────────────────────────
# Bug Bounty Toolkit Installer
# Sets up all tools from the HuntBook methodology
# Tested on: Kali Linux, Ubuntu 22.04+
# Usage: chmod +x install.sh && sudo ./install.sh
# ──────────────────────────────────────────────────────────────────────────────

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}[*]${NC} $1"; }
log_success() { echo -e "${GREEN}[+]${NC} $1"; }
log_warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
log_error()   { echo -e "${RED}[-]${NC} $1"; }

TOOLS_DIR="$HOME/tools"
mkdir -p "$TOOLS_DIR"

# ──────────────────────────────────────────────────────────────────────────────
log_info "Updating system packages..."
apt-get update -qq
apt-get install -y -qq \
  git curl wget python3 python3-pip golang-go cargo \
  nmap masscan dnsutils whois libpcap-dev \
  ruby rubygems default-jdk \
  chromium-browser unzip jq 2>/dev/null

# ──────────────────────────────────────────────────────────────────────────────
# Go tools setup
export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"
echo 'export GOPATH="$HOME/go"' >> ~/.bashrc
echo 'export PATH="$PATH:$GOPATH/bin"' >> ~/.bashrc

# ──────────────────────────────────────────────────────────────────────────────
log_info "Installing Go-based recon tools..."

go_tools=(
  "github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
  "github.com/projectdiscovery/httpx/cmd/httpx@latest"
  "github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest"
  "github.com/projectdiscovery/dnsx/cmd/dnsx@latest"
  "github.com/projectdiscovery/shuffledns/cmd/shuffledns@latest"
  "github.com/projectdiscovery/katana/cmd/katana@latest"
  "github.com/projectdiscovery/interactsh/cmd/interactsh-client@latest"
  "github.com/tomnomnom/assetfinder@latest"
  "github.com/tomnomnom/waybackurls@latest"
  "github.com/tomnomnom/httprobe@latest"
  "github.com/tomnomnom/anew@latest"
  "github.com/tomnomnom/unfurl@latest"
  "github.com/tomnomnom/gf@latest"
  "github.com/lc/gau/v2/cmd/gau@latest"
  "github.com/ffuf/ffuf/v2@latest"
  "github.com/hahwul/dalfox/v2@latest"
  "github.com/jaeles-project/gospider@latest"
  "github.com/hakluke/hakrawler@latest"
  "github.com/Josue87/gotator@latest"
  "github.com/d3mondev/puredns/v2@latest"
  "github.com/OJ/gobuster/v3@latest"
  "github.com/sensepost/gowitness@latest"
  "github.com/assetnote/kiterunner/cmd/kr@latest"
)

for tool in "${go_tools[@]}"; do
  name=$(echo "$tool" | rev | cut -d'/' -f1 | rev | cut -d'@' -f1)
  log_info "Installing $name..."
  go install "$tool" 2>/dev/null && log_success "$name installed" || log_warn "$name failed"
done

# ──────────────────────────────────────────────────────────────────────────────
log_info "Installing Python-based tools..."

pip3 install -q --upgrade pip
pip3_tools=(
  "arjun"
  "s3scanner"
  "ghauri"
  "trufflehog3"
  "frida-tools"
  "objection"
  "shodan"
)

for tool in "${pip3_tools[@]}"; do
  log_info "Installing $tool..."
  pip3 install -q "$tool" && log_success "$tool installed" || log_warn "$tool failed"
done

# ──────────────────────────────────────────────────────────────────────────────
log_info "Installing git-based tools..."

git_tools=(
  "https://github.com/sqlmapproject/sqlmap"
  "https://github.com/GerbenJavado/LinkFinder"
  "https://github.com/nsonaniya2010/SubDomainizer"
  "https://github.com/s0md3v/Corsy"
  "https://github.com/epinna/tplmap"
  "https://github.com/tarunkant/Gopherus"
  "https://github.com/ticarpi/jwt_tool"
  "https://github.com/defparam/smuggler"
  "https://github.com/obheda12/GitDorker"
  "https://github.com/maurosoria/dirsearch"
  "https://github.com/laramies/theHarvester"
  "https://github.com/jordanpotti/AWSBucketDump"
  "https://github.com/initstring/cloud_enum"
  "https://github.com/devanshbatham/ParamSpider"
  "https://github.com/1ndianl33t/Gf-Patterns"
)

for repo in "${git_tools[@]}"; do
  name=$(echo "$repo" | rev | cut -d'/' -f1 | rev)
  log_info "Cloning $name..."
  git clone -q "$repo" "$TOOLS_DIR/$name" 2>/dev/null && \
    log_success "$name cloned" || \
    log_warn "$name already exists or failed"
done

# Install Python requirements for cloned tools
for req_file in "$TOOLS_DIR"/*/requirements.txt; do
  pip3 install -q -r "$req_file" 2>/dev/null
done

# ──────────────────────────────────────────────────────────────────────────────
log_info "Setting up GF patterns..."
mkdir -p ~/.gf
cp -r "$TOOLS_DIR/Gf-Patterns/"*.json ~/.gf/ 2>/dev/null
log_success "GF patterns installed"

# ──────────────────────────────────────────────────────────────────────────────
log_info "Installing Nuclei templates..."
nuclei -update-templates -silent 2>/dev/null
log_success "Nuclei templates updated"

# ──────────────────────────────────────────────────────────────────────────────
log_info "Installing SecLists..."
if [ ! -d "/usr/share/seclists" ]; then
  git clone -q https://github.com/danielmiessler/SecLists /usr/share/seclists
  log_success "SecLists installed to /usr/share/seclists"
else
  log_warn "SecLists already exists, skipping"
fi

# ──────────────────────────────────────────────────────────────────────────────
log_info "Downloading DNS resolvers..."
wget -q "https://raw.githubusercontent.com/janmasarik/resolvers/master/resolvers.txt" \
  -O "$TOOLS_DIR/resolvers.txt"
log_success "Resolvers saved to $TOOLS_DIR/resolvers.txt"

# ──────────────────────────────────────────────────────────────────────────────
log_info "Installing PureDNS..."
go install github.com/d3mondev/puredns/v2@latest 2>/dev/null
log_success "PureDNS installed"

# ──────────────────────────────────────────────────────────────────────────────
log_info "Installing cargo-based tools..."
if command -v cargo &> /dev/null; then
  cargo install feroxbuster 2>/dev/null && log_success "feroxbuster installed" || log_warn "feroxbuster failed"
  cargo install x8 2>/dev/null && log_success "x8 installed" || log_warn "x8 failed"
else
  log_warn "cargo not found, skipping Rust tools"
fi

# ──────────────────────────────────────────────────────────────────────────────
log_info "Installing GitLeaks..."
GITLEAKS_VERSION="8.18.0"
wget -q "https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz" \
  -O /tmp/gitleaks.tar.gz
tar -xzf /tmp/gitleaks.tar.gz -C /usr/local/bin/ gitleaks
chmod +x /usr/local/bin/gitleaks
log_success "GitLeaks installed"

# ──────────────────────────────────────────────────────────────────────────────
log_info "Installing Subjack..."
go install github.com/haccer/subjack@latest 2>/dev/null
log_success "Subjack installed"

# ──────────────────────────────────────────────────────────────────────────────
log_info "Installing MassDNS..."
git clone -q https://github.com/blechschmidt/massdns "$TOOLS_DIR/massdns" 2>/dev/null
cd "$TOOLS_DIR/massdns" && make -s 2>/dev/null
sudo cp bin/massdns /usr/local/bin/
cd - > /dev/null
log_success "MassDNS installed"

# ──────────────────────────────────────────────────────────────────────────────
# Create convenient aliases
cat >> ~/.bashrc << 'EOF'

# ── Bug Bounty Aliases ──────────────────────────────────────────────────────
alias sqlmap="python3 $HOME/tools/sqlmap/sqlmap.py"
alias dirsearch="python3 $HOME/tools/dirsearch/dirsearch.py"
alias linkfinder="python3 $HOME/tools/LinkFinder/linkfinder.py"
alias subdomainizer="python3 $HOME/tools/SubDomainizer/SubDomainizer.py"
alias corsy="python3 $HOME/tools/Corsy/corsy.py"
alias tplmap="python3 $HOME/tools/tplmap/tplmap.py"
alias gopherus="python3 $HOME/tools/Gopherus/gopherus.py"
alias jwt_tool="python3 $HOME/tools/jwt_tool/jwt_tool.py"
alias gitdorker="python3 $HOME/tools/GitDorker/gitdorker.py"

# Quick recon function
recon() {
  TARGET=$1
  mkdir -p "recon/$TARGET"
  echo "[*] Starting quick recon on $TARGET"
  subfinder -d "$TARGET" -all -silent | anew "recon/$TARGET/subs.txt"
  cat "recon/$TARGET/subs.txt" | httpx -silent | anew "recon/$TARGET/live.txt"
  echo "[+] Subdomains: $(wc -l < recon/$TARGET/subs.txt)"
  echo "[+] Live hosts: $(wc -l < recon/$TARGET/live.txt)"
}
EOF

# ──────────────────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  Installation complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "  Tools installed to:  ~/go/bin/ and ~/tools/"
echo "  SecLists:            /usr/share/seclists/"
echo "  DNS Resolvers:       ~/tools/resolvers.txt"
echo "  GF Patterns:         ~/.gf/"
echo ""
echo "  Run: source ~/.bashrc"
echo "  Then: recon target.com"
echo ""
