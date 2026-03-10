#!/usr/bin/env bash
# =============================================================================
# IceBreaker — pipx / gem tool installer
# Installs Python pentesting tools that are NOT in nixpkgs.
# Run this after `nrs` completes.
#
# Tools now in nixpkgs (no longer installed here — managed by nix modules):
#   impacket         → python3Packages.impacket   (active-directory.nix)
#   netexec          → netexec                    (active-directory.nix)
#   certipy-ad       → certipy-ad                 (active-directory.nix)
#   ldapdomaindump   → python3Packages.ldapdomaindump (active-directory.nix)
#   donpapi          → donpapi                    (active-directory.nix)
#   lsassy           → python3Packages.lsassy     (active-directory.nix)
#   evil-winrm       → evil-winrm                 (active-directory.nix)
#   pygpoabuse       → pygpoabuse                 (post-exploitation.nix)
#   updog            → updog                      (post-exploitation.nix)
#   mitmproxy        → mitmproxy                  (web.nix / mitm.nix, fixed in 12.x)
#   arjun            → arjun                      (web.nix)
#   name-that-hash   → python3Packages.name-that-hash (password.nix)
#   haiti-hash       → haiti                      (password.nix)
#   shodan           → python3Packages.shodan     (network.nix)
#   recon-ng         → recon-ng                   (network.nix)
#   theHarvester     → theharvester               (network.nix)
#   dnstwist         → dnstwist                   (network.nix)
#
# Usage:
#   ./scripts/install-pipx-tools.sh           # install all
#   ./scripts/install-pipx-tools.sh --update  # upgrade all already-installed
# =============================================================================

set -euo pipefail

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  cat <<'HELP'
IceBreaker — External Tool Installer

Usage:
  ./scripts/install-pipx-tools.sh           Install all pipx/gem tools
  ./scripts/install-pipx-tools.sh --update  Upgrade already-installed tools
  ./scripts/install-pipx-tools.sh --help    Show this help

Only tools NOT available in nixpkgs are installed here.
Run this after `nrs` (NixOS rebuild) completes.
HELP
  exit 0
fi

UPDATE=false
[[ "${1:-}" == "--update" ]] && UPDATE=true

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

info()    { echo -e "${GREEN}[+]${NC} $*"; }
warn()    { echo -e "${YELLOW}[!]${NC} $*"; }
fail()    { echo -e "${RED}[-]${NC} $*"; }

pipx_install() {
  local pkg="$1"
  local name="${2:-$1}"
  if pipx list --short 2>/dev/null | grep -q "^${name%%[>=<@]*}"; then
    if $UPDATE; then
      info "Upgrading  $name"
      pipx upgrade "$name" 2>/dev/null || warn "Could not upgrade $name"
    else
      warn "Already installed: $name (pass --update to upgrade)"
    fi
  else
    info "Installing $name"
    pipx install "$pkg" 2>/dev/null || fail "Failed: $name"
  fi
}

pipx_install_git() {
  local url="$1"
  local name="$2"
  if pipx list --short 2>/dev/null | grep -q "^${name}"; then
    if $UPDATE; then
      info "Upgrading  $name (git)"
      pipx upgrade "$name" 2>/dev/null || warn "Could not upgrade $name"
    else
      warn "Already installed: $name (pass --update to upgrade)"
    fi
  else
    info "Installing $name (from git)"
    pipx install "git+${url}" 2>/dev/null || fail "Failed: $name"
  fi
}

gem_install() {
  local gem="$1"
  if gem list --local | grep -q "^${gem%%[>=<]*} "; then
    if $UPDATE; then
      info "Upgrading gem: $gem"
      gem update "$gem" 2>/dev/null || warn "Could not upgrade $gem"
    else
      warn "Gem already installed: $gem"
    fi
  else
    info "Installing gem: $gem"
    gem install "$gem" 2>/dev/null || fail "Failed gem: $gem"
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

# ── Check pipx is available ───────────────────────────────────────────────────
if ! command -v pipx &>/dev/null; then
  fail "pipx not found. Make sure nrs completed successfully."
  exit 1
fi

info "pipx home: $(pipx environment --value PIPX_HOME 2>/dev/null || echo '~/.local/pipx')"
echo ""

# =============================================================================
# ACTIVE DIRECTORY  (tools not yet in nixpkgs)
# =============================================================================
echo "── Active Directory ─────────────────────────────────────────────────────"

# Windapsearch — LDAP enumeration (Go version not in nixpkgs, Python version GitHub-only)
pipx_install_git "https://github.com/ropnop/windapsearch" "windapsearch"

# SprayHound — password spray with lockout awareness (not in nixpkgs)
pipx_install "sprayhound" "sprayhound"

# BloodHound CE Python ingestor — collects AD data for BloodHound CE
# NOTE: nixpkgs 'bloodhound-ce' is the CE *server* binary (Go), not the Python collector.
#       'bloodhound-py' in nixpkgs is the original BH ingestor (older format).
pipx_install "bloodhound" "bloodhound"

# =============================================================================
# POST-EXPLOITATION  (tools not yet in nixpkgs)
# =============================================================================
echo ""
echo "── Post-Exploitation ────────────────────────────────────────────────────"

# MANSPIDER — SMB share spider (searches for sensitive files by content/name)
# PyPI package name is 'man-spider', NOT 'manspider'
pipx_install "man-spider" "man-spider"

# pwncat-cs — post-exploitation platform (not in nixpkgs; last PyPI release 2022)
# NOTE: nixpkgs has a separate older 'pwncat' package — this is the CS fork
pipx_install "pwncat-cs" "pwncat-cs"

# =============================================================================
# WEB APPLICATION  (tools not yet in nixpkgs)
# =============================================================================
echo ""
echo "── Web Application ──────────────────────────────────────────────────────"

# droopescan — CMS scanner (Drupal, WordPress, SilverStripe, etc.)
pipx_install "droopescan" "droopescan"

# XSStrike — XSS detection suite (stale upstream, last release 2022 — may fail)
pipx_install "xsstrike" "xsstrike"

# =============================================================================
# PASSWORD / CREDENTIALS  (tools not yet in nixpkgs)
# =============================================================================
echo ""
echo "── Password & Credentials ───────────────────────────────────────────────"

# CUPP — Common User Password Profiler (not in nixpkgs)
pipx_install "cupp" "cupp"

# =============================================================================
# MISC / UTILITIES  (tools not yet in nixpkgs)
# =============================================================================
echo ""
echo "── Utilities ────────────────────────────────────────────────────────────"

# Ciphey — automated decryption/decoding (not in nixpkgs; may fail on Python 3.12+)
pipx_install "ciphey" "ciphey"

# =============================================================================
# SUMMARY
# =============================================================================
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ${BOLD}Cyberdeckware loaded. All systems operational.${NC}      ${GREEN}║${NC}"
echo -e "${GREEN}╠══════════════════════════════════════════════════════╣${NC}"
echo -e "${GREEN}║${NC}  Tools installed to ~/.local/bin                     ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}  Run ${BOLD}pipx list${NC} to see all installed packages          ${GREEN}║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════╝${NC}"
echo ""
