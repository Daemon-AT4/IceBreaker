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

---

## // WHAT IS THIS

A fully modular NixOS pentesting environment built as a Nix flake. Your entire workstation — every tool, alias, function, theme, and keybinding — declared in code.

One command rebuilds everything. One `git push` backs it all up. One `git clone` restores it anywhere.

```
> nrs                          # rebuild the entire system from ~/IceBreaker
> newbox target 10.10.10.1     # scaffold a new engagement
> htb-tmux                     # launch 3-pane workspace
> revshell bash                # generate a payload with your VPN IP
> flag HTB{owned} "root"       # log it
```

---

## // TABLE OF CONTENTS

```
 [00] PAYLOAD MANIFEST ................. what's inside
 [01] SYSTEM REQUIREMENTS .............. what you need
 [02] PRE-FLIGHT ....................... username + hypervisor
 [03] INSTALLATION ..................... step by step
 [04] DEPLOY FROM GITHUB ............... clone → build → hack
 [05] WHEN THINGS BREAK ................ manual recovery
 [06] DAILY OPS ........................ commands you'll use constantly
 [07] ARSENAL .......................... categories & presets
 [08] ADDING & REMOVING PACKAGES ....... make it yours
 [09] ARCHITECTURE ..................... how it's wired
 [10] TROUBLESHOOTING .................. flatline recovery
 [11] DOCUMENTATION .................... full docs index
```

---

## [00] PAYLOAD MANIFEST

```
 OFFENSIVE                              ENVIRONMENT
 ─────────────────────────────────      ─────────────────────────────────
 12 pentesting categories               Rose Pine dark — system-wide
 4 preset profiles                      Powerlevel10k powerline prompt
 14 reverse shell payload types         VPN IP + ping latency in prompt
 9 workflow shell functions             Alacritty terminal, Nerd Fonts
 50+ shell aliases                      15 tmux plugins, session persist
 25+ pipx tools                         XFCE desktop, LightDM greeter
 HTB tmux 3-pane layout                 x86_64 + aarch64 outputs
```

---

## [01] SYSTEM REQUIREMENTS

- **NixOS** — any starting channel (the flake pins `nixos-unstable`)
- **Architecture** — x86_64-linux or aarch64-linux
- **Disk** — 20 GB minimum, 50 GB+ recommended for `full` preset
- **RAM** — 4 GB minimum, 8 GB+ recommended
- **Network** — internet connection during first build (20–60 min)
- **Hypervisor** — VMware, QEMU/KVM, VirtualBox, or bare metal

---

## [02] PRE-FLIGHT

Read this **before** running anything.

### // USERNAME

IceBreaker creates a user called **`archangel`** with default password **`icebreaker`**.

**Option A — Keep `archangel` (path of least resistance)**

Do nothing. Log in as `archangel` after setup. If you created a different user during NixOS install, ignore it — `archangel` is the user that gets the full IceBreaker config.

**Option B — Use your own username**

Edit these four files **before** running setup:

| File | What to change |
|------|----------------|
| `modules/system/base.nix` | `users.users.archangel` → `users.users.YOURNAME` + `initialPassword` |
| `modules/system/nix-helpers.nix` | `"archangel"` in `trusted-users` → `"YOURNAME"` |
| `home/default.nix` | `home.username`, `home.homeDirectory`, `git user.name`, `git user.email` |
| `flake.nix` | `users.archangel` → `users.YOURNAME` |

Every occurrence of `archangel` must become your chosen username. You can search for it:

```bash
grep -rn "archangel" --include="*.nix" .
```

> IceBreaker defines its own user in `base.nix`. Unless you edit the username to match your NixOS install user, you'll have two separate accounts. The IceBreaker user is the one with all the tooling, aliases, prompt, and theme.

### // HYPERVISOR

VMware is enabled by default. If you're on something else, edit `modules/system/base.nix` — look for the virtualisation section:

```nix
# VMware (default)
virtualisation.vmware.guest.enable = true;

# QEMU/KVM — uncomment these, set VMware to false:
# services.qemuGuest.enable = true;
# services.spice-vdagentd.enable = true;  # only with SPICE display

# VirtualBox — uncomment this, set VMware to false:
# virtualisation.virtualbox.guest.enable = true;
```

Bare metal: set all to `false`.

> Auto-detection doesn't work in Nix flakes — pure evaluation prohibits reading `/sys/` paths.

### // BOOTLOADER

Default is GRUB MBR on `/dev/sda`. If you use UEFI or a different disk, edit `modules/system/base.nix`:

