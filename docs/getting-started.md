```
 ┌─────────────────────────────────────────────────────────┐
 │  ICEBREAKER // INITIALIZATION PROTOCOL                  │
 │  "The future is already here — it's just not evenly     │
 │   distributed."  — William Gibson                       │
 └─────────────────────────────────────────────────────────┘
```

# Getting Started

This guide walks you through setting up IceBreaker from scratch on a fresh NixOS installation, or rebuilding it on an existing system.

## Prerequisites

- A NixOS installation (any channel — the flake pins nixos-unstable)
- x86_64-linux architecture
- Internet connection
- At least 20GB free disk space (full preset needs more)

## Fresh Install

### 1. Install NixOS

Use the standard NixOS installer. Minimal or graphical — doesn't matter. IceBreaker will configure everything.

During installation:
- Create a user called `archangel` (or change `users.users.archangel` in `base.nix`)
- Use GRUB as bootloader on `/dev/sda` (or update `base.nix`)
- Enable networking

### 2. Clone the Repository

```bash
# If git isn't installed yet
nix-shell -p git

# Clone
git clone https://github.com/YOUR_USERNAME/icebreaker.git ~/IceBreaker
cd ~/IceBreaker
```

### 3. Generate Hardware Configuration

Every machine has different hardware. Generate yours:

```bash
sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
```

This replaces the included `hardware-configuration.nix` with one matching your actual hardware.

### 4. Run Setup

```bash
./scripts/setup.sh
```

This will:
- Enable Nix flakes if not already enabled
- Make all scripts executable
- Create `~/targets`, `~/ctf`, `~/vpn` directories
- Update flake inputs
- Rebuild the system

### 5. Start Your New Shell

```bash
exec zsh
```

You should see the Powerlevel10k prompt with Rose Pine colours.

### 6. Install Pipx Tools

```bash
~/IceBreaker/scripts/install-pipx-tools.sh
```

These are Python/Ruby pentesting tools that are broken or missing in nixpkgs.

### 7. Read the Guide

```bash
guide
```

Interactive walkthrough of everything IceBreaker provides.

## Choosing Your Tools

By default, only `network`, `web`, and `password` categories are enabled. To change this, edit `configuration.nix`:

```nix
# Option 1: Toggle individual categories
pentesting.categories = {
  network          = true;
  web              = true;
  activeDirectory  = true;   # <- enable this
  password         = true;
  cloud            = true;   # <- and this
  # ...
};

# Option 2: Use a preset
pentesting.preset = "engagement";  # enables 8 categories at once
```

Then rebuild:

```bash
nrs
```

See [Categories & Presets](categories.md) for full details.

## Directory Layout

After setup, your home directory will have:

```
~/IceBreaker/     <- The flake (all your config)
~/targets/        <- Engagement directories (created by newbox)
~/ctf/            <- CTF work
~/vpn/            <- VPN configs (htb.ovpn, thm.ovpn)
```

## VPN Setup

Place your VPN config files in `~/vpn/`:

```bash
# Download from HackTheBox/TryHackMe and save as:
~/vpn/htb.ovpn
~/vpn/thm.ovpn
```

Then connect with:

```bash
htb     # Connect to HackTheBox
thm     # Connect to TryHackMe
vpnstop # Disconnect
```

## Updating

```bash
nfu    # Update all flake inputs (nixpkgs, home-manager, stylix)
nrs    # Rebuild with updated packages
```

To update only one input:

```bash
cd ~/IceBreaker
nix flake update stylix   # Update just stylix
nrs
```

## What If Something Breaks?

NixOS creates a new "generation" on every rebuild. If a rebuild breaks something:

1. Reboot
2. In the GRUB menu, select a previous generation
3. Fix the config
4. Run `nrs` again

You can also check generations:

```bash
ngen   # List all generations
nhc    # Garbage collect, keep 3 most recent
```

## Next Steps

- [Engagement Workflow](workflow.md) — How to use IceBreaker for a box
- [Aliases Reference](aliases.md) — All 50+ aliases
- [Shell Functions](shell-functions.md) — Target management, nmap wrappers
- [Customisation](customisation.md) — Make it yours
