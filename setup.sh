#!/usr/bin/env bash
# IceBreaker — Initial flake setup
# Run once after cloning / moving this directory.
set -e

FLAKE_DIR="$(cd "$(dirname "$0")" && pwd)"
USERNAME="archangel"

echo "=== IceBreaker Flake Setup ==="
echo "Flake directory: $FLAKE_DIR"
echo ""

# ── 1. Enable flakes if not already ────────────────────────────
echo "Step 1: Enabling Nix flakes..."
if ! grep -q "experimental-features" /etc/nix/nix.conf 2>/dev/null; then
    echo "  Adding flakes to /etc/nix/nix.conf..."
    echo 'experimental-features = nix-command flakes' | sudo tee -a /etc/nix/nix.conf
fi
echo "  ✓ Flakes enabled"

# ── 2. Generate flake.lock ──────────────────────────────────────
echo ""
echo "Step 2: Fetching flake inputs (this downloads nixpkgs & home-manager)..."
cd "$FLAKE_DIR"
nix flake update
echo "  ✓ flake.lock generated"

# ── 3. Build and switch ─────────────────────────────────────────
echo ""
echo "Step 3: Building NixOS configuration..."
echo "  This may take a while on first run (large downloads)."
echo ""
sudo nixos-rebuild switch --flake "${FLAKE_DIR}#icebreaker"

echo ""
echo "=== Setup Complete! ==="
echo ""
echo "Quick reference:"
echo "  nrs          — rebuild & switch system (alias, from any dir)"
echo "  hms          — rebuild home-manager config"
echo "  nfu          — update all flake inputs"
echo "  nhc          — garbage collect old generations"
echo ""
echo "Pentesting categories (edit configuration.nix to enable):"
echo "  network, web, password          — enabled by default"
echo "  activeDirectory, wireless       — disabled (enable per engagement)"
echo "  forensics, reverseEngineering   — disabled"
echo "  mitm                            — disabled"
echo ""
echo "VPN files → ~/vpn/htb.ovpn  ~/vpn/thm.ovpn"
echo "Then: htb   or   thm"
echo ""
