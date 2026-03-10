#!/usr/bin/env bash
# =============================================================================
# IceBreaker — First-time Setup Script
# Handles EVERYTHING so users never need to touch /etc/nixos/.
#
# What this script does:
#   1. Copies hardware-configuration.nix from /etc/nixos/ into ~/IceBreaker/
#   2. Makes all scripts executable
#   3. Creates user directories (~/targets, ~/ctf, ~/vpn)
#   4. Updates flake inputs (bootstraps flakes if not yet enabled)
#   5. Rebuilds the entire NixOS system from this flake
#
# IMPORTANT: On NixOS, /etc/nix/nix.conf is a symlink into /nix/store/ and
# is READ-ONLY — you CANNOT write to it, even with sudo. Flakes are enabled
# through the NixOS module system (nix-helpers.nix sets experimental-features).
# For the bootstrap (before the first rebuild), we use:
#   nix CLI:          --extra-experimental-features 'nix-command flakes'
#   nixos-rebuild:    --option extra-experimental-features 'nix-command flakes'
# These are DIFFERENT flags — nixos-rebuild does NOT support --extra-experimental-features.
#
# Usage:
#   cd ~/IceBreaker && ./scripts/setup.sh
#
# If the script fails, see the "MANUAL SETUP" section printed at the bottom,
# or read the comments in this file.
#
# After running:
#   exec zsh               — start a fresh shell with all the goodies
#   install-pipx-tools.sh  — install Python tools not in nixpkgs
# =============================================================================

set -uo pipefail

# ── Colours ────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

info()  { echo -e "${GREEN}[+]${NC} $*"; }
warn()  { echo -e "${YELLOW}[!]${NC} $*"; }
fail_msg() { echo -e "${RED}[-]${NC} $*"; }

# Track whether we hit any errors
SETUP_FAILED=0

# ── Banner ─────────────────────────────────────────────────────────────────
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
echo -e "  ${DIM}/// Jacking in — first-time system initialisation ///${NC}"
echo -e "  ${DIM}\"The matrix has its roots in primitive arcade games.\"${NC}"
echo -e "  ${DIM}                              — William Gibson${NC}"
echo ""

# ── Resolve IceBreaker root directory ──────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLAKE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Sanity check: make sure we're in the IceBreaker repo
if [[ ! -f "$FLAKE_DIR/flake.nix" ]]; then
  fail_msg "Cannot find flake.nix in $FLAKE_DIR"
  fail_msg "Are you running this from ~/IceBreaker/scripts/?"
  exit 1
fi

info "IceBreaker directory: $FLAKE_DIR"
echo ""

# ==========================================================================
# Step 1: Copy hardware-configuration.nix
# ==========================================================================
echo -e "${BOLD}─── Step 1/5: Hardware configuration ───${NC}"
HW_SRC="/etc/nixos/hardware-configuration.nix"
HW_DST="$FLAKE_DIR/hardware-configuration.nix"

if [[ -f "$HW_DST" ]]; then
  # Already exists in IceBreaker
  if [[ -f "$HW_SRC" ]]; then
    if diff -q "$HW_SRC" "$HW_DST" > /dev/null 2>&1; then
      info "hardware-configuration.nix already present and matches /etc/nixos/"
    else
      warn "hardware-configuration.nix exists but differs from /etc/nixos/ version"
      warn "Backing up current version to hardware-configuration.nix.bak"
      cp "$HW_DST" "$HW_DST.bak"
      info "Copying fresh version from /etc/nixos/..."
      sudo cp "$HW_SRC" "$HW_DST"
      sudo chown "$(id -u):$(id -g)" "$HW_DST"
      info "Updated hardware-configuration.nix"
    fi
  else
    info "hardware-configuration.nix already present (no /etc/nixos/ source found)"
  fi
elif [[ -f "$HW_SRC" ]]; then
  info "Copying hardware-configuration.nix from /etc/nixos/..."
  sudo cp "$HW_SRC" "$HW_DST"
  sudo chown "$(id -u):$(id -g)" "$HW_DST"
  info "Copied to $HW_DST"
else
  # Neither exists — generate it
  warn "No hardware-configuration.nix found anywhere!"
  info "Generating one with nixos-generate-config..."
  sudo nixos-generate-config --show-hardware-config > "$HW_DST" 2>/dev/null \
    || sudo nixos-generate-config --dir /tmp/nixos-hwconfig \
    && sudo cp /tmp/nixos-hwconfig/hardware-configuration.nix "$HW_DST" \
    && sudo chown "$(id -u):$(id -g)" "$HW_DST"
  if [[ -f "$HW_DST" ]]; then
    info "Generated hardware-configuration.nix"
  else
    fail_msg "Could not generate hardware-configuration.nix!"
    fail_msg "You will need to copy it manually (see manual steps below)"
    SETUP_FAILED=1
  fi
