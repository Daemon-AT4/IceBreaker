#!/usr/bin/env bash
# =============================================================================
# IceBreaker — pipx / gem tool installer
#
# Installs Python pentesting tools as a FALLBACK for when the nix-managed
# versions in modules/pentesting/*.nix fail to build or are missing.
#
# Each section below includes both:
#   - Tools that are NOT in nixpkgs at all
#   - Tools that ARE in nixpkgs but frequently break on unstable
#
# If a nix-managed tool works fine, skip the pipx version — nix is preferred.
# If a nix package fails to build (common on nixpkgs-unstable), run this script
# to get the pipx fallback instead.
#
# Usage:
#   ./scripts/install-pipx-tools.sh           # install all
#   ./scripts/install-pipx-tools.sh --update  # upgrade all already-installed
#   ./scripts/install-pipx-tools.sh --help    # show this help
#
# After running: tools are installed to ~/.local/bin/ (already in $PATH).
# =============================================================================

set -uo pipefail

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  cat <<'HELP'
IceBreaker — External Tool Installer (pipx / gem)

Usage:
  ./scripts/install-pipx-tools.sh           Install all tools
  ./scripts/install-pipx-tools.sh --update  Upgrade already-installed tools
  ./scripts/install-pipx-tools.sh --help    Show this help

Installs pentesting Python tools via pipx (isolated virtualenvs) as fallback
for when nixpkgs versions fail to build or are missing entirely.

Tools are installed to ~/.local/bin/ which is already in your $PATH.
HELP
  exit 0
fi

UPDATE=false
[[ "${1:-}" == "--update" ]] && UPDATE=true

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

info()    { echo -e "${GREEN}[+]${NC} $*"; }
warn()    { echo -e "${YELLOW}[!]${NC} $*"; }
fail()    { echo -e "${RED}[-]${NC} $*"; }
section() { echo -e "\n${BOLD}── $* ──${NC}"; }

FAILED=0
INSTALLED=0
SKIPPED=0

pipx_install() {
  local pkg="$1"
  local name="${2:-$1}"
  if pipx list --short 2>/dev/null | grep -q "^${name%%[>=<@]*}"; then
    if $UPDATE; then
      info "Upgrading  $name"
      pipx upgrade "$name" 2>/dev/null || { warn "Could not upgrade $name"; }
    else
      SKIPPED=$((SKIPPED + 1))
      echo -e "  ${DIM}skip${NC}  $name (already installed)"
    fi
  else
    info "Installing $name"
    if pipx install "$pkg" 2>/dev/null; then
      INSTALLED=$((INSTALLED + 1))
    else
      fail "Failed: $name"
      FAILED=$((FAILED + 1))
    fi
  fi
}

pipx_install_git() {
  local url="$1"
  local name="$2"
  if pipx list --short 2>/dev/null | grep -q "^${name}"; then
    if $UPDATE; then
      info "Upgrading  $name (git)"
      pipx upgrade "$name" 2>/dev/null || { warn "Could not upgrade $name"; }
    else
      SKIPPED=$((SKIPPED + 1))
      echo -e "  ${DIM}skip${NC}  $name (already installed)"
    fi
  else
    info "Installing $name (from git)"
    if pipx install "git+${url}" 2>/dev/null; then
      INSTALLED=$((INSTALLED + 1))
    else
      fail "Failed: $name (git install)"
      FAILED=$((FAILED + 1))
    fi
  fi
}

gem_install() {
  local gem="$1"
  if gem list --local 2>/dev/null | grep -q "^${gem%%[>=<]*} "; then
    if $UPDATE; then
      info "Upgrading gem: $gem"
      gem update "$gem" 2>/dev/null || warn "Could not upgrade $gem"
    else
      SKIPPED=$((SKIPPED + 1))
      echo -e "  ${DIM}skip${NC}  $gem (gem already installed)"
    fi
  else
    info "Installing gem: $gem"
    if gem install "$gem" --user-install 2>/dev/null; then
      INSTALLED=$((INSTALLED + 1))
    else
      fail "Failed gem: $gem"
      FAILED=$((FAILED + 1))
    fi
  fi
}

echo ""
echo -e "${GREEN}"
cat << 'BANNER'
    _______________  ____  ____  ______ ___    __ __ ______ ____
   /  _/ ____/ __ )/ __ \/ __ \/ ____//   |  / //_// ____// __ \
   / // /   / __  / /_/ / /_/ / __/  / /| | / ,<  / __/  / /_/ /
 _/ // /___/ /_/ / _, _/ ____/ /___ / ___ |/ /| |/ /___ / _, _/
