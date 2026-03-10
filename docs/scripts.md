```
 ┌─────────────────────────────────────────────────────────┐
 │  ICEBREAKER // AUTONOMOUS ATTACK PROGRAMS               │
 │  "Cyberspace. A consensual hallucination experienced    │
 │   daily by billions."  — Neuromancer                    │
 └─────────────────────────────────────────────────────────┘
```

# Scripts

IceBreaker includes standalone scripts in the `scripts/` directory. These handle tasks that don't need to modify the current shell's environment.

## Reverse Shell Generator

**File:** `scripts/revshell.sh`
**Alias:** `revshell`

Generates reverse shell payloads for 14 different languages/tools. Uses `$LHOST` and `$LPORT` from `settarget`.

### Usage

```bash
revshell bash           # Generate bash reverse shell
revshell python3        # Python3 with PTY upgrade notes
revshell powershell     # PowerShell + base64-encoded version
revshell --list         # Show all available types
revshell --all          # Print every payload at once
revshell                # Interactive — prompts for type
```

### Available Types

| Type | Notes |
|------|-------|
| `bash` | Includes URL-encoded and exec variants |
| `python` | Python 2 |
| `python3` | Includes PTY upgrade instructions |
| `perl` | Standard perl reverse shell |
| `php` | CLI + web shell one-liner |
| `powershell` | Standard + base64-encoded (AV bypass) |
| `nc` | Standard + mkfifo fallback |
| `ncat` | Standard + SSL variant |
| `ruby` | Ruby socket reverse shell |
| `java` | Runtime.exec() payload |
| `xterm` | X11 display redirect |
| `socat` | Full TTY reverse shell |
| `awk` | Awk network socket |
| `lua` | Lua socket reverse shell |

### Tips

- Run `settarget <IP>` first to set `$LHOST`/`$LPORT`
- If not set, the script auto-detects your VPN IP or prompts
- Copy payloads directly — they include your actual IP and port
- The powershell base64 variant requires `iconv` (available in base system)

## HTB Tmux Layout

**File:** `scripts/tmux-htb.sh`
**Alias:** `htb-tmux`

Creates a 3-pane tmux session optimised for HackTheBox/CTF work.

### Layout

```
┌──────────────────────────────────────────┐
│                                          │
│           Main Terminal (60%)            │
│                                          │
├─────────────────────┬────────────────────┤
│                     │                    │
│   Notes (nvim)      │  Listener Info     │
│     (20%)           │    (20%)           │
└─────────────────────┴────────────────────┘
```

### Behaviour

- **Session name:** Derived from `$TARGET` or current directory name
- **If session exists:** Re-attaches instead of creating a new one
- **Notes pane:** Opens `./notes.md` or `~/targets/current/notes.md` in nvim
- **Listener pane:** Shows `rlisten`/`rlisten2` commands and current `$TARGET`/`$LHOST`

### Typical Usage

```bash
newbox forest 10.10.10.161    # Create target scaffold
htb-tmux                       # Launch the layout

# Now you have:
# - Top pane: run nmap-init, exploits, etc.
# - Bottom-left: notes open in nvim
# - Bottom-right: start rlisten when ready
```

### Tmux Keybindings

IceBreaker uses `Ctrl+a` as the tmux prefix (not the default `Ctrl+b`):

| Key | Action |
|-----|--------|
| `Ctrl+a \|` | Split pane vertically |
| `Ctrl+a -` | Split pane horizontally |
| `Ctrl+a r` | Reload tmux config |
| `Ctrl+a [` | Enter copy mode (vi keys) |

## Setup Script

**File:** `scripts/setup.sh`

First-time setup for a fresh NixOS installation.

### What It Does

1. Enables Nix flakes in `/etc/nix/nix.conf` (if not already)
2. Makes all scripts in `scripts/` executable
3. Creates `~/targets`, `~/ctf`, `~/vpn` directories
4. Runs `nix flake update`
5. Runs `sudo nixos-rebuild switch --flake .#icebreaker`
6. Prints next steps

### Usage

```bash
cd ~/IceBreaker
./scripts/setup.sh
```

Only needs to be run once after cloning.

## Pipx Tool Installer

**File:** `scripts/install-pipx-tools.sh`

Installs Python/Ruby pentesting tools that are broken or missing in nixpkgs.

### Usage

```bash
~/IceBreaker/scripts/install-pipx-tools.sh            # Install all
~/IceBreaker/scripts/install-pipx-tools.sh --update    # Upgrade installed
~/IceBreaker/scripts/install-pipx-tools.sh --help      # Show help
```

### What It Installs

| Section | Tools |
|---------|-------|
| **Network/Exploit** | impacket, netexec |
| **Active Directory** | certipy-ad, bloodhound-ce, ldapdomaindump, windapsearch, sprayhound, donpapi, lsassy |
| **Post-Exploit** | manspider, pygpoabuse |
| **Web** | mitmproxy, arjun, droopescan, xsstrike |
| **OSINT** | shodan |
| **Password** | name-that-hash, haiti-hash, cupp |
| **Recon** | recon-ng, theHarvester, dnstwist |
| **Utilities** | pwncat-cs, updog, ciphey |
| **Ruby Gems** | evil-winrm |

### Why Pipx?

Some Python tools have conflicting dependencies that break the nixpkgs build. Pipx installs each tool in its own isolated virtualenv, avoiding conflicts.

Tools are installed to `~/.local/bin/` (already in your `$PATH`).

### Updating

```bash
~/IceBreaker/scripts/install-pipx-tools.sh --update
```

Or update a single tool:
```bash
pipx upgrade mitmproxy
```

## Interactive Guide

**File:** `scripts/icebreaker-guide.sh`
**Alias:** `guide`

Terminal-based walkthrough of everything IceBreaker provides. Runs through 10 sections with coloured output:

1. Welcome
2. What is NixOS?
3. Flake structure
4. Rebuilding
5. Categories & presets
6. Target management
7. Shell functions
8. Aliases reference
9. Pipx tools
10. Tips & tricks

Good for getting oriented or as a quick reference.