fi

# Nix flakes only include git-tracked files. hardware-configuration.nix is
# gitignored (machine-specific), so we must force-stage it for Nix to see it.
# It won't be committed/pushed (gitignore still blocks commits), but staged
# files ARE included in flake source evaluation.
if [[ -f "$HW_DST" ]]; then
  cd "$FLAKE_DIR"
  git add -f hardware-configuration.nix 2>/dev/null \
    && info "Staged hardware-configuration.nix for Nix flake evaluation" \
    || warn "Could not git-add hardware-configuration.nix (is this a git repo?)"
fi
echo ""

# ==========================================================================
# Step 2: Make scripts executable
# ==========================================================================
echo -e "${BOLD}─── Step 2/5: Script permissions ───${NC}"
chmod +x "$SCRIPT_DIR"/*.sh 2>/dev/null || true
info "All scripts in scripts/ are now executable"
echo ""

# ==========================================================================
# Step 3: Create user directories
# ==========================================================================
echo -e "${BOLD}─── Step 3/5: Create user directories ───${NC}"
mkdir -p "$HOME/targets" "$HOME/ctf" "$HOME/vpn"
info "Created ~/targets, ~/ctf, ~/vpn"
echo ""

# ==========================================================================
# Step 4: Update flake inputs
# ==========================================================================
# On a fresh NixOS install, flakes are NOT enabled yet. The /etc/nix/nix.conf
# is a read-only symlink managed by the Nix store — you CANNOT edit it.
#
# Instead, we pass --extra-experimental-features to the nix command itself.
# After the first successful rebuild, nix-helpers.nix permanently enables
# flakes via nix.settings.experimental-features.
# ==========================================================================
echo -e "${BOLD}─── Step 4/5: Update flake inputs ───${NC}"
cd "$FLAKE_DIR"
info "Running nix flake update in $FLAKE_DIR..."
info "(Using --extra-experimental-features for bootstrap — flakes may not be enabled yet)"

if nix --extra-experimental-features 'nix-command flakes' flake update; then
  info "Flake inputs updated"
else
  fail_msg "nix flake update failed!"
  fail_msg "Check your internet connection and try again"
  SETUP_FAILED=1
fi
echo ""

# ==========================================================================
# Step 5: Rebuild system
# ==========================================================================
# IMPORTANT: nixos-rebuild does NOT support --extra-experimental-features.
# That flag is only for the `nix` CLI. nixos-rebuild uses --option instead:
#   --option extra-experimental-features "nix-command flakes"
#
# After this rebuild completes, flakes are permanently enabled system-wide
# (set in modules/system/nix-helpers.nix via nix.settings.experimental-features).
# ==========================================================================
echo -e "${BOLD}─── Step 5/5: Rebuild NixOS system ───${NC}"
info "Building and switching to IceBreaker configuration..."
info "This may take a while on first run (downloading packages)..."
echo ""

if sudo nixos-rebuild switch \
  --flake "$FLAKE_DIR#icebreaker" \
  --option extra-experimental-features "nix-command flakes"; then
  echo ""
  info "System rebuild complete!"
else
  echo ""
  fail_msg "System rebuild FAILED!"
  fail_msg "Check the error output above and see manual steps below"
  SETUP_FAILED=1
fi
echo ""

# ==========================================================================
# Post-install: pipx tools
# ==========================================================================
if [[ -x "$SCRIPT_DIR/install-pipx-tools.sh" ]]; then
  echo -e "${BOLD}─── Optional: pipx tools ───${NC}"
  echo ""
  echo -e "  Some tools aren't in nixpkgs and need pipx."
  echo -e "  Run this now or later:"
  echo -e "    ${BOLD}~/IceBreaker/scripts/install-pipx-tools.sh${NC}"
  echo ""
fi

# ==========================================================================
# Result
# ==========================================================================
if [[ "$SETUP_FAILED" -eq 0 ]]; then
  echo -e "${GREEN}╔══════════════════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║  ${BOLD}Connection established. Welcome to the matrix.${NC}      ${GREEN}║${NC}"
  echo -e "${GREEN}╚══════════════════════════════════════════════════════╝${NC}"
  echo ""
  echo ""
  echo -e "  ${YELLOW}╔══════════════════════════════════════════════════════╗${NC}"
  echo -e "  ${YELLOW}║  ${BOLD}IMPORTANT: Default login credentials${NC}               ${YELLOW}║${NC}"
  echo -e "  ${YELLOW}╠══════════════════════════════════════════════════════╣${NC}"
  echo -e "  ${YELLOW}║${NC}  Username: ${BOLD}archangel${NC}                                ${YELLOW}║${NC}"
  echo -e "  ${YELLOW}║${NC}  Password: ${BOLD}icebreaker${NC}                               ${YELLOW}║${NC}"
  echo -e "  ${YELLOW}║${NC}                                                      ${YELLOW}║${NC}"
  echo -e "  ${YELLOW}║${NC}  ${RED}Change the password after first login:${NC}              ${YELLOW}║${NC}"
  echo -e "  ${YELLOW}║${NC}    ${BOLD}passwd${NC}                                            ${YELLOW}║${NC}"
  echo -e "  ${YELLOW}╚══════════════════════════════════════════════════════╝${NC}"
  echo ""
  echo "  Next steps:"
  echo ""
  echo -e "  ${GREEN}1.${NC} ${BOLD}Reboot${NC} the system"
  echo -e "  ${GREEN}2.${NC} Log in as ${BOLD}archangel${NC} with password ${BOLD}icebreaker${NC}"
  echo -e "  ${GREEN}3.${NC} Open a terminal and run: ${BOLD}passwd${NC}  (change your password!)"
  echo -e "  ${GREEN}4.${NC} Start a new shell:  ${BOLD}exec zsh${NC}"
  echo -e "  ${GREEN}5.${NC} Install pipx tools: ${BOLD}~/IceBreaker/scripts/install-pipx-tools.sh${NC}"
  echo -e "  ${GREEN}6.${NC} Read the guide:     ${BOLD}guide${NC}"
  echo -e "  ${GREEN}7.${NC} Place VPN configs:  ${BOLD}~/vpn/htb.ovpn${NC} and ${BOLD}~/vpn/thm.ovpn${NC}"

  echo ""
  echo "  For HTB/CTF workflow:"
  echo -e "    ${BOLD}newbox boxname 10.10.10.1${NC}   Create target scaffold"
  echo -e "    ${BOLD}htb-tmux${NC}                    Launch tmux layout"
  echo -e "    ${BOLD}revshell bash${NC}               Generate reverse shell"
  echo ""
else
  # ======================================================================
  # MANUAL SETUP — if the script failed, show the user how to do it by hand
  # ======================================================================
  echo ""
  echo -e "${RED}╔══════════════════════════════════════════════════════╗${NC}"
  echo -e "${RED}║  ${BOLD}Setup encountered errors. See manual steps below.${NC}  ${RED}║${NC}"
  echo -e "${RED}╚══════════════════════════════════════════════════════╝${NC}"
  echo ""
  echo -e "${BOLD}═══ MANUAL SETUP STEPS ═══${NC}"
  echo ""
  echo -e "${BOLD}Step 1: Copy hardware-configuration.nix${NC}"
  echo "  If ~/IceBreaker/hardware-configuration.nix does not exist:"
  echo ""
  echo -e "    ${BOLD}sudo cp /etc/nixos/hardware-configuration.nix ~/IceBreaker/${NC}"
  echo -e "    ${BOLD}sudo chown \$(id -u):\$(id -g) ~/IceBreaker/hardware-configuration.nix${NC}"
  echo ""
  echo "  If /etc/nixos/hardware-configuration.nix also doesn't exist:"
  echo ""
  echo -e "    ${BOLD}sudo nixos-generate-config --show-hardware-config > ~/IceBreaker/hardware-configuration.nix${NC}"
  echo ""
  echo -e "${BOLD}Step 2: Update the flake inputs${NC}"
  echo "  (The --extra-experimental-features flag is needed on fresh NixOS"
  echo "   because flakes are not enabled yet — /etc/nix/nix.conf is read-only)"
  echo ""
  echo -e "    ${BOLD}cd ~/IceBreaker${NC}"
  echo -e "    ${BOLD}nix --extra-experimental-features 'nix-command flakes' flake update${NC}"
  echo ""
  echo -e "${BOLD}Step 3: Rebuild the system${NC}"
  echo "  (nixos-rebuild uses --option, NOT --extra-experimental-features)"
  echo ""
  echo -e "    ${BOLD}sudo nixos-rebuild switch --flake ~/IceBreaker#icebreaker --option extra-experimental-features 'nix-command flakes'${NC}"
  echo ""
  echo "  If the rebuild fails with a package error, read the error message —"
  echo "  it usually tells you which package doesn't exist. Comment it out"
  echo "  in the relevant modules/pentesting/*.nix file and try again."
  echo ""
  echo -e "${BOLD}Step 4: Start a new shell${NC}"
  echo ""
  echo -e "    ${BOLD}exec zsh${NC}"
  echo ""
  echo -e "${BOLD}Step 5: (Optional) Install pipx tools${NC}"
  echo ""
  echo -e "    ${BOLD}~/IceBreaker/scripts/install-pipx-tools.sh${NC}"
  echo ""
  echo "  After the first successful rebuild, flakes are permanently enabled"
  echo "  and you can use 'nrs' (alias for nh os switch ~/IceBreaker) for"
  echo "  all future rebuilds without any extra flags."
  echo ""
fi