/___/\____/_____/_/ |_/_/   /_____//_/  |_/_/ |_/_____//_/ |_|
BANNER
echo -e "${NC}"
echo -e "  ${YELLOW}/// Loading cyberdeckware — external tool installer ///${NC}"
echo ""

# ── Check pipx is available ─────────────────────────────────────────────────
if ! command -v pipx &>/dev/null; then
  fail "pipx not found. Make sure nrs completed successfully."
  exit 1
fi

info "pipx home: $(pipx environment --value PIPX_HOME 2>/dev/null || echo '~/.local/pipx')"

# =============================================================================
# ACTIVE DIRECTORY / WINDOWS
# =============================================================================
# Nix equivalents: python3Packages.impacket, netexec, certipy-ad,
#   python3Packages.ldapdomaindump, donpapi, python3Packages.lsassy,
#   evil-winrm, coercer, bloodhound-py, bloodhound-ce
#
# Install these via pipx if the nix versions fail to build.
# =============================================================================
section "Active Directory / Windows"

# NetExec — CrackMapExec successor (nxc). The definitive AD/SMB/LDAP/WinRM tool.
# Nix: netexec in active-directory.nix. Pipx fallback if nix build fails.
# NOTE: crackmapexec is DEAD — do NOT install it, it fails on Python 3.12+
pipx_install "netexec" "netexec"

# Impacket — Windows protocol toolkit (psexec, secretsdump, ntlmrelayx, etc.)
# Nix: python3Packages.impacket. Pipx fallback.
pipx_install "impacket" "impacket"

# Certipy — Active Directory Certificate Services (ADCS) abuse
# Nix: certipy-ad. Pipx fallback.
# IMPORTANT: the PyPI package is 'certipy-ad' NOT 'certipy' (that's unrelated)
pipx_install "certipy-ad" "certipy-ad"

# BloodHound CE Python ingestor — collects AD relationship data for BH CE
# PyPI: 'bloodhound-ce' (NOT 'bloodhound' — that's the legacy ingestor)
# Nix: bloodhound-py is the legacy ingestor, bloodhound-ce is the CE server
pipx_install "bloodhound-ce" "bloodhound-ce"

# Coercer — Windows authentication coercion (PetitPotam + 14 other methods)
# Nix: coercer in active-directory.nix. Pipx fallback.
pipx_install "coercer" "coercer"

# DonPAPI — DPAPI credential extraction across domain machines
# Nix: donpapi. Pipx fallback.
pipx_install "donpapi" "donpapi"

# lsassy — remote LSASS credential dumping
# Nix: python3Packages.lsassy. Pipx fallback.
pipx_install "lsassy" "lsassy"

# ldapdomaindump — LDAP domain enumeration and HTML report generation
# Nix: python3Packages.ldapdomaindump. Pipx fallback.
pipx_install "ldapdomaindump" "ldapdomaindump"

# dploot — SharpDPAPI rewrite in Python. Extracts DPAPI secrets remotely.
# NOT in nixpkgs.
pipx_install "dploot" "dploot"

# pypykatz — Mimikatz in pure Python. Parses LSASS dumps, SAM/SYSTEM hives.
# NOT in nixpkgs.
pipx_install "pypykatz" "pypykatz"

# mitm6 — IPv6 MITM attack tool. Exploits WPAD + DHCPv6 for credential relay.
# Pairs with ntlmrelayx from impacket.
# NOT in nixpkgs.
pipx_install "mitm6" "mitm6"

# Windapsearch — LDAP enumeration (Python version, Go version not on PyPI)
# NOT in nixpkgs.
pipx_install_git "https://github.com/ropnop/windapsearch" "windapsearch"

# =============================================================================
# POST-EXPLOITATION
# =============================================================================
# Nix equivalents: pwncat in post-exploitation.nix
# =============================================================================
section "Post-Exploitation"

# pwncat-vl — post-exploitation platform (community fork of pwncat-cs)
# The original pwncat-cs is BROKEN on Python 3.12+ (unmaintained since 2022).
# pwncat-vl is the actively maintained fork with Python 3.13+ support.
# NOT in nixpkgs.
pipx_install "pwncat-vl" "pwncat-vl"

