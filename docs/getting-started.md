<div align="center">

<!-- ════════════════════════════════════════════════════════════════════════ -->
<!--  I C E B R E A K E R   //   B O O T   S E Q U E N C E                    -->
<!-- ════════════════════════════════════════════════════════════════════════ -->

```
▓▒░ ─── I C E B R E A K E R  //  B O O T   S E Q U E N C E ─── ░▒▓
```

<p align="center">
  <img src="https://img.shields.io/badge/SECTION-01_of_11-c4a7e7?style=for-the-badge&labelColor=191724"/>
  <img src="https://img.shields.io/badge/INSTALL-boot_sequence-c4a7e7?style=for-the-badge&labelColor=191724"/>
  <a href="README.md"><img src="https://img.shields.io/badge/%E2%86%A9_docs_index-9ccfd8?style=for-the-badge&labelColor=191724"/></a>
  <a href="../README.md"><img src="https://img.shields.io/badge/%E2%86%A9_main_README-eb6f92?style=for-the-badge&labelColor=191724"/></a>
</p>

</div>

---

```
 ┌─────────────────────────────────────────────────────────┐
 │  ICEBREAKER // INITIALIZATION PROTOCOL                  │
 │  "The future is already here — it's just not evenly     │
 │   distributed."  — William Gibson                       │
 └─────────────────────────────────────────────────────────┘
```

# Getting Started

This guide walks you through setting up IceBreaker from scratch on a fresh NixOS installation, or deploying it on an existing system.

## Prerequisites

- A NixOS installation (any channel — the flake pins nixos-unstable)
- x86_64-linux or aarch64-linux
- Internet connection
- At least 20 GB free disk space (50 GB+ for `full` preset)

## Fresh Install

### 1. Install NixOS

Use the standard NixOS installer. Minimal or graphical — doesn't matter. IceBreaker replaces the desktop entirely with XFCE.

During installation:
- Choose any username — IceBreaker creates its own user (`archangel`) unless you edit the config
- Use GRUB as bootloader on `/dev/sda` (or update `boot.loader.grub.device` in `base.nix`)
- Enable networking

### 2. Clone the Repository

```bash
# If git isn't installed yet
nix-shell -p git

# Clone
git clone https://github.com/YOUR_USERNAME/IceBreaker.git ~/IceBreaker
cd ~/IceBreaker
```

### 3. Pre-Flight Checks

**Username:** IceBreaker defaults to user `archangel` with password `icebreaker`. If you want a different username, edit these files before running setup:
- `modules/system/base.nix` — `users.users.archangel`
- `modules/system/nix-helpers.nix` — `trusted-users`
- `home/default.nix` — `home.username`, `home.homeDirectory`, git settings
- `flake.nix` — `users.archangel`

**Hypervisor:** VMware is the default. For QEMU/KVM or VirtualBox, edit `modules/system/base.nix` — comment out the VMware line and uncomment the correct block.

**Bootloader:** Default is GRUB MBR on `/dev/sda`. For UEFI, replace the GRUB block with `boot.loader.systemd-boot` in `base.nix`.

### 4. Run Setup

```bash
cd ~/IceBreaker
./scripts/setup.sh
```

This handles everything:
- Copies `hardware-configuration.nix` from `/etc/nixos/` into `~/IceBreaker/`
- Makes all scripts executable
- Creates `~/targets`, `~/ctf`, `~/vpn` directories
- Updates flake inputs (bootstraps flakes on fresh NixOS automatically)
- Rebuilds the entire NixOS system

> **Note:** The first rebuild downloads the entire package set and can take 20–60 minutes. This is normal.

### 5. Reboot and Log In

```bash
sudo reboot
```

At the LightDM login screen:
- Username: `archangel` (or your custom username)
- Password: `icebreaker`

**Immediately change your password:**

```bash
passwd
```

### 6. Start Your New Shell

```bash
exec zsh
```

You should see the Powerlevel10k prompt with Rose Pine colours and a powerline style.

### 7. Install Pipx Tools

```bash
~/IceBreaker/scripts/install-pipx-tools.sh
```

These are Python/Ruby pentesting tools that are broken or missing in nixpkgs.

### 8. Read the Guide

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

## Adding & Removing Packages

To add a package, open the relevant `.nix` file, add the package name to the list, and run `nrs`. To remove one, delete or comment out the line and rebuild. See [Customisation](customisation.md) for the full guide.

```bash
# Search for a package
ns my-tool

# Try a package without installing
nrun my-tool
```

## Directory Layout

After setup, your home directory will have:

```
~/IceBreaker/     <<< the flake (all your config)
~/targets/        <<< engagement directories (created by newbox)
~/ctf/            <<< CTF work
~/vpn/            <<< VPN configs (htb.ovpn, thm.ovpn)
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

See the main [README](../README.md) section [05] for detailed manual recovery steps.

## Next Steps

- [Engagement Workflow](workflow.md) — How to use IceBreaker for a box
- [Aliases Reference](aliases.md) — All 50+ aliases
- [Shell Functions](shell-functions.md) — Target management, nmap wrappers
- [Customisation](customisation.md) — Add packages, create categories, change theme