```nix
# MBR (default):
boot.loader.grub.device = "/dev/sda";  # change to your disk

# UEFI — replace the GRUB block with:
# boot.loader.systemd-boot.enable = true;
# boot.loader.efi.canTouchEfiVariables = true;
```

---

## [03] INSTALLATION

### Step 1 — Install NixOS

Download the ISO from [nixos.org/download](https://nixos.org/download). Minimal or graphical — doesn't matter. IceBreaker replaces the desktop entirely.

### Step 2 — Get Git

On a fresh minimal install, `git` won't be available. Drop into a temporary shell:

```bash
nix-shell -p git
```

### Step 3 — Clone IceBreaker

```bash
git clone https://github.com/YOUR_USERNAME/IceBreaker.git ~/IceBreaker
cd ~/IceBreaker
```

> `hardware-configuration.nix` is **not** in the repo — it's machine-specific and gitignored. The setup script copies yours from `/etc/nixos/` automatically.

### Step 4 — Edit Username / Hypervisor (if needed)

See [PRE-FLIGHT](#02-pre-flight). If you're keeping `archangel` and on VMware, skip this.

### Step 5 — Run Setup

```bash
cd ~/IceBreaker
./scripts/setup.sh
```

The script runs five steps:

| Step | What it does |
|------|-------------|
| 1/5 | Copies `hardware-configuration.nix` from `/etc/nixos/` |
| 2/5 | Makes all scripts in `scripts/` executable |
| 3/5 | Creates `~/targets/`, `~/ctf/`, `~/vpn/` |
| 4/5 | Runs `nix flake update` (fetches nixpkgs, home-manager, stylix) |
| 5/5 | Runs `sudo nixos-rebuild switch --flake ~/IceBreaker#icebreaker` |

Step 5 takes the longest — 20–60 minutes on first run. It's downloading the entire package set. This is normal.

> **The bootstrap problem:** Fresh NixOS doesn't have flakes enabled. `/etc/nix/nix.conf` is a read-only symlink into the Nix store — you literally cannot edit it. The setup script passes `--extra-experimental-features 'nix-command flakes'` to `nix` and `--option extra-experimental-features 'nix-command flakes'` to `nixos-rebuild` for the bootstrap. After the first rebuild, `nix-helpers.nix` permanently enables flakes and these flags are never needed again.

### Step 6 — Reboot and Log In

```bash
sudo reboot
```

At the LightDM login screen:

```
Username:  archangel
Password:  icebreaker
```

Open a terminal and **immediately change your password**:

```bash
passwd
```

> `initialPassword` only sets the password if none exists. Once you run `passwd`, it persists across rebuilds — NixOS won't overwrite it.

### Step 7 — Install Pipx Tools

Some tools aren't in nixpkgs or have broken builds. These are installed via pipx in isolated virtualenvs:

```bash
~/IceBreaker/scripts/install-pipx-tools.sh
```

### Step 8 — Read the Guide

```bash
guide
```

Interactive terminal walkthrough covering categories, aliases, functions, scripts, and tips.

---

## [04] DEPLOY FROM GITHUB

This is the real power of a Nix flake. Your entire environment — every tool, every alias, every theme colour — restores from a single `git clone`.

### // Fresh NixOS Machine

```bash
# 1. Get git
nix-shell -p git

# 2. Clone
git clone https://github.com/YOUR_USERNAME/IceBreaker.git ~/IceBreaker

# 3. (Optional) Edit username — see PRE-FLIGHT
# 4. Run setup
cd ~/IceBreaker && ./scripts/setup.sh

# 5. Reboot, log in as archangel / icebreaker
sudo reboot

# 6. Change password, start new shell, install pipx tools
passwd
exec zsh
~/IceBreaker/scripts/install-pipx-tools.sh
```

### // Existing NixOS Machine

```bash
git clone https://github.com/YOUR_USERNAME/IceBreaker.git ~/IceBreaker
cd ~/IceBreaker
./scripts/setup.sh     # copies hardware-configuration.nix from /etc/nixos/ automatically
```

### // ARM64 (aarch64)

```bash
sudo nixos-rebuild switch --flake ~/IceBreaker#icebreaker-aarch64
```

Some packages (burpsuite, metasploit) may not have ARM64 binaries — comment them out in the relevant category file if the build fails.

### // Keeping Multiple Machines in Sync

```bash
# Machine A — change config, push
cd ~/IceBreaker && git add -A && git commit -m "enabled AD tools" && git push

# Machine B — pull and rebuild
cd ~/IceBreaker && git pull && nrs
```

`hardware-configuration.nix` is gitignored — each machine generates its own. Everything else syncs.

---

## [05] WHEN THINGS BREAK

The setup script tracks errors and prints manual instructions if anything fails. If you see the red error box, follow these steps.

### // Manual Step 1 — Hardware Configuration

```bash
# Copy from /etc/nixos/
sudo cp /etc/nixos/hardware-configuration.nix ~/IceBreaker/
sudo chown $(id -u):$(id -g) ~/IceBreaker/hardware-configuration.nix

# If /etc/nixos/ doesn't have it either:
sudo nixos-generate-config --show-hardware-config > ~/IceBreaker/hardware-configuration.nix
```

### // Manual Step 2 — Update the Flake

```bash
cd ~/IceBreaker
nix --extra-experimental-features 'nix-command flakes' flake update
```

> **Why the flag?** `/etc/nix/nix.conf` on NixOS is a symlink into `/nix/store/` — a read-only, content-addressed, immutable filesystem. Even `sudo` can't write to it. This is by design. The `--extra-experimental-features` flag enables flakes for this single command. After the first rebuild, `nix-helpers.nix` enables flakes permanently.

### // Manual Step 3 — Rebuild

```bash
# CRITICAL: nixos-rebuild uses --option, NOT --extra-experimental-features
# They are DIFFERENT commands with DIFFERENT flag syntax
sudo nixos-rebuild switch \
  --flake ~/IceBreaker#icebreaker \
  --option extra-experimental-features "nix-command flakes"
```

**If it fails with a package error:** The error names the package. Find it in `modules/pentesting/*.nix`, comment it out, try again. Package names in nixpkgs-unstable change frequently — check [DEVLOG.md](DEVLOG.md) for known renames.

**If it fails with "unrecognized arguments":** You used `--extra-experimental-features` on `nixos-rebuild`. It's `--option extra-experimental-features` for that command.

### // Manual Step 4 — New Shell

```bash
exec zsh
```

### // Manual Step 5 — Pipx Tools

```bash
~/IceBreaker/scripts/install-pipx-tools.sh
```

### // Common Failures

| Symptom | Cause | Fix |
|---------|-------|-----|
| `unrecognized arguments: --extra-experimental-features` | Wrong flag on `nixos-rebuild` | Use `--option extra-experimental-features` |
| `cannot find attribute 'icebreaker'` | Flake output mismatch | Check `nixosConfigurations.icebreaker` in `flake.nix` |
| `hardware-configuration.nix: No such file` | Missing hardware config | Run `sudo nixos-generate-config --show-hardware-config > ~/IceBreaker/hardware-configuration.nix` |
| Build fails on a package | Package renamed or removed | Comment it out in `modules/pentesting/*.nix`, rebuild |
| `nrs: command not found` | Still in bash, not zsh | `exec zsh` |
| "Failed to start session" at login | Missing `defaultSession` | Add `services.displayManager.defaultSession = "xfce";` to `base.nix` |
| Black screen after login | Wrong hypervisor setting | Set correct hypervisor in `base.nix`, rebuild, reboot |
| p10k prompt missing | Not logged in as IceBreaker user | Log in as `archangel` (or your configured username) |
| Alacritty "conflicting definitions" | Manual colours/fonts set | Stylix manages colours/fonts/opacity — remove them from `home/default.nix` |

### // Rolling Back

NixOS keeps a snapshot of every rebuild. If something breaks:

1. Reboot
2. In GRUB, select a previous generation
3. Fix the config
4. `nrs`

From a working shell:

```bash
ngen    # list all generations
nhc     # garbage collect, keep 3 most recent
```

---

## [06] DAILY OPS

### // Rebuild Commands

```bash
nrs     # nh os switch ~/IceBreaker  — rebuild + switch immediately
nrt     # nh os test ~/IceBreaker    — test without boot entry
nrb     # nh os boot ~/IceBreaker    — build + boot entry, don't switch yet
nfu     # nix flake update           — update nixpkgs, home-manager, stylix
nfc     # nix flake check            — check for eval errors without building
```

After `nrs`, the running system is updated live. No reboot needed (except kernel updates).

### // Engagement Workflow

```bash
htb                                # connect VPN
newbox forest 10.10.10.161        # create target scaffold + set $TARGET/$LHOST
htb-tmux                           # 3-pane tmux layout

nmap-init                          # quick scan → ./nmap/initial
nmap-allports                      # all 65535 ports → ./nmap/allports
nmap-targeted $TARGET 88,445      # deep scan specific ports

flag "HTB{fl4g_v4lu3}" "user"     # log flag with timestamp
cred admin P@ssw0rd ssh            # log credentials

revshell bash                      # generate reverse shell with $LHOST/$LPORT
rlisten                            # nc -lvnp 4444 with readline

vpnstop                            # kill VPN when done
```

### // VPN

```bash
htb         # sudo openvpn ~/vpn/htb.ovpn
thm         # sudo openvpn ~/vpn/thm.ovpn
vpnstop     # sudo pkill openvpn
vpnip       # show tun0/tun1 IP
```

### // Updating

```bash
nfu && nrs     # update all inputs + rebuild
```

---

## [07] ARSENAL — Categories & Presets

Edit `configuration.nix` to arm your loadout:

```nix
pentesting = {
  enable = true;

  # ── Option A: Use a preset ────────────────────────
  # preset = "ctf";         # network, web, password, forensics, reverseEngineering, exploitation
  # preset = "engagement";  # network, web, AD, password, mitm, exploitation, postExploitation, cloud
  # preset = "full";        # all 12 categories
  # preset = "blue";        # network, forensics, blueTeam

  # ── Option B: Toggle individually ─────────────────
  categories = {
    network            = true;   # nmap, masscan, rustscan, wireshark, dns tools
    web                = true;   # burpsuite, ffuf, sqlmap, nuclei, nikto, dalfox
    activeDirectory    = false;  # bloodhound, impacket, netexec, responder, evil-winrm
    password           = true;   # hashcat, john, hydra, seclists
    wireless           = false;  # aircrack-ng, kismet, wifite2, reaver
    forensics          = false;  # volatility3, binwalk, sleuthkit, steghide
    reverseEngineering = false;  # ghidra, radare2, gdb+gef, pwntools, angr
    mitm               = false;  # bettercap, ettercap, dsniff
    blueTeam           = false;  # suricata, snort, yara, zeek, chainsaw, hayabusa
    exploitation       = false;  # metasploit, searchsploit/exploitdb
    postExploitation   = false;  # chisel, ligolo-ng, proxychains, havoc, villain
    cloud              = false;  # awscli2, google-cloud-sdk, azure-cli, terraform
  };
};
```

Presets use `mkDefault` — individual toggles **always** override:

```nix
# Use full preset but drop wireless and cloud
pentesting.preset = "full";
pentesting.categories.wireless = false;
pentesting.categories.cloud = false;
```

Then rebuild: `nrs`

See [docs/categories.md](docs/categories.md) for the full tool listing per category.

---

## [08] ADDING & REMOVING PACKAGES

### // Adding a Package to a Pentesting Category

Open the relevant module in `modules/pentesting/`. Example — adding `whatweb` to web tools:

```nix
# modules/pentesting/web.nix
environment.systemPackages = with pkgs; [
  # ... existing tools ...
  whatweb        # add your package here
];
```

Rebuild: `nrs`

### // Removing a Package

Same file — delete or comment out the line:

```nix
# modules/pentesting/web.nix
environment.systemPackages = with pkgs; [
  # whatweb      # commented out — not needed for this engagement
  ffuf
  sqlmap
  # ...
];
```

Rebuild: `nrs`. The package is removed from your system. NixOS doesn't leave orphans behind.

### // Adding a Package to the Base System (always installed)

Edit `modules/system/base.nix` — find the `environment.systemPackages` list and add your package:

```nix
environment.systemPackages = with pkgs; [
  # ... existing packages ...
  obsidian       # note-taking
  flameshot      # screenshots
  chromium       # browser
];
```

These are installed regardless of which pentesting categories are enabled.

### // Adding a Package via Home-Manager (user-level)

Edit `home/default.nix`:

```nix
home.packages = with pkgs; [
  # ... existing packages ...
  my-tool
];
```

Home-manager packages live in `~/.nix-profile/` instead of system-wide `/run/current-system/`. Use this for personal tools that don't need root.

### // Finding Package Names

```bash
# Search nixpkgs for a package
ns my-tool                     # alias for: nix search nixpkgs my-tool

# Check if a specific package name exists
nix eval nixpkgs#my-tool.name

# Run a package without installing it (try before you buy)
nrun my-tool                   # alias for: nix run nixpkgs#my-tool

# Find which package provides a command you need
, some-command                 # comma — finds and runs it, shows the package name
```

### // Package Name Pitfalls

nixpkgs-unstable renames things frequently. Known gotchas:

| You might try | Correct name | Notes |
|---------------|-------------|-------|
| `impacket` | `python3Packages.impacket` | Not a top-level package |
| `noto-fonts-emoji` | `noto-fonts-color-emoji` | Renamed |
| `du-dust` | `dust` | Alias is misleading |
| `snmp` | `net-snmp` | Renamed |
| `ldaputils` | `openldap` | Provides ldapsearch etc. |
| `wifite` | `wifite2` | v1 removed |
| `python3Packages.jwt` | `python3Packages.pyjwt` | jwt doesn't exist |
| `hayabusa` | `hayabusa-sec` | `hayabusa` is an unrelated package |
| `neofetch` | `fastfetch` | neofetch removed (unmaintained) |

If a package doesn't exist at all, add it to `scripts/install-pipx-tools.sh` instead (for Python tools) or install it via `nix-shell -p` on demand.

### // Creating a New Pentesting Category

**1. Create the module** — use `cloud.nix` as a template:

```nix
# modules/pentesting/my-category.nix
{ config, lib, pkgs, ... }:

with lib;

let cfg = config.pentesting; in

{
  config = mkIf (cfg.enable && cfg.categories.myCategory) {
    environment.systemPackages = with pkgs; [
      tool1
      tool2
    ];
  };
}
```

**2. Register the option** in `modules/pentesting/default.nix`:

```nix
imports = [
  # ... existing imports ...
  ./my-category.nix
];

options.pentesting.categories = {
  # ... existing options ...
  myCategory = mkEnableOption "my custom tools";
};
```

**3. Add to presets** (optional) in `modules/pentesting/presets.nix`:

```nix
(mkIf (cfg.preset == "full") {
  pentesting.categories.myCategory = mkDefault true;
})
```

**4. Add toggle** in `configuration.nix`:

```nix
pentesting.categories.myCategory = true;
```

**5. Rebuild:** `nfc && nrs`

### // Adding Aliases

Edit `home/aliases.nix`:

```nix
programs.zsh.shellAliases = {
  # ... existing aliases ...
  "myalias" = "command --flag $HOME/path";
};
```

Rules:
- Use `$HOME` not `~` in paths (tilde doesn't expand in double quotes)
- Escape special characters: `\\n` for newline
- Test the command manually before adding

### // Adding Shell Functions

Edit `home/zsh.nix`, append to the string block in `initContent`:

```nix
''
  myfunction() {
    local arg="''${1:-default}"    # ''${} is Nix escaping for ${} in shell
    echo "Working on $arg"
  }
''
```

Nix escaping rules for shell code:
- `${var}` → write as `''${var}` inside `''...''` strings
- `$VAR` (no braces) → safe as-is
- `$(command)` → safe as-is

### // Adding Pipx Tools

Edit `scripts/install-pipx-tools.sh` and add under the relevant section:

```bash
pipx_install "package-name" "Display Name"
```

---

## [09] ARCHITECTURE

```
flake.nix                         <<< entry point — inputs + nixosConfigurations
|
+-- hardware-configuration.nix    <<< machine-specific (NOT in git)
+-- configuration.nix             <<< toggle categories + presets here
|
+-- modules/system/
|   +-- base.nix                  <<< boot, XFCE, LightDM, users, core packages
|   +-- nix-helpers.nix           <<< nh, comma, nil, nix-index, formatters
|   +-- stylix.nix                <<< Rose Pine dark, fonts, opacity
|
+-- modules/pentesting/
|   +-- default.nix               <<< options tree (pentesting.enable + categories.*)
|   +-- network.nix               <<< nmap, masscan, rustscan, wireshark
|   +-- web.nix                   <<< burpsuite, ffuf, sqlmap, nuclei, nikto
|   +-- active-directory.nix      <<< bloodhound, impacket, netexec, responder
|   +-- password.nix              <<< hashcat, john, hydra, seclists
|   +-- wireless.nix              <<< aircrack-ng, kismet, wifite2, reaver
|   +-- forensics.nix             <<< volatility3, binwalk, sleuthkit, steghide
|   +-- reverse-engineering.nix   <<< ghidra, radare2, gdb+gef, pwntools, angr
|   +-- mitm.nix                  <<< bettercap, ettercap, dsniff
|   +-- blue-team.nix             <<< suricata, snort, yara, zeek, chainsaw
|   +-- exploitation.nix          <<< metasploit, exploitdb/searchsploit
|   +-- post-exploitation.nix     <<< chisel, ligolo-ng, proxychains, havoc
|   +-- cloud.nix                 <<< awscli2, gcloud, azure-cli, terraform
|   +-- presets.nix               <<< preset system (ctf, engagement, full, blue)
|
+-- home/
|   +-- default.nix               <<< home-manager: git, tmux, alacritty, fzf, bat
|   +-- zsh.nix                   <<< ZSH + oh-my-zsh + p10k + functions + plugins
|   +-- aliases.nix               <<< 50+ aliases
|   +-- p10k.zsh                  <<< powerlevel10k config (Rose Pine + VPN/ping)
|
+-- scripts/
    +-- setup.sh                  <<< first-time setup (5 steps)
    +-- install-pipx-tools.sh     <<< 25+ Python tools not in nixpkgs
    +-- revshell.sh               <<< reverse shell generator (14 types)
    +-- tmux-htb.sh               <<< 3-pane HTB tmux layout
    +-- icebreaker-guide.sh       <<< interactive terminal walkthrough
```

### // Design Decisions

**home-manager is embedded** — not standalone. `nh os switch` rebuilds system + home together. There's no separate `home-manager switch` step. `hms` and `nrs` are the same command.

**Stylix auto-injects into home-manager** — the NixOS module handles it. Never add stylix to `home-manager.sharedModules` — causes duplicate definition errors.

**EXTENDED_GLOB is disabled in ZSH** — it makes `#` a glob operator, which breaks flake refs like `~/IceBreaker#icebreaker`. Don't re-enable it.

**hardware-configuration.nix is gitignored** — it contains filesystem UUIDs and hardware specific to one machine. Each host generates its own.

**Docker is always enabled** — with auto-prune. Available regardless of pentesting categories.

---

## [10] TROUBLESHOOTING

### // "Failed to start session" at LightDM

`base.nix` needs:
```nix
services.displayManager.defaultSession = "xfce";
```
Note: this is `services.displayManager.defaultSession`, **not** `services.xserver.displayManager.defaultSession` — the option moved namespaces.

### // Black screen after login (cursor visible)

Wrong hypervisor. VMware guest tools on a KVM machine (or vice versa). Fix the hypervisor setting in `base.nix`, rebuild, reboot.

### // `nrs: command not found`

You're in bash, not zsh: `exec zsh`

### // Powerlevel10k prompt not showing

Not logged in as the IceBreaker user, or Nerd Font not loaded. Log in as `archangel`, open Alacritty (Stylix configures the font automatically). If glyphs are boxes, log out and back in.

### // `experimental feature 'flakes' is disabled`

First run — use the bootstrap flag:
```bash
nix --extra-experimental-features 'nix-command flakes' flake update
```

### // Package build failure

Package renamed or removed in nixpkgs-unstable. Read the error (it names the package), comment it out in `modules/pentesting/*.nix`, rebuild. Check [DEVLOG.md](DEVLOG.md) for known renames.

### // Stylix "conflicting definitions"

You set `colors`, `font`, or `window.opacity` in Alacritty/FZF settings while Stylix also manages them. Remove those settings — Stylix owns all theming.

### // System won't boot

Reboot → GRUB → select a previous generation → fix the config → `nrs`.

---

## [11] DOCUMENTATION

```
 docs/getting-started.md ......... installation, first rebuild, basic usage
 docs/github-setup.md ............ push to GitHub, rebuild from GitHub
 docs/categories.md .............. all 12 categories with tool tables
 docs/aliases.md ................. complete alias listing
 docs/shell-functions.md ......... settarget, newbox, flag, cred, nmap helpers
 docs/scripts.md ................. revshell, htb-tmux, setup, pipx installer
 docs/workflow.md ................ engagement workflow: box setup to flag capture
 docs/customisation.md ........... add packages, create categories, change theme
 docs/theming.md ................. Stylix, Rose Pine, fonts, prompt
 docs/troubleshooting.md ......... common issues and fixes
 DEVLOG.md ....................... development history — every bug and fix
```

---

```
 ┌──────────────────────────────────────────────────────────┐
 │  "We have no future because our present is too volatile. │
 │   We only have risk management."                         │
 │                              — William Gibson, Pattern   │
 │                                Recognition               │
 └──────────────────────────────────────────────────────────┘

 LICENSE: Do whatever you want with it. Hack the planet.
```
