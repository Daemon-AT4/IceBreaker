# IceBreaker Development Log

A record of issues encountered while building a modular NixOS pentesting flake from scratch, and how I resolved each one.

---

## Session 1 — Initial Flake Build

### 1. `programs.nmap` does not exist

**Error:** `The option 'programs.nmap' does not exist`

**Cause:** NixOS doesn't have a `programs.nmap` module option. I assumed it worked like `programs.wireshark` but nmap has no NixOS module.

**Fix:** Removed `programs.nmap.enable = true` from `base.nix`. Instead, created a SUID wrapper so nmap can do raw socket scans without sudo:
```nix
security.wrappers.nmap = {
  setuid = true;
  owner  = "root";
  group  = "root";
  source = "${pkgs.nmap}/bin/nmap";
};
```

---

### 2. Nix string interpolation conflict with `${PATH}`

**Error:** `syntax error, unexpected ':'` in aliases.nix

**Cause:** Had `"path" = "echo ${PATH//:/\\n}"` — Nix tries to interpolate `${PATH}` as a Nix variable, not a shell variable.

**Fix:** Changed the alias to avoid bash parameter expansion inside Nix strings:
```nix
"path" = "echo $PATH | tr ':' '\\n'";
```

---

### 3. Deprecated home-manager options

**Error:** Multiple deprecation errors after updating to latest home-manager on nixos-unstable.

**Affected options and fixes:**

| Deprecated | Replacement |
|-----------|-------------|
| `programs.git.userName` | `programs.git.settings.user.name` |
| `programs.git.userEmail` | `programs.git.settings.user.email` |
| `programs.git.extraConfig` | `programs.git.settings` (attrset) |
| `programs.git.delta.enable` | `programs.delta.enable` + `enableGitIntegration = true` |
| `programs.zsh.initExtraFirst` | `programs.zsh.initContent` with `lib.mkBefore` |
| `programs.zsh.initExtra` | `programs.zsh.initContent` (plain string in `lib.mkMerge`) |
| `programs.ssh.extraConfig` | `programs.ssh.matchBlocks."*".extraOptions` |

The `initContent` migration was the trickiest — p10k's instant prompt block must load before everything else, so I used:
```nix
initContent = lib.mkMerge [
  (lib.mkBefore ''# p10k instant prompt block'')
  ''# everything else''
];
```

---

### 4. Package name errors in nixpkgs-unstable

Spent a lot of time tracking down packages that had been renamed or don't exist. Built up a reference table:

| Attempted | Correct | Notes |
|-----------|---------|-------|
| `impacket` | `python3Packages.impacket` | Not a top-level package |
| `snmp` | `net-snmp` | Renamed |
| `du-dust` | `dust` | nixpkgs alias misleading |
| `noto-fonts-emoji` | `noto-fonts-color-emoji` | Renamed |
| `ldaputils` | `openldap` | Provides ldapsearch etc. |
| `wifite` | `wifite2` | v1 removed |
| `neofetch` | `fastfetch` | neofetch removed (unmaintained) |

**Packages that simply don't exist in nixpkgs:**
- `xplico` — removed entirely
- `zaproxy` / `owasp-zap` — not packaged
- `johnymacumbar` — doesn't exist
- `md5sum` / `sha256sum` — part of `coreutils`, not standalone
- `xxd` — provided by `vim`, not standalone

---

### 5. mitmproxy build failure

**Error:** `cannot build python3.13-mitmproxy` — Python dependency version conflicts

**Cause:** Upstream nixpkgs-unstable has broken mitmproxy due to conflicting Python package versions. Not something I can fix locally.

**Fix:** Commented out `mitmproxy` in both `web.nix` and `mitm.nix`. Added it to `scripts/install-pipx-tools.sh` instead — pipx installs it in an isolated virtualenv where the deps don't conflict.

---

### 6. Shell aliases not loading (`nrs: command not found`)

**Error:** After first successful rebuild, typing `nrs` returned `bash: nrs: command not found`.

**Cause:** Was still in bash, not zsh. The aliases are defined in `programs.zsh.shellAliases`. Need to either log out/in or run `exec zsh` to switch to the new shell.

**Fix:** `exec zsh` after rebuild. Also confirmed that `users.users.archangel.shell = pkgs.zsh` was set in `base.nix`.

---

### 7. Powerlevel10k parse errors

