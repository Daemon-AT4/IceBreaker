<div align="center">

<!-- ════════════════════════════════════════════════════════════════════════ -->
<!--  I C E B R E A K E R   //   U P L I N K                                  -->
<!-- ════════════════════════════════════════════════════════════════════════ -->

```
▓▒░ ─── I C E B R E A K E R  //  U P L I N K ─── ░▒▓
```

<p align="center">
  <img src="https://img.shields.io/badge/SECTION-02_of_11-c4a7e7?style=for-the-badge&labelColor=191724"/>
  <img src="https://img.shields.io/badge/GIT-uplink-c4a7e7?style=for-the-badge&labelColor=191724"/>
  <a href="README.md"><img src="https://img.shields.io/badge/%E2%86%A9_docs_index-9ccfd8?style=for-the-badge&labelColor=191724"/></a>
  <a href="../README.md"><img src="https://img.shields.io/badge/%E2%86%A9_main_README-eb6f92?style=for-the-badge&labelColor=191724"/></a>
</p>

</div>

<div align="center">
  <img src="images/graphics/icebreaker-dividers/divider-d-minimal-phosphor.png" width="100%"/>
</div>

```
 ┌─────────────────────────────────────────────────────────┐
 │  ICEBREAKER // NEURAL BACKUP & RESTORE                  │
 │  "A year here and he still dreamed of cyberspace."      │
 │                                        — Neuromancer    │
 └─────────────────────────────────────────────────────────┘
```

# GitHub Setup

How to upload IceBreaker to GitHub and rebuild it on any NixOS machine.

## Uploading to GitHub

### 1. Create the Repository

Go to [github.com/new](https://github.com/new) and create a new repository:
- **Name:** `icebreaker` (or whatever you prefer)
- **Visibility:** Private (recommended — your config contains system details)
- **Don't** initialise with README/license/gitignore (the repo already has content)

### 2. Initialise Git (if not already)

```bash
cd ~/IceBreaker
git init
git branch -M main
```

### 3. Create a .gitignore

The flake already tracks most files. Add a `.gitignore` to exclude generated files:

```bash
cat > .gitignore << 'EOF'
# Nix build results
result
result-*

# Editor backups
*~
*.swp
*.swo
.vscode/
.idea/

# Secrets (NEVER commit these)
*.ovpn
*.pem
*.key
secrets/

# OS files
.DS_Store
Thumbs.db
EOF
```

### 4. Commit and Push

```bash
git add .
git commit -m "Initial commit — IceBreaker pentesting flake"
git remote add origin git@github.com:YOUR_USERNAME/icebreaker.git
git push -u origin main
```

### 5. Ongoing Workflow

After making changes:

```bash
# Test first
nfc                    # Check for evaluation errors
nrs                    # Rebuild to verify it works

# Then commit
cd ~/IceBreaker
git add -A
git commit -m "Add cloud category, update aliases"
git push
```

## Rebuilding from GitHub

### On a Fresh NixOS Machine

```bash
# 1. Install git (temporary)
nix-shell -p git

# 2. Clone your repo
git clone git@github.com:YOUR_USERNAME/icebreaker.git ~/IceBreaker

# 3. Generate hardware config for THIS machine
sudo nixos-generate-config --show-hardware-config > ~/IceBreaker/hardware-configuration.nix

# 4. Run setup
cd ~/IceBreaker
./scripts/setup.sh

# 5. New shell + pipx tools
exec zsh
~/IceBreaker/scripts/install-pipx-tools.sh
```

That's it. Your entire pentesting environment is restored.

### On an Existing NixOS Machine

If you already have NixOS running and just want to apply the IceBreaker config:

```bash
git clone git@github.com:YOUR_USERNAME/icebreaker.git ~/IceBreaker
cd ~/IceBreaker

# Generate hardware config
sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix

# Build directly
sudo nixos-rebuild switch --flake .#icebreaker

exec zsh
```

### Rebuilding from a Specific Commit

```bash
# Roll back to a known-good state
cd ~/IceBreaker
git log --oneline          # Find the commit
git checkout abc1234       # Check out that commit
sudo nixos-rebuild switch --flake .#icebreaker

# Go back to latest
git checkout main
```

## SSH Key Setup for GitHub

If you don't have SSH keys set up:

```bash
# Generate a key
ssh-keygen -t ed25519 -C "your_email@example.com"

# Start the agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Copy the public key
cat ~/.ssh/id_ed25519.pub
```

Go to [GitHub Settings > SSH Keys](https://github.com/settings/keys) and add it.

Test the connection:

```bash
ssh -T git@github.com
# Should say: "Hi USERNAME! You've successfully authenticated"
```

## Using HTTPS Instead of SSH

If you prefer HTTPS:

```bash
git remote set-url origin https://github.com/YOUR_USERNAME/icebreaker.git
```

You'll need a [Personal Access Token](https://github.com/settings/tokens) for authentication. GitHub no longer accepts passwords.

## What NOT to Commit

Never commit:
- **VPN configs** (`*.ovpn`) — contain your HTB/THM credentials
- **SSH private keys** (`~/.ssh/id_*`)
- **API keys or tokens** — Shodan, cloud provider creds
- **Target data** — `~/targets/` engagement files

The `.gitignore` above handles most of this, but always check `git status` before committing.

## Keeping Multiple Machines in Sync

If you use IceBreaker on multiple VMs:

```bash
# On machine A (after making changes)
git add -A && git commit -m "Updated config" && git push

# On machine B
cd ~/IceBreaker
git pull
nrs
```

### Machine-Specific Hardware Config

`hardware-configuration.nix` is different per machine. Options:

**Option A: Don't commit it.** Add to `.gitignore` and generate fresh on each machine:
```bash
echo "hardware-configuration.nix" >> .gitignore
```

**Option B: Use host-specific configs.** Rename per machine:
```
hardware-desktop.nix
hardware-laptop.nix
hardware-vm.nix
```
And import the right one in `configuration.nix`.

## Flake Lock File

`flake.lock` pins exact versions of all inputs (nixpkgs, home-manager, stylix). This is **good** — it means:
- Your build is reproducible (same lock = same packages)
- `git clone` on another machine gets the exact same versions

To update inputs:
```bash
nfu    # nix flake update — updates all inputs
nrs    # Rebuild with new versions
git add flake.lock && git commit -m "Update flake inputs"
git push
```

## Remote Rebuild (Advanced)

You can rebuild a remote machine directly:

```bash
# From your local machine, rebuild a remote NixOS box
nixos-rebuild switch --flake .#icebreaker --target-host user@remote-ip --use-remote-sudo
```

This pushes your config to the remote machine and rebuilds it there.