# MANSPIDER — SMB share spider (searches file contents across shares)
# PyPI package name is 'man-spider' NOT 'manspider'
# NOTE: depends on textract which can be fragile — may fail on some systems
# NOT in nixpkgs.
pipx_install "man-spider" "man-spider"

# =============================================================================
# WEB APPLICATION
# =============================================================================
# Nix equivalents: mitmproxy, arjun in web.nix
# =============================================================================
section "Web Application"

# mitmproxy — HTTPS interception proxy
# Nix: mitmproxy in web.nix / mitm.nix. Pipx fallback if nix build fails.
pipx_install "mitmproxy" "mitmproxy"

# droopescan — CMS scanner for Drupal, WordPress, SilverStripe, Joomla
# Not actively maintained but still functional for CMS fingerprinting.
# NOT in nixpkgs.
pipx_install "droopescan" "droopescan"

# XSStrike — XSS detection and exploitation suite
# Upstream not actively maintained but still functional.
# NOT in nixpkgs.
pipx_install "xsstrike" "xsstrike"

# =============================================================================
# PASSWORD / CREDENTIALS
# =============================================================================
# Nix equivalents: python3Packages.name-that-hash, haiti in password.nix
# =============================================================================
section "Password & Credentials"

# name-that-hash — identify hash types before cracking
# Nix: python3Packages.name-that-hash. Pipx fallback.
pipx_install "name-that-hash" "name-that-hash"

# CUPP — Common User Password Profiler. Generates targeted wordlists.
# NOT in nixpkgs.
pipx_install "cupp" "cupp"

# =============================================================================
# RECON / OSINT
# =============================================================================
# Nix equivalents: python3Packages.shodan, theharvester, dnstwist in network.nix
# =============================================================================
section "Recon & OSINT"

# Shodan CLI — search engine for internet-connected devices
# Nix: python3Packages.shodan. Pipx fallback.
pipx_install "shodan" "shodan"

# theHarvester — email, subdomain, and IP harvesting from public sources
# Nix: theharvester. Pipx fallback.
pipx_install "theHarvester" "theHarvester"

# dnstwist — domain permutation engine for phishing detection
# Nix: dnstwist. Pipx fallback.
pipx_install "dnstwist" "dnstwist"

# =============================================================================
# CLOUD
# =============================================================================
section "Cloud"

# ROADrecon — Azure AD / Entra ID reconnaissance tool (ROADtools suite)
# Dumps users, groups, apps, service principals, conditional access policies.
# NOT in nixpkgs.
pipx_install "roadrecon" "roadrecon"

# =============================================================================
# RUBY GEMS
# =============================================================================
section "Ruby Gems"

# evil-winrm — WinRM shell with file transfer, DLL loading, AMSI bypass
# Nix: evil-winrm in active-directory.nix. Gem fallback if nix version breaks.
if command -v gem &>/dev/null; then
  gem_install "evil-winrm"
else
  warn "gem not found — skipping evil-winrm (install ruby first)"
fi

# =============================================================================
# SUMMARY
# =============================================================================
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ${BOLD}Cyberdeckware loaded.${NC}                                   ${GREEN}║${NC}"
echo -e "${GREEN}╠══════════════════════════════════════════════════════════╣${NC}"
echo -e "${GREEN}║${NC}  Installed: ${BOLD}${INSTALLED}${NC}                                            ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}  Skipped:   ${SKIPPED} (already present)                         ${GREEN}║${NC}"
if [[ "$FAILED" -gt 0 ]]; then
echo -e "${GREEN}║${NC}  ${RED}Failed:    ${FAILED}${NC} (check errors above)                      ${GREEN}║${NC}"
fi
echo -e "${GREEN}║${NC}                                                          ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}  Tools in: ${BOLD}~/.local/bin${NC}                                    ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}  Run ${BOLD}pipx list${NC} to see installed packages                   ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}  Run with ${BOLD}--update${NC} to upgrade all                          ${GREEN}║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

if [[ "$FAILED" -gt 0 ]]; then
  echo -e "${YELLOW}Some tools failed to install. Common causes:${NC}"
  echo -e "  - Missing build dependencies (rust, gcc, libffi, openssl headers)"
  echo -e "  - Python version incompatibility (some tools need Python 3.11)"
  echo -e "  - Network issues during pip download"
  echo ""
  echo -e "To retry a single tool:  ${BOLD}pipx install <package-name>${NC}"
  echo -e "To force Python 3.11:    ${BOLD}pipx install <package> --python python3.11${NC}"
  echo ""
fi
