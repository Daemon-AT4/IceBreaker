```
    _______________  ____  ____  ______ ___    __ __ ______ ____
   /  _/ ____/ __ )/ __ \/ __ \/ ____//   |  / //_// ____// __ \
   / // /   / __  / /_/ / /_/ / __/  / /| | / ,<  / __/  / /_/ /
 _/ // /___/ /_/ / _, _/ ____/ /___ / ___ |/ /| |/ /___ / _, _/
/___/\____/_____/_/ |_/_/   /_____//_/  |_/_/ |_/_____//_/ |_|

  ///  N I X O S   P E N T E S T I N G   E N V I R O N M E N T  ///
  -------------------------------------------------------------------
   "The sky above the port was the colour of television,
    tuned to a dead channel."  — William Gibson, Neuromancer
```

# IceBreaker

A fully modular NixOS pentesting environment built as a Nix flake. Your entire workstation — tools, shell, theme, aliases, workflow automation — declared in code.

One command rebuilds everything. One `git push` backs it all up. One `git clone` restores it on any machine.

---

## Table of Contents

- [What's Inside](#whats-inside)
- [Requirements](#requirements)
- [Before You Begin](#before-you-begin)
  - [Choosing a Username](#choosing-a-username)
  - [Choosing a Hypervisor](#choosing-a-hypervisor)
- [Installation](#installation)
  - [Step 1 — Install NixOS](#step-1--install-nixos)
  - [Step 2 — Get a Shell with Git](#step-2--get-a-shell-with-git)
  - [Step 3 — Clone IceBreaker](#step-3--clone-icebreaker)
  - [Step 4 — Adjust Username (if needed)](#step-4--adjust-username-if-needed)
  - [Step 5 — Run Setup](#step-5--run-setup)
  - [Step 6 — Reboot and Log In](#step-6--reboot-and-log-in)
  - [Step 7 — Install Pipx Tools](#step-7--install-pipx-tools)
  - [Step 8 — Read the Guide](#step-8--read-the-guide)
- [Building Directly from GitHub](#building-directly-from-github)
- [If the Setup Script Fails](#if-the-setup-script-fails)
- [Daily Usage](#daily-usage)
- [Categories & Presets](#categories--presets)
- [Architecture](#architecture)
- [Troubleshooting](#troubleshooting)
- [Documentation](#documentation)

---

## What's Inside

- **12 pentesting categories** — toggle on/off individually or use presets
- **Preset system** — `ctf`, `engagement`, `full`, `blue` profiles
- **50+ shell aliases** — nix helpers, nmap presets, listeners, VPN shortcuts
- **9 ZSH functions** — target management, nmap wrappers, hashcat reference, proxy config
- **Reverse shell generator** — 14 payload types, auto-uses your VPN IP
- **HTB tmux layout** — 3-pane workspace with notes + listener pane
- **Rose Pine dark theme** — system-wide via Stylix (terminal, GTK, apps)
- **Powerlevel10k prompt** — powerline style with VPN IP + ping latency segments
- **Alacritty terminal** — fully configured, Nerd Font, Rose Pine colours
- **Pipx installer script** — 25+ Python tools not in nixpkgs
- **Multi-arch** — x86_64-linux and aarch64-linux outputs

---

## Requirements

- A NixOS installation (any starting channel — the flake pins nixos-unstable)
- x86_64-linux or aarch64-linux
- Internet connection during first build (can take 20–60 min depending on speed)
- At least **20 GB** free disk space (50 GB+ recommended for `full` preset)
- A hypervisor: VMware Workstation/Player, QEMU/KVM, VirtualBox, or bare metal

---

## Before You Begin

Read this section **before** running anything. Two decisions need to be made upfront.

### Choosing a Username

IceBreaker creates a user called **`archangel`** by default. You have two options:

**Option A — Keep `archangel` (easiest)**

Do nothing. The NixOS user `archangel` will be created automatically with the password `icebreaker`. Just make sure you log in as `archangel` after setup. If you created a different user during the NixOS install, that user won't have the IceBreaker config — log in as `archangel` instead.

**Option B — Use your own username**

If you want a different username, edit these four files **before** running `setup.sh`:

| File | What to change |
|------|----------------|
| `modules/system/base.nix` | `users.users.archangel` → `users.users.YOURNAME` |
| `modules/system/nix-helpers.nix` | `"archangel"` in `trusted-users` → `"YOURNAME"` |
| `home/default.nix` | `home.username`, `home.homeDirectory`, git `user.name` / `user.email` |
| `flake.nix` | `users.archangel` → `users.YOURNAME` |

Every occurrence of `archangel` in those files needs to become your chosen username. After setup, you must log in as that user — the config only applies to the user defined in these files.

> **Why not just use the NixOS installer username?** NixOS creates a user during install, but IceBreaker defines its own user (`archangel`) in `base.nix`. Unless you customise the username to match your install user, you'll have two separate users on the system. The IceBreaker user is the one that gets all the tooling, ZSH config, and theme.

### Choosing a Hypervisor

VMware is enabled by default because it's the most common choice for pentesting VMs. If you're using something else, open `modules/system/base.nix` and look for the "Virtualisation / VM guest support" section. Comment out the VMware line and uncomment the appropriate block:

```nix
# VMware (default — most common for pentesting)
virtualisation.vmware.guest.enable = true;

# QEMU/KVM — uncomment these and disable VMware above:
# services.qemuGuest.enable = true;
# services.spice-vdagentd.enable = true;  # only if using SPICE display

# VirtualBox — uncomment this and disable VMware above:
# virtualisation.virtualbox.guest.enable = true;
```

If you're on bare metal, set all three to `false`.

> **Note:** Auto-detection of the hypervisor is not possible in Nix flakes. Flakes use pure evaluation, which prohibits reading `/sys/` paths at eval time. The commented blocks are the correct approach.

---

## Installation

### Step 1 — Install NixOS

Download the NixOS ISO from [nixos.org](https://nixos.org/download). Either the minimal or graphical installer works — IceBreaker replaces the desktop environment entirely.

Key decisions during install:
- **Disk:** GRUB bootloader on `/dev/sda` (or update `boot.loader.grub.device` in `base.nix`)
- **User:** Either create `archangel` as your user, or plan to use Option B above
- **Desktop:** Doesn't matter — IceBreaker will replace it with XFCE

After the installer finishes and you reboot, you'll have a plain NixOS system. That's the starting point.

### Step 2 — Get a Shell with Git

On a fresh minimal NixOS install, `git` may not be available yet. Start a temporary shell with it:

```bash
nix-shell -p git
```

This drops you into a shell with `git` available without installing it permanently.

### Step 3 — Clone IceBreaker

```bash
git clone https://github.com/YOUR_USERNAME/icebreaker.git ~/IceBreaker
cd ~/IceBreaker
```

Replace `YOUR_USERNAME` with the actual GitHub username where you forked or own the repo. If you're cloning the original:

```bash
git clone https://github.com/archangel/icebreaker.git ~/IceBreaker
```

> **hardware-configuration.nix is not in the repo.** It's intentionally excluded from git (it's machine-specific). The setup script handles copying it from `/etc/nixos/` automatically — you don't need to create it manually.

### Step 4 — Adjust Username (if needed)

If you want to use a username other than `archangel`, make the four edits described in [Choosing a Username](#choosing-a-username) now, before running setup.

If you're happy with `archangel`, skip this step entirely.

### Step 5 — Run Setup

```bash
cd ~/IceBreaker
./scripts/setup.sh
```

The setup script runs six steps:

| Step | What it does |
|------|-------------|
| 1/6 | Copies `hardware-configuration.nix` from `/etc/nixos/` into `~/IceBreaker/` |
| 2/6 | Makes all scripts in `scripts/` executable |
| 3/6 | Creates `~/targets/`, `~/ctf/`, `~/vpn/` directories |
| 4/6 | Runs `nix flake update` to fetch latest package versions |
| 5/6 | Runs `sudo nixos-rebuild switch --flake ~/IceBreaker#icebreaker` to build and apply the config |

**The rebuild step (5/6) will take the longest** — on first run it downloads and builds all packages. Expect 20–60 minutes depending on your internet connection and machine speed. This is normal.

> **On the bootstrap problem:** Fresh NixOS installs don't have flakes enabled yet. The `/etc/nix/nix.conf` file is a read-only symlink into the Nix store and cannot be edited. The setup script works around this by passing `--extra-experimental-features 'nix-command flakes'` to the `nix` command and `--option extra-experimental-features 'nix-command flakes'` to `nixos-rebuild`. After the first rebuild, `nix-helpers.nix` permanently enables flakes via `nix.settings.experimental-features` — no workarounds needed for future rebuilds.

When setup completes successfully, you'll see a credentials box:

```
  ╔══════════════════════════════════════════════════════╗
  ║  IMPORTANT: Default login credentials                ║
  ╠══════════════════════════════════════════════════════╣
  ║  Username: archangel                                 ║
  ║  Password: icebreaker                                ║
  ║                                                      ║
  ║  Change the password after first login:              ║
  ║    passwd                                            ║
  ╚══════════════════════════════════════════════════════╝
```

### Step 6 — Reboot and Log In

```bash
sudo reboot
```

At the LightDM login screen:
- Username: `archangel` (or your custom username)
- Password: `icebreaker`

After logging in, open Alacritty (or the XFCE terminal) and **immediately change your password**:

```bash
passwd
```

> **If the login screen says "Failed to start session":** This means the hypervisor selection in `base.nix` doesn't match your actual hypervisor. Also verify that `services.displayManager.defaultSession = "xfce"` is set in `base.nix`. See [Troubleshooting](#troubleshooting).

### Step 7 — Install Pipx Tools

Some pentesting tools aren't packaged in nixpkgs, or were broken at the time of writing. These are installed via `pipx` (isolated Python virtualenvs) or `gem` (Ruby):

```bash
~/IceBreaker/scripts/install-pipx-tools.sh
```

This installs tools including: `impacket`, `crackmapexec`, `bloodhound-python`, `netexec`, `certipy-ad`, `mitmproxy`, `xsstrike`, `shodan`, `manspider`, `cupp`, and more.

### Step 8 — Read the Guide

```bash
guide
```

This runs `scripts/icebreaker-guide.sh` — an interactive terminal walkthrough covering everything IceBreaker provides: categories, presets, aliases, functions, scripts, and tips.

---

## Building Directly from GitHub

This is the real power of a Nix flake: your entire environment can be restored on any machine from a single `git clone`.

### On a Fresh NixOS Machine

```bash
# 1. Install NixOS normally, then get git
nix-shell -p git

# 2. Clone the repo into ~/IceBreaker
git clone https://github.com/YOUR_USERNAME/icebreaker.git ~/IceBreaker

# 3. (Optional) Edit username if you don't want to use 'archangel'
#    Edit the 4 files listed in "Before You Begin" above

# 4. Run setup — it handles hardware-configuration.nix automatically
cd ~/IceBreaker && ./scripts/setup.sh

# 5. Reboot
sudo reboot

# 6. Log in as archangel / icebreaker, open a terminal
passwd          # change your password!
exec zsh        # start the new shell (or open a new terminal)

# 7. Install pipx tools
~/IceBreaker/scripts/install-pipx-tools.sh
```

That's it. Your complete pentesting environment is running.

### On an Existing NixOS Machine (replacing the current config)

If you already have NixOS with your own config and want to switch to IceBreaker:

```bash
git clone https://github.com/YOUR_USERNAME/icebreaker.git ~/IceBreaker
cd ~/IceBreaker

# The setup script copies hardware-configuration.nix from /etc/nixos/ automatically
./scripts/setup.sh
```

### Building a Specific Target (ARM64)

If you're on an ARM64 machine (Apple Silicon via Asahi Linux, Raspberry Pi 4/5, etc.):

```bash
sudo nixos-rebuild switch --flake ~/IceBreaker#icebreaker-aarch64
```

> **Note:** Some packages (burpsuite, metasploit) may not have ARM64 binaries. If the build fails on aarch64, comment out those packages in the relevant category files.

### Keeping Multiple Machines in Sync

```bash
# Machine A — make changes, push
cd ~/IceBreaker
git add -A
git commit -m "Added evil-winrm to AD tools"
git push

# Machine B — pull and rebuild
cd ~/IceBreaker
git pull
nrs
```

---

## If the Setup Script Fails

The setup script is designed to be resilient — it tracks errors and prints full manual instructions if anything goes wrong. If you see the "Setup encountered errors" box, follow these manual steps:

### Manual Step 1 — Copy hardware-configuration.nix

```bash
# Check if it already exists
ls ~/IceBreaker/hardware-configuration.nix

# If not, copy from /etc/nixos/
sudo cp /etc/nixos/hardware-configuration.nix ~/IceBreaker/
sudo chown $(id -u):$(id -g) ~/IceBreaker/hardware-configuration.nix

# If /etc/nixos/ doesn't have it either, generate a fresh one
sudo nixos-generate-config --show-hardware-config > ~/IceBreaker/hardware-configuration.nix
```

### Manual Step 2 — Update the Flake

```bash
cd ~/IceBreaker

# The --extra-experimental-features flag is required on fresh NixOS
# because flakes aren't enabled yet — /etc/nix/nix.conf is READ-ONLY
nix --extra-experimental-features 'nix-command flakes' flake update
```

> **Why not edit `/etc/nix/nix.conf`?** On NixOS, `/etc/nix/nix.conf` is a symlink into `/nix/store/`, which is a read-only, content-addressed filesystem. Even `sudo` cannot write to it — this is by design. The only way to enable flakes permanently is via `nix.settings.experimental-features` in the NixOS config (which `nix-helpers.nix` already does), but you need flakes enabled to do the first rebuild. The `--extra-experimental-features` flag breaks this chicken-and-egg problem.

### Manual Step 3 — Rebuild the System

```bash
# IMPORTANT: nixos-rebuild uses --option, NOT --extra-experimental-features
# These are different commands with different flag syntax
sudo nixos-rebuild switch \
  --flake ~/IceBreaker#icebreaker \
  --option extra-experimental-features "nix-command flakes"
```

> **If this fails with a package error:** Read the error carefully — it will tell you which package doesn't exist in nixpkgs. Open the relevant file in `modules/pentesting/` and comment out the broken package. Then try again. Package names in nixpkgs-unstable change frequently. See the [DEVLOG](DEVLOG.md) for a running list of known naming issues.

> **If this fails with "unrecognized arguments":** Make sure you're using `--option extra-experimental-features` and NOT `--extra-experimental-features` for `nixos-rebuild`. The two commands use different flag syntax.

> **If this fails with "error: A definition for option ... is not of type":** There's a syntax or type error in a `.nix` file. The error message will include the file and option name. Fix it and retry.

### Manual Step 4 — Start the New Shell

```bash
exec zsh
```

If you get a `command not found` error, you're still in bash. Check that the rebuild completed successfully — `zsh` should now be installed.

### Manual Step 5 — Install Pipx Tools

```bash
~/IceBreaker/scripts/install-pipx-tools.sh
```

### Common Failure Causes

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| `error: unrecognized arguments: --extra-experimental-features` | Used wrong flag on `nixos-rebuild` | Use `--option extra-experimental-features` for `nixos-rebuild` |
| `error: cannot find attribute 'icebreaker'` | `flake.nix` not referencing your system correctly | Check `nixosConfigurations.icebreaker` exists in `flake.nix` |
| `error: hardware-configuration.nix: No such file` | Hardware config missing | Run `sudo nixos-generate-config --show-hardware-config > ~/IceBreaker/hardware-configuration.nix` |
| Build fails on a specific package | Package renamed or removed in nixpkgs | Comment out the package in its category `.nix` file |
| `bash: nrs: command not found` | Still in bash, not zsh | Run `exec zsh` to switch shells |
| Login screen "Failed to start session" | Missing `defaultSession` or wrong hypervisor | Add `services.displayManager.defaultSession = "xfce"` to `base.nix` |
| Black screen after login | Wrong hypervisor in `base.nix` | Set correct hypervisor option and rebuild |
| p10k prompt not showing | Not logged in as the IceBreaker user | Log in as `archangel` (or your configured username) |
| Alacritty "conflicting definitions" | You set `colors`/`font`/`opacity` in alacritty settings | Stylix manages these — remove those settings from `home/default.nix` |

### Rolling Back a Bad Rebuild

NixOS creates a "generation" (snapshot) on every rebuild. If a rebuild breaks your system:

1. Reboot the machine
2. At the GRUB menu, press a key to stop the countdown
3. Select an older generation from the list (e.g., "NixOS generation 3")
4. Log in, fix the config, then run `nrs` again

To list and manage generations from a working shell:

```bash
ngen    # list all generations
nhc     # garbage collect, keeping 3 most recent
```

---

## Daily Usage

Once IceBreaker is running, these are the most important commands:

### Rebuilding After Config Changes

```bash
nrs     # nh os switch ~/IceBreaker  — build, switch, and start using immediately
nrt     # nh os test ~/IceBreaker    — test without making it the boot default
nrb     # nh os boot ~/IceBreaker    — build and set as boot default, but don't switch yet
nfu     # nix flake update           — update all flake inputs (nixpkgs, HM, stylix)
nfc     # nix flake check            — check for evaluation errors without building
```

After every `nrs`, your running system is updated live. No reboot needed (except for kernel updates).

### Starting an Engagement

```bash
# Set up a new target
newbox boxname 10.10.10.1      # Creates ~/targets/boxname/ with full scaffold

# Launch tmux workspace
htb-tmux                       # 3-pane layout: terminal + notes + listener info

# Run initial nmap scans
nmap-init                      # Quick scan — saves to ./nmap/
nmap-allports                  # Full port scan
nmap-targeted <target> <ports> # Service/script scan on specific ports

# Capture flags
flag "HTB{FLAG_VALUE}" "user flag"    # Logs to ~/targets/boxname/flags.txt
cred admin Password123 ssh            # Logs to ~/targets/boxname/creds.txt
```

### VPN

```bash
htb     # Connect to HackTheBox (requires ~/vpn/htb.ovpn)
thm     # Connect to TryHackMe (requires ~/vpn/thm.ovpn)
vpnstop # Disconnect VPN
vpnip   # Show current VPN IP (tun0 → tun1)
```

### Listeners

```bash
rlisten    # nc -lvnp 4444 (rlwrap — readline-capable)
rlisten2   # nc -lvnp 4445
```

### Reverse Shells

```bash
settarget 10.10.10.1 4444    # Set target IP and listener port
revshell bash                 # Generate bash reverse shell using $LHOST/$LPORT
revshell python3              # Python3 PTY shell
revshell --list               # Show all 14 payload types
revshell --all                # Print all payloads at once
```

### Updating the System

```bash
nfu && nrs     # Update all inputs + rebuild
```

---

## Categories & Presets

Edit `configuration.nix` to toggle categories:

```nix
pentesting.categories = {
  network          = true;   # nmap, masscan, rustscan, wireshark, dns tools
  web              = true;   # burpsuite, ffuf, sqlmap, nuclei, nikto, dalfox
  activeDirectory  = false;  # bloodhound, impacket, netexec, responder
  password         = true;   # hashcat, john, hydra, seclists
  wireless         = false;  # aircrack-ng, kismet, wifite2, reaver
  forensics        = false;  # volatility3, binwalk, sleuthkit, steghide
  reverseEng       = false;  # ghidra, radare2, gdb+gef, pwntools, angr
  mitm             = false;  # bettercap, ettercap, dsniff
  blueTeam         = false;  # suricata, snort, yara, zeek, chainsaw, hayabusa
  exploitation     = true;   # metasploit, searchsploit/exploitdb
  postExploitation = false;  # chisel, ligolo-ng, proxychains, havoc, villain
  cloud            = false;  # awscli2, google-cloud-sdk, azure-cli, terraform
};
```

Or use a preset to enable a curated group in one line:

```nix
pentesting.preset = "ctf";         # network, web, password, forensics, reverseEng, exploitation
pentesting.preset = "engagement";  # network, web, activeDirectory, password, mitm, exploitation, postExploitation, cloud
pentesting.preset = "full";        # all 12 categories
pentesting.preset = "blue";        # network, forensics, blueTeam
```

Presets use `mkDefault` — individual `categories.X = false` overrides always win. You can use a preset as a base and disable specific categories:

```nix
pentesting.preset = "full";
pentesting.categories.cloud = false;      # too slow to build right now
pentesting.categories.wireless = false;   # not needed in a VM
```

Then rebuild:

```bash
nrs
```

See [docs/categories.md](docs/categories.md) for the full tool listing per category.

---

## Architecture

```
flake.nix                         ← Entry point (inputs + nixosConfigurations.icebreaker)
├── hardware-configuration.nix    ← Machine-specific, NOT in git (generated per host)
├── configuration.nix             ← Toggle pentesting categories here
│
├── modules/system/
│   ├── base.nix                  ← Boot, XFCE, LightDM, users, core packages, SUID wrappers
│   ├── nix-helpers.nix           ← Flake tooling (nh, comma, nil, nix-index, formatters)
│   └── stylix.nix                ← System-wide theming (Rose Pine dark, fonts, opacity)
│
├── modules/pentesting/
│   ├── default.nix               ← Options tree (pentesting.enable + categories.*)
│   ├── network.nix               ← nmap, masscan, rustscan, wireshark, dns tools
│   ├── web.nix                   ← burpsuite, ffuf, sqlmap, nuclei, nikto, dalfox
│   ├── active-directory.nix      ← bloodhound, impacket, netexec, responder
│   ├── password.nix              ← hashcat, john, hydra, seclists
│   ├── wireless.nix              ← aircrack-ng, kismet, wifite2, reaver
│   ├── forensics.nix             ← volatility3, binwalk, sleuthkit, steghide
│   ├── reverse-engineering.nix   ← ghidra, radare2, gdb+gef, pwntools, angr
│   ├── mitm.nix                  ← bettercap, ettercap, dsniff, responder
│   ├── blue-team.nix             ← suricata, snort, yara, zeek, chainsaw, hayabusa
│   ├── exploitation.nix          ← metasploit, exploitdb/searchsploit
│   ├── post-exploitation.nix     ← chisel, ligolo-ng, proxychains, havoc, villain
│   ├── cloud.nix                 ← awscli2, google-cloud-sdk, azure-cli, terraform
│   └── presets.nix               ← Preset system (ctf, engagement, full, blue)
│
├── home/
│   ├── default.nix               ← Home-manager root (git, tmux, alacritty, fzf, etc.)
│   ├── zsh.nix                   ← ZSH + oh-my-zsh + powerlevel10k + functions + plugins
│   ├── aliases.nix               ← 50+ aliases (nix helpers, VPN, listeners, etc.)
│   └── p10k.zsh                  ← Powerlevel10k prompt config (Rose Pine + VPN/ping segments)
│
└── scripts/
    ├── setup.sh                  ← First-time setup (handles everything)
    ├── install-pipx-tools.sh     ← Post-rebuild script for pipx/gem tools
    ├── revshell.sh               ← Reverse shell payload generator (14 types)
    ├── tmux-htb.sh               ← HTB/CTF tmux layout (3 panes)
    └── icebreaker-guide.sh       ← Interactive terminal walkthrough
```

### Key Design Decisions

**home-manager is embedded in the NixOS module** — not standalone. This means:
- `nh os switch` rebuilds both system and home-manager config together
- There is no separate `home-manager switch` step
- `hms` is an alias for `nrs` — they do the same thing

**Stylix injects into home-manager automatically** — never add it to `sharedModules`. The NixOS stylix module handles injection. Adding it again causes duplicate definition errors.

**ZSH EXTENDED_GLOB is disabled** — it makes `#` a glob operator, which breaks Nix flake refs like `~/IceBreaker#icebreaker`. Don't re-enable it.

**`hardware-configuration.nix` is gitignored** — it's machine-specific. Every machine generates its own from `/etc/nixos/hardware-configuration.nix` or `nixos-generate-config`.

---

## Troubleshooting

### Login fails — "Failed to start session"

Cause: LightDM doesn't know which session to launch.

Fix: Ensure `base.nix` contains:
```nix
services.displayManager.defaultSession = "xfce";
```

Note: This is `services.displayManager.defaultSession`, **not** `services.xserver.displayManager.defaultSession` — the option moved namespaces in recent NixOS versions.

### Black screen after login (cursor visible, no desktop)

Cause: Wrong hypervisor setting. VMware guest tools loaded on a KVM/QEMU machine (or vice versa).

Fix: Edit `modules/system/base.nix`, set the correct hypervisor block, set all others to `false`, then rebuild and reboot.

### `nrs: command not found`

Cause: You're still in bash, not zsh. Aliases are defined for zsh.

Fix:
```bash
exec zsh
```

If zsh still isn't available, the rebuild may not have completed. Rerun `setup.sh` or the manual rebuild step.

### Powerlevel10k prompt not appearing

Cause: Either you're not logged in as the IceBreaker user, or the Nerd Font isn't loaded yet.

Fix:
1. Make sure you're logged in as `archangel` (or your configured username)
2. Open Alacritty — Stylix configures it with JetBrainsMono Nerd Font automatically
3. If the font is a series of boxes/question marks, log out and back in to reload the Stylix font config

### `nix flake update` fails with "experimental feature 'flakes' is disabled"

Cause: Flakes not yet enabled (first run on fresh NixOS).

Fix: Use the bootstrap flag:
```bash
nix --extra-experimental-features 'nix-command flakes' flake update
```

After the first `nixos-rebuild switch`, flakes are permanently enabled by `nix-helpers.nix` and this flag is no longer needed.

### Package build failure during rebuild

Cause: A package was renamed, removed, or broken in nixpkgs-unstable.

Fix:
1. Read the error output — it names the failing package
2. Find it in the relevant `modules/pentesting/*.nix` file
3. Comment it out
4. Run `nrs` again
5. Check the [DEVLOG](DEVLOG.md) — common renames are documented there

### Stylix "conflicting definitions" errors

Cause: You set `colors`, `font`, or `window.opacity` in `programs.alacritty.settings` while Stylix also manages them.

Fix: Remove those settings from `home/default.nix`. Stylix owns all colour/font/opacity settings for Alacritty. Set only non-theming settings there.

### FZF colours wrong after changing theme

Cause: You set a `colors` block in `programs.fzf` while Stylix is also setting FZF colours.

Fix: Remove the `colors` block from `programs.fzf` in `home/default.nix`. Stylix handles FZF theming automatically.

### `hms` (home-manager switch) fails with "flake does not provide attribute homeConfigurations"

Cause: `hms` was set to `nh home switch`, which requires a standalone `homeConfigurations` flake output. IceBreaker uses home-manager as a NixOS module, not standalone.

Fix: `hms` in IceBreaker is the same as `nrs` — both run `nh os switch ~/IceBreaker`. Use either one.

---

## Documentation

| Guide | Description |
|-------|-------------|
| [Getting Started](docs/getting-started.md) | Installation, first rebuild, basic usage |
| [GitHub Setup](docs/github-setup.md) | Upload to GitHub, rebuild from GitHub, secrets |
| [Categories & Presets](docs/categories.md) | All 12 tool categories and preset profiles |
| [Aliases Reference](docs/aliases.md) | Complete alias listing with descriptions |
| [Shell Functions](docs/shell-functions.md) | Target management, nmap helpers, hcmode |
| [Scripts](docs/scripts.md) | revshell, tmux layout, setup, pipx installer |
| [Engagement Workflow](docs/workflow.md) | Step-by-step: box setup to flag capture |
| [Customisation](docs/customisation.md) | Add packages, create categories, change theme |
| [Theming](docs/theming.md) | Stylix, Rose Pine, fonts, prompt customisation |
| [Troubleshooting](docs/troubleshooting.md) | Common issues and fixes |
| [DEVLOG](DEVLOG.md) | Development history — issues encountered and how they were solved |

---

## License

Do whatever you want with it. Hack the planet.