**Error:**
```
/home/archangel/.p10k.zsh:206: parse error near `}'
```
Plus cascading `url-quote-magic` errors that made the entire shell unusable.

**Cause:** The p10k config file had `} always {` as the function termination pattern, which is invalid zsh syntax. The correct pattern from `p10k configure` output is `} "$@"`.

**Fix:** Rewrote `home/p10k.zsh` using the correct anonymous function structure:
```zsh
() {
  emulate -L zsh
  setopt no_unset
  # ... config ...
} "$@"
```
The `} "$@"` terminates the anonymous function properly. The old `} always {` pattern was from an outdated template.

---

### 8. `dotDir` deprecation and null coercion

**Error sequence:**
1. Removed `dotDir` entirely → worked but threw deprecation warning
2. Set `dotDir = null` → `error: cannot coerce null to a string`
3. Set `dotDir = config.home.homeDirectory` → worked but caused issues alongside broken p10k

**Final fix:** After fixing p10k separately, settled on:
```nix
dotDir = "${config.home.homeDirectory}";
```
This silences the deprecation warning without breaking anything.

---

### 9. ZSH `EXTENDED_GLOB` breaks nix flake refs

**Error:** `nrs` and any command containing `#` failed with glob errors.

**Cause:** `setopt EXTENDED_GLOB` makes `#` a glob operator in zsh. So `~/IceBreaker#icebreaker` gets interpreted as a glob pattern instead of a flake reference.

**Fix:** Disabled `EXTENDED_GLOB` in zsh initContent:
```zsh
# NOTE: EXTENDED_GLOB makes # a glob operator which breaks nix flake refs
# (e.g. .#icebreaker). Disabled — use setopt EXTENDED_GLOB in scripts if needed.
# setopt EXTENDED_GLOB
```
Also changed all aliases to use `$HOME/IceBreaker` instead of `~/IceBreaker` — tilde doesn't expand inside double quotes.

---

### 10. `hms` alias failing (no homeConfigurations output)

**Error:**
```
error: flake does not provide attribute 'homeConfigurations'
```

**Cause:** Had `hms = "nh home switch $HOME/IceBreaker"` — but `nh home switch` expects a standalone `homeConfigurations` output in the flake. My setup uses home-manager as a NixOS module (embedded), so there's no standalone output.

**Fix:** Changed `hms` to be identical to `nrs`:
```nix
"hms" = "nh os switch $HOME/IceBreaker";
```
Since home-manager is embedded in the NixOS module, `nh os switch` rebuilds both system and home together. There's no separate home-manager rebuild step.

---

## Session 2 — Stylix Integration

### 11. Stylix flake URL moved

**Issue:** The original stylix repo at `github:danth/stylix` has moved to `github:nix-community/stylix`.

**Fix:** Updated `flake.nix`:
```nix
stylix.url = "github:nix-community/stylix";
```
Then ran `nix flake update stylix` to update the lock file.

---

### 12. Stylix double-injection error

**Error:** `stylix.base16Scheme` defined in multiple locations.

**Cause:** Added stylix to both `stylix.nixosModules.stylix` (in the NixOS modules list) AND `home-manager.sharedModules`. The NixOS stylix module automatically injects itself into home-manager — adding it to `sharedModules` causes a duplicate definition conflict.

**Fix:** Removed stylix from `home-manager.sharedModules`. The NixOS module handles injection automatically:
```nix
# In flake.nix modules list:
stylix.nixosModules.stylix  # this auto-injects into HM

# Do NOT also add to:
# home-manager.sharedModules = [ stylix.homeModules.stylix ];
```

---

### 13. `stylix.targets.fzf` does not exist

**Error:** `The option 'stylix.targets.fzf' does not exist`

**Cause:** FZF is not a stylix target. Stylix applies colours to FZF through environment variables set by the home-manager module, not through a dedicated target option.

**Fix:** Removed the entire `targets` block that referenced `fzf`. Kept only:
```nix
targets.qt.enable = false;  # KDE Plasma 6 safety
```

---

### 14. FZF colour conflict

**Error:** `programs.fzf.colors.bg` has conflicting definitions.

**Cause:** Had custom FZF colour settings in `home/default.nix` while stylix was also trying to set FZF colours through its home-manager injection.

**Fix:** Removed the custom `colors` block from `programs.fzf` in `home/default.nix`. Let stylix handle all FZF theming automatically.

---

### 15. KDE Plasma 6 + stylix `targets.qt`

**Issue:** Stylix's Qt target can cause a black screen on KDE Plasma 6 (tracked as stylix issue #1092).

**Fix:** Disabled the Qt target preemptively:
```nix
targets.qt.enable = false;
```
KDE manages its own Qt theming — letting stylix fight with it causes issues.

---

### 16. Stylix colours not applying after rebuild

**Issue:** Ran `nrs` successfully but terminal/desktop colours didn't change.

**Cause:** Multiple things need to happen:
- Terminal emulator (Konsole) needs to pick up the stylix-generated colour profile
- KDE desktop colours apply at login — need to log out and back in
- Shell needs `exec zsh` to reload

**Fix:** Log out → log back in (or reboot) for full KDE theme application. Check Konsole profile settings for the stylix/base16 theme.

---

## Lessons Learned

1. **Always verify package names before adding them.** `nix eval nixpkgs#<name>.name` is faster than waiting for a full rebuild to fail.

2. **nixpkgs-unstable moves fast.** Package renames, removals, and option deprecations happen constantly. What worked last month might not work today.

3. **home-manager as NixOS module vs standalone are different.** When embedded, there's no `homeConfigurations` flake output. `nh home switch` won't work — use `nh os switch` instead.

4. **Stylix's NixOS module auto-injects into home-manager.** Never manually add it to `sharedModules` when using the NixOS module approach.

5. **ZSH `EXTENDED_GLOB` and Nix don't mix.** The `#` character is used by both — disable `EXTENDED_GLOB` or escape everything.

6. **Test p10k configs with `source ~/.p10k.zsh`** before rebuilding. Parse errors in p10k cascade and break the entire shell.

7. **Nix string interpolation catches shell variables.** Use `$VAR` not `${VAR}` in Nix strings, or escape with `''${VAR}`.

---

---

## Session 3 — Blue Team, Presets, Powerline Prompt

### 17. Added Blue Team / DFIR category

**New file:** `modules/pentesting/blue-team.nix`

Added a 9th pentesting category for defensive security / DFIR work. Verified tools:
- IDS/IPS: `suricata`, `snort`
- Malware: `yara`, `clamav`
- Auditing: `lynis`, `aide`
- Network: `zeek`, `tcpdump`, `wireshark`
- SIEM: `sigma-cli`, `lnav`
- Windows forensics: `chainsaw`, `hayabusa-sec` (NOT `hayabusa` — that's an unrelated package)
- Memory: `volatility3`

Toggle: `pentesting.categories.blueTeam = true;`

---

### 18. Added preset system

**New file:** `modules/pentesting/presets.nix`

Introduced `pentesting.preset` option (enum: `null`, `"ctf"`, `"engagement"`, `"full"`, `"blue"`).
Each preset auto-enables a group of categories via `mkDefault`, so individual `categories.X = false` toggles always win.

| Preset | Categories |
|--------|-----------|
| `"ctf"` | network, web, password, forensics, reverseEngineering |
| `"engagement"` | network, web, activeDirectory, password, mitm |
| `"full"` | all 9 categories |
| `"blue"` | network, forensics, blueTeam |

---

### 19. Upgraded p10k to rainbow/powerline style

Changed from lean/transparent style to classic powerline with:
- Rose Pine dark background colours on all segments
- Powerline arrow separators (`\uE0B0` / `\uE0B2`)
- Colour mapping: dir=iris, vcs clean=foam, vcs modified=gold, error=love, nix_shell=pine, time=subtle
- Kept transient prompt and instant prompt

---

### 20. Added zsh plugins

Added two new plugins to `home/zsh.nix`:
- `zsh-completions` — extra completion definitions
- `fzf-tab` — replaces default zsh tab completion with fzf picker

---

---

## Session 4 — Red Team Expansion, Scripts & Cleanup

### 21. Removed redundant `hms` alias

The `hms` alias was identical to `nrs` (both run `nh os switch ~/IceBreaker`). Removed it since home-manager is embedded in the NixOS module — there's no separate home-manager rebuild step.

---

### 22. Added red team tools to existing modules

Expanded three existing modules with verified nixpkgs-unstable packages:

**network.nix** (+6 tools):
- `nbtscan` — NetBIOS name scanner
- `naabu`, `httpx`, `katana`, `uncover`, `interactsh` — ProjectDiscovery suite

**web.nix** (+4 tools):
- `commix` — command injection exploitation
- `wafw00f` — WAF fingerprinting
- `ghauri` — advanced SQL injection (sqlmap alternative)
- `cewl` — custom wordlist generator from URLs

**active-directory.nix** (+4 tools):
- `evil-winrm` — WinRM shell for Windows pentesting
- `kerbrute` — Kerberos brute-force / user enumeration
- `coercer` — Windows authentication coercion (PetitPotam, etc.)
- `smbmap` — SMB share enumeration & access checking

---

### 23. Added exploitation & post-exploitation categories

**New file:** `modules/pentesting/exploitation.nix`
- `metasploit` — the exploitation framework
- `exploitdb` — exploit database + searchsploit CLI

**New file:** `modules/pentesting/post-exploitation.nix`
- `chisel` — TCP/UDP tunnelling over HTTP
- `ligolo-ng` — tunnelling/pivoting tool
- `proxychains-ng` — force TCP through proxy
- `sshuttle` — VPN over SSH
- `rlwrap` — readline wrapper for dumb shells
- `pwncat` — post-exploitation platform
- `havoc` — C2 framework
- `villain` — C2 framework (Python-based)

Updated `default.nix` with two new `mkEnableOption` entries, `presets.nix` with updated preset definitions (ctf gets exploitation; engagement gets exploitation + postExploitation; full gets both), and `configuration.nix` with new toggle defaults.

Total categories: 9 → 11.

---

### 24. Expanded pipx install script

Added `--help` flag and new tools:
- **Post-exploitation:** `manspider` (SMB file spider), `pygpoabuse` (GPO abuse)
- **Web:** `droopescan` (CMS scanner for Drupal, WordPress, SilverStripe)
- **Recon:** `dnstwist` (domain phishing detection / permutation scanner)

---

### 25. Created IceBreaker walkthrough guide

**New file:** `scripts/icebreaker-guide.sh`

Interactive terminal guide with coloured output that walks through:
- What NixOS is and how it differs from other distros
- IceBreaker flake structure (full tree view)
- Rebuilding (nrs/nrt/nrb) and rollback
- All 11 categories with tool lists
- Presets (ctf, engagement, full, blue)
- Complete aliases reference
- Pipx tools and how to run the installer
- Updating, garbage collection, maintenance
- Tips and tricks

Added `guide` alias in `aliases.nix` to run it from anywhere.

---

---

## Session 5 — Engagement Workflow, Shell Functions & Cloud Module

### 26. Target & Engagement Management Functions

Added ZSH functions to `home/zsh.nix` `initContent` for managing pentesting engagements:

- `settarget <IP> [LPORT]` — sets `$TARGET`, auto-detects `$LHOST` from tun0→tun1→eth0, persists to `~/.target.env`
- `newbox <name> [IP]` — creates `~/targets/<name>/` with nmap/, loot/, exploits/, www/ subdirs, flags.txt, creds.txt, notes.md template; symlinks `~/targets/current`
- `flag <value> [desc]` — appends timestamped flag to `./flags.txt` or `~/targets/current/flags.txt`
- `cred <user> <pass> [service]` — appends timestamped credential to creds.txt
- `hcmode [filter]` — hashcat mode quick-reference with optional grep filter
- `nmap-init`, `nmap-allports`, `nmap-targeted` — nmap wrappers that auto-create `./nmap/` and save output with `-oA`
- `setproxy [port]` — edits proxychains SOCKS5 port via sed

All functions use `''${var}` Nix escaping for `${var}` references inside `''...''` strings.

---

### 27. Reverse Shell Generator

**New file:** `scripts/revshell.sh`

Standalone script generating reverse shell payloads for 14 types: bash, python, python3, perl, php, powershell, nc, ncat, ruby, java, xterm, socat, awk, lua. Each type includes alternatives/notes (URL-encoded bash, PTY upgrade for python3, mkfifo fallback for nc, base64-encoded powershell, SSL ncat).

Uses `$LHOST`/`$LPORT` from `settarget`, prompts if not set.

---

### 28. HTB Tmux Layout

**New file:** `scripts/tmux-htb.sh`

Creates a 3-pane tmux session:
- Top 60%: main terminal
- Bottom-left: notes.md in nvim (auto-detects from `./notes.md` or `~/targets/current/notes.md`)
- Bottom-right: listener info and target variables

Session name derived from `$TARGET` or current directory. Re-attaches if session already exists.

---

### 29. Setup Script

**New file:** `scripts/setup.sh`

First-time setup: enables flakes, chmod scripts, creates ~/targets + ~/ctf + ~/vpn, runs flake update + nixos-rebuild switch, prints next steps.

---

### 30. Cloud Pentesting Module

**New file:** `modules/pentesting/cloud.nix`

12th pentesting category with cloud platform tools:
- `awscli2` — AWS CLI v2
- `google-cloud-sdk` — gcloud, gsutil, bq
- `azure-cli` — az CLI
- `terraform` — IaC enumeration & misconfiguration analysis

Toggle: `pentesting.categories.cloud = true;`

Updated `default.nix` (import + mkEnableOption), `presets.nix` (cloud added to engagement + full; descriptions updated 11→12), `configuration.nix` (toggle + comment updates).

---

### 31. New Aliases

Added to `home/aliases.nix`:
- `rlisten` / `rlisten2` — rlwrap nc listeners on 4444/4445
- `vpnip` — show VPN IP (tun0→tun1 fallback)
- `serve` — python3 HTTP server on 8080
- `revshell` — reverse shell generator script
- `htb-tmux` — HTB tmux layout script

---

### 32. Additional Web Tools

Added to `modules/pentesting/web.nix`:
- `dalfox` — parameter analysis & XSS scanner
- `hakrawler` — fast web crawler for endpoint discovery

---

### 33. Proxychains Configuration

Added `home.activation.createProxychainsConf` to `home/default.nix` — creates `~/.config/proxychains/proxychains.conf` only if it doesn't exist (mutable, so `setproxy` can edit it with sed).

Default: strict_chain, quiet_mode, proxy_dns, SOCKS5 127.0.0.1:1080.

Added `PROXYCHAINS_CONF_FILE` session variable to `home/zsh.nix`.

---

### 34. rlwrap in Base Packages

Added `rlwrap` to `modules/system/base.nix` terminal utilities section so `rlisten` aliases work regardless of whether postExploitation is enabled.

---

### 35. Pipx Script Additions

Added to `scripts/install-pipx-tools.sh`:
- **OSINT section (new):** `shodan` (Shodan CLI)
- **Web section:** `xsstrike` (XSS scanner)
- **Password section:** `cupp` (Common User Password Profiler)

---

### 36. Guide Updates

Updated `scripts/icebreaker-guide.sh` with:
- New section: "Target Management" (newbox, settarget, flag, cred)
- New section: "Shell Functions" (hcmode, nmap helpers, setproxy, revshell, htb-tmux)
- Updated structure tree with cloud.nix, revshell.sh, tmux-htb.sh, setup.sh
- Updated categories section (12 categories, cloud added)
- Updated aliases section with rlisten, vpnip, serve, revshell, htb-tmux
- Updated pipx section with shodan, xsstrike, cupp

---

## Session 6 — Multi-Arch, Comments, P10k Segments, Tmux Overhaul

### 37. Multi-Architecture Support

Added `mkSystem` helper in `flake.nix` that takes a `system` parameter, producing two outputs:
- `icebreaker` — x86_64-linux (Intel/AMD)
- `icebreaker-aarch64` — aarch64-linux (ARM64, Raspberry Pi, Apple Silicon via Asahi)

### 38. Comprehensive Nix File Comments

Added guiding comments to all nix files explaining:
- What each section does and how to customize it
- Where new packages/categories/aliases should go
- How to create new pentesting category modules (with cloud.nix as template)
- How to add new presets
- Nix string escaping rules for ZSH code in `''...''` strings

Files updated: `flake.nix`, `configuration.nix`, `modules/system/base.nix`, `modules/system/nix-helpers.nix`, `modules/pentesting/default.nix`, `modules/pentesting/presets.nix`, `modules/pentesting/web.nix`, `modules/pentesting/cloud.nix`, `home/default.nix`, `home/zsh.nix`, `home/aliases.nix`

### 39. Powerlevel10k Custom Segments

Added two custom p10k segments to `home/p10k.zsh`:

**`my_vpn_ip`** — Shows network IP in the right prompt:
- VPN active (tun0/tun1): foam-coloured lock icon + IP
- No VPN: muted ethernet icon + LAN IP (auto-detected via `ip route`)
- No network: segment hidden

**`my_ping`** — Shows ping latency:
- Pings `$TARGET` if set, otherwise default gateway
- Uses async background caching (10s refresh) to avoid blocking the prompt
- Colour-coded: foam (<50ms), gold (50-150ms), love (>150ms)

### 40. Full Tmux Configuration — Rose Pine Dawn

Replaced the minimal tmux config with a comprehensive Nix-managed setup:

**Theme:** Rose Pine Dawn (light variant) — contrasts nicely with the dark terminal theme.

**Plugins (15, all via nixpkgs):**
- `sensible` — universal sane defaults
- `yank` — system clipboard integration
- `resurrect` + `continuum` — session persistence (auto-save/restore)
- `pain-control` — standardised pane keybindings
- `vim-tmux-navigator` — seamless Ctrl+h/j/k/l between tmux and neovim
- `extrakto` — fuzzy text extraction from terminal output
- `open` — open files/URLs from copy mode
- `fzf-tmux-url` — fuzzy URL picker
- `prefix-highlight` — visual feedback when prefix key is pressed
- `jump` — vimium-style jump to any character
- `tmux-thumbs` — hint-based text copying
- `tmux-sessionx` — fzf + zoxide session management
- `logging` — terminal logging and screen capture
- `sidebar` — directory tree sidebar

**Keybindings:**
- `prefix + v/s` or `|/-` — split panes (preserving directory)
- `Alt+arrows` — navigate panes without prefix
- `prefix + </>`— swap windows left/right
- `prefix + x/X` — kill pane/window
- Vi copy mode: `v` select, `C-v` rectangle, `y` copy

**Status bar:** Powerline-style with session name (pine), hostname, time, prefix highlight indicator.

**Note:** `tmux-window-name` does NOT exist in nixpkgs — removed from plugin list.

---

---

## Session 7 — KDE→XFCE, Setup Script Fix, Multi-VM Support

### 41. Setup script crash: unbound `$DIM` variable

**Error:** `bash: DIM: unbound variable` — script died immediately at the banner.

**Cause:** `set -euo pipefail` with `-u` (treat unset variables as errors) + `${DIM}` used on line 32 but never defined. Only `GREEN`, `YELLOW`, `RED`, `BOLD`, and `NC` were declared.

**Fix:** Added `DIM='\033[2m'` to the colour definitions at the top of the script.

---

### 42. KDE Plasma 6 black screen → switched to XFCE

**Problem:** After login via SDDM, KDE showed a black screen with only the mouse cursor. Ctrl+Alt+Del still worked (VMware intercept), confirming the session was alive but `plasmashell` failed to start.

**Root cause:** Stylix's Qt/KDE theming targets conflict with Plasma 6's own theming stack. The `targets.qt.enable = false` workaround (upstream issue #1092) was insufficient — Stylix's other targets (GTK, cursor, icons) still interfered with KDE's initialisation.

**Why XFCE:**
- GTK-native → Stylix applies cleanly with zero workarounds
- Lighter on VM resources (~300-400MB vs ~800MB+ RAM for KDE)
- More reliable compositing under virtualised GPUs
- Simpler failure modes — no layered kwin/plasmashell/plasma-frameworks stack
- No functional loss for pentesting — the actual workflow is terminals + Firefox + Burp/Wireshark

**Changes:**
- `base.nix`: Replaced SDDM + Plasma 6 with LightDM (slick-greeter) + XFCE. Replaced `kdePackages.kate` with `mousepad` + `xfce.xfce4-terminal`.
- `stylix.nix`: Removed `targets.qt.enable = false` (no longer needed).
- `configuration.nix`: Updated references.

---

### 43. Setup script rewrite — fully automated first-run

**Problem:** The script didn't copy `hardware-configuration.nix` from `/etc/nixos/`, used `nh` (not available on fresh installs), and had no step indicators.

**Changes:**
- Added Step 2: auto-copies `hardware-configuration.nix` from `/etc/nixos/` with smart handling (diff check if both exist, backup of existing, generate fresh if neither exists).
- Changed rebuild from `nh os switch` to `sudo nixos-rebuild switch` (always available).
- Added numbered step headers (now 7 steps total).
- Users never need to touch `/etc/nixos/` at all — the script handles everything.

---

### 44. Multi-VM hypervisor support

**Problem:** `virtualisation.vmware.guest.enable = true` was hardcoded, causing issues on non-VMware hypervisors.

**Initial approach (rejected):** Tried auto-detecting via `builtins.pathExists "/sys/class/dmi/id/sys_vendor"` + `builtins.readFile`. This is **impure** — Nix flakes use pure evaluation by default, so reading `/sys/` paths at eval time fails without `--impure`. Also tried always-enabling `services.spice-vdagentd` and `services.qemuGuest` — but spice-vdagent fails to start on non-SPICE VMs (nixpkgs issue #481078), polluting systemd logs.

**Final approach:** VMware stays as the default (most common for pentesting VMs). Commented-out blocks for QEMU/KVM and VirtualBox with clear instructions — user uncomments the one matching their hypervisor and sets the others to false. This is explicit, reproducible, and avoids impure evaluation or service failures.

**Changes:**
- `base.nix`: VMware enabled by default, QEMU/KVM and VirtualBox options documented as comments
- Clear comment block explaining why auto-detection doesn't work in flakes
- SPICE agent only suggested for QEMU/KVM with SPICE display

---

### 45. Setup script fails on first line: `/etc/nix/nix.conf: Read-only file system`

**Error:** `tee: /etc/nix/nix.conf: Read-only file system` — the very first step of setup.sh failed.

**Root cause:** On NixOS, `/etc/nix/nix.conf` is a **symlink into `/nix/store/`** — the entire Nix store is an immutable, read-only filesystem. You cannot write to any file in `/nix/store/` regardless of permissions or sudo. The script was trying to `echo | sudo tee -a /etc/nix/nix.conf` which is fundamentally impossible on NixOS.

This is different from a permissions problem — even `sudo` cannot bypass it because the filesystem itself is mounted read-only. The Nix store is content-addressed and immutable by design.

**Why the old approach was wrong:**
- On non-NixOS systems (Ubuntu, macOS), `/etc/nix/nix.conf` is a regular file you can edit
- On NixOS, `/etc/nix/nix.conf` is generated by the NixOS module system and symlinked from the store
- The setup script was written assuming non-NixOS behaviour
- Confusingly, `sudo mkdir -p /etc/nix` succeeded (since `/etc/` itself is writable on NixOS), making it look like only the `tee` was failing, when actually the entire approach was wrong

**The chicken-and-egg problem:** We need flakes to run `nix flake update`, but flakes are enabled through `nix.settings.experimental-features` in the NixOS module system, which requires a rebuild, which requires flakes.

**Fix:** Removed the entire "enable flakes in /etc/nix/nix.conf" step. Instead:
1. Use `--extra-experimental-features 'nix-command flakes'` flag on `nix flake update` for the bootstrap
2. Use the same flag on `sudo nixos-rebuild switch` for the first rebuild
3. After the first rebuild, `nix-helpers.nix` permanently enables flakes via `nix.settings.experimental-features = [ "nix-command" "flakes" ]`
4. All subsequent rebuilds (via `nrs` alias) work without any extra flags

Also restructured the script from 7 steps to 6 steps (removed the broken "enable flakes" step), added error tracking instead of `set -e` immediate exit, and added a full "MANUAL SETUP STEPS" fallback section that prints if any step fails — showing the user exactly how to do each step by hand with copy-pasteable commands.

---

### 47. nixos-rebuild: unrecognized arguments: --extra-experimental-features

**Error:** `nixos-rebuild: error: unrecognized arguments: --extra-experimental-features nix-command flakes`

**Cause:** `--extra-experimental-features` is a `nix` CLI flag only. `nixos-rebuild` is a separate command (a Perl/bash wrapper) that does NOT support the same flags. Looking at `nixos-rebuild --help`, it supports `--option OPTION VALUE` which gets passed through to the underlying Nix evaluator.

**The two commands use DIFFERENT flag syntax:**
- `nix` CLI: `nix --extra-experimental-features 'nix-command flakes' flake update`
- `nixos-rebuild`: `sudo nixos-rebuild switch --option extra-experimental-features 'nix-command flakes'`

This is confusing because they look similar but `--extra-experimental-features` is a top-level nix flag, while `--option` is the generic passthrough for nix settings in nixos-rebuild.

**Fix:** Changed `setup.sh` step 5 from `--extra-experimental-features` to `--option extra-experimental-features "nix-command flakes"`. Also updated the manual fallback instructions to use the correct flag. Also removed `set -e` from `set -euo pipefail` (changed to `set -uo pipefail`) so the script doesn't abort on first error — we track errors with `SETUP_FAILED` variable instead.

---

### 48. No password set for `archangel` user — can't login after rebuild

**Error:** After a successful rebuild and reboot, the LightDM greeter shows `archangel` as the user, but no password works because none was ever set.

**Cause:** `users.users.archangel` in `base.nix` defined `isNormalUser = true` and all the groups/shell/etc, but had no password option set. On NixOS, `isNormalUser` creates the user account and home directory but does NOT set a password — the user is effectively locked out unless they can get to a root shell via recovery boot.

**Fix:** Added `initialPassword = "icebreaker"` to the user definition. This is a NixOS-specific option that sets a default password only if no password has been set yet. Once the user runs `passwd` to change it, NixOS won't overwrite it on subsequent rebuilds (unlike `hashedPassword` which would reset on every rebuild).

Also added prominent password instructions to `setup.sh` success output — a visible box telling the user the default credentials and to change them immediately.

---

### 49. LightDM "Failed to start session" — missing `defaultSession`

**Error:** After logging in via LightDM with the correct password, the screen flashes and shows "Failed to start session."

**Cause:** `services.xserver.desktopManager.xfce.enable = true` registers XFCE as an available session, but without explicitly setting `services.displayManager.defaultSession = "xfce"`, LightDM may not know which session to launch — especially on a fresh user account with no prior session selection saved.

**Fix:** Added `services.displayManager.defaultSession = "xfce";` to `base.nix` in the desktop section. This explicitly tells LightDM to use XFCE as the default session type. Note: this is `services.displayManager.defaultSession`, NOT `services.xserver.displayManager.defaultSession` — the option was moved to the new namespace in recent NixOS versions.

---

### 50. README and setup script: username instructions and password info

**Problem:** Nothing told users that:
- The config hardcodes `archangel` as the username and they need to change it if they used a different name during NixOS install
- The three files that need updating (base.nix, home/default.nix, flake.nix)
- What the default password is and that they need to change it

**Fix:**
- Added "Before You Begin" section to `README.md` with a table showing which files to edit for username changes, plus hypervisor selection instructions
- Updated Quick Start in README to include reboot, login, and `passwd` steps
- Added a prominent credentials box to `setup.sh` success output showing username/password and the `passwd` command
- Updated next steps in setup.sh to start with reboot → login → change password

---

### 51. Alacritty terminal — full config via home-manager

**Added:** `programs.alacritty` to `home/default.nix` with comprehensive settings:
- Window: 8px/6px padding, dynamic title, starts maximised
- Scrollback: 50,000 lines, 3x scroll multiplier
- Cursor: block with blinking, underline in vi mode
- Selection: auto-copy to clipboard
- Mouse: hide when typing
- Shell: ZSH
- Keyboard: font size controls, copy/paste, page scroll, vi mode toggle, search
- Colours/font/opacity: NOT set — Stylix manages all of these automatically

**Note:** Alacritty is a Stylix target that auto-enables when installed. Stylix injects the Rose Pine colour scheme, JetBrainsMono Nerd Font, and terminal opacity. Setting any of those manually would cause "conflicting definitions" errors.

---

### 52. `python3Packages.jwt` does not exist — fixed to `pyjwt`

**Problem:** `python3Packages.jwt` in `web.nix` would fail to build because there's no package by that name in nixpkgs.

**Fix:** Changed to `python3Packages.pyjwt` — the correct package name for the PyJWT library.

---

### 53. Config audit — `nix-helpers.nix` also hardcodes username

**Problem:** The README "Before You Begin" section only listed 3 files to edit when changing the username from `archangel`. But `modules/system/nix-helpers.nix` also has `"archangel"` in the `trusted-users` list, and `home/default.nix` additionally has `git user.name` and `user.email` set to `archangel`.

**Fix:** Updated README table to include all 4 files and note the git settings.

---

### 54. P10k prompt not loading on first `exec zsh`

**Diagnosis:** Most likely cause — the user ran `exec zsh` from their original NixOS user account (the one they installed with), not as `archangel`. Home-manager only generates `.zshrc` and `.p10k.zsh` in `/home/archangel/`. The original user's home has no p10k config, so they get a bare zsh prompt.

**Secondary cause:** On the very first `exec zsh` as archangel, the p10k instant prompt cache (`~/.cache/p10k-instant-prompt-*.zsh`) doesn't exist yet. The theme still loads but the first render can be slightly delayed. Subsequent shell startups are instant.

**Resolution:** After rebooting and logging in as `archangel`, the prompt should work correctly. The XFCE terminal or Alacritty must also use a Nerd Font (Stylix handles this automatically).

---

---

## Session 8 — Documentation, .gitignore, README Overhaul

### 55. `hardware-configuration.nix` not in .gitignore

**Problem:** `hardware-configuration.nix` was being tracked by git. This file is machine-specific (it contains filesystem UUIDs, hardware detection results, and device paths unique to each host). Committing it to a shared repo means anyone who clones and rebuilds without replacing it will get errors, or worse, a config that silently targets the wrong hardware layout.

**Fix:** Created `.gitignore` at the repo root. Added `hardware-configuration.nix` and `hardware-configuration.nix.bak` to it, along with standard entries for:
- Nix build results (`result`, `result-*`)
- Secrets (`*.ovpn`, `*.pem`, `*.key`, `*.crt`, etc.)
- Editor files (`.vscode/`, `.idea/`, `*.swp`, etc.)
- OS files (`.DS_Store`, `Thumbs.db`)
- Python artefacts (`__pycache__/`, `*.pyc`, `.venv/`)

The `github-setup.md` doc already mentioned adding `hardware-configuration.nix` to `.gitignore` as "Option A" — this makes it the default instead of an afterthought.

---

### 56. README rewrite — comprehensive installation guide

**Problem:** The README covered the happy path in about 20 lines. It didn't explain:
- What to do if the setup script fails (manual steps, specific error messages)
- The bootstrap problem (why `/etc/nix/nix.conf` can't be edited, the flag difference between `nix` and `nixos-rebuild`)
- The `archangel` username situation in enough detail (two options, which files to edit, why it matters)
- How to build from GitHub from scratch on a brand new machine
- The "Failed to start session" LightDM failure mode
- Generation rollback workflow

**Fix:** Full rewrite of `README.md`. New structure:
- Table of contents (with anchor links)
- "Before You Begin" — username choice (Option A: keep archangel, Option B: full file list) and hypervisor selection
- Full installation walkthrough — 8 numbered steps, each with explanation
- "Building Directly from GitHub" — covers fresh NixOS install, existing NixOS machine, aarch64, and multi-machine sync
- "If the Setup Script Fails" — complete manual steps with copy-paste commands, explanation of the `/etc/nix/nix.conf` read-only constraint, and a troubleshooting table
- "Daily Usage" — key commands for rebuilding, starting engagements, VPN, listeners, reverse shells
- "Categories & Presets" — full category table with preset override example
- "Architecture" — updated tree + key design decisions explaining the embedded HM model, Stylix injection, EXTENDED_GLOB, and gitignore rationale
- "Troubleshooting" — 9 specific failure scenarios with causes and fixes

---

*Last updated: 2026-03-10*
