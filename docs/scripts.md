```
 ┌─────────────────────────────────────────────────────────┐
 │  ICEBREAKER // AUTONOMOUS ATTACK PROGRAMS               │
 │  "Cyberspace. A consensual hallucination experienced    │
 │   daily by billions."  — Neuromancer                    │
 └─────────────────────────────────────────────────────────┘
```

# Scripts

Standalone scripts in the `scripts/` directory. These handle tasks that don't modify the current shell's environment.

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
| `powershell` | Standard + base64-encoded (bypass) |
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

## HTB Tmux Layout

**File:** `scripts/tmux-htb.sh`
**Alias:** `htb-tmux`

Creates a 3-pane tmux session optimised for HackTheBox/CTF work.

### Layout

```
+------------------------------------------+
|                                          |
|           Main Terminal (60%)            |
|                                          |
+---------------------+--------------------+
|                     |                    |
|   Notes (nvim)      |  Listener Info     |
|     (20%)           |    (20%)           |
+---------------------+--------------------+
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

## Setup Script

**File:** `scripts/setup.sh`

First-time setup for a fresh NixOS installation. Handles everything so users never need to touch `/etc/nixos/`.

### What It Does

| Step | Action |
|------|--------|
| 1/5 | Copies `hardware-configuration.nix` from `/etc/nixos/` into `~/IceBreaker/` |
| 2/5 | Makes all scripts in `scripts/` executable |
| 3/5 | Creates `~/targets/`, `~/ctf/`, `~/vpn/` directories |
| 4/5 | Updates flake inputs (bootstraps flakes with `--extra-experimental-features` on fresh NixOS) |
| 5/5 | Runs `sudo nixos-rebuild switch --flake ~/IceBreaker#icebreaker` |

### Usage

```bash
cd ~/IceBreaker
./scripts/setup.sh
```

Only needs to be run once after cloning. If any step fails, the script prints full manual recovery instructions.

### If It Fails

See the main [README](../README.md) section [05] for detailed manual steps.

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

Some Python tools have conflicting dependencies that break the nixpkgs build. Pipx installs each tool in its own isolated virtualenv, avoiding conflicts. Tools are installed to `~/.local/bin/` (already in `$PATH`).

### Updating

```bash
~/IceBreaker/scripts/install-pipx-tools.sh --update    # update all
pipx upgrade mitmproxy                                  # update one
```

## Interactive Guide

**File:** `scripts/icebreaker-guide.sh`
**Alias:** `guide`

Terminal-based walkthrough with coloured output covering:

1. What is NixOS?
2. Flake structure
3. Rebuilding
4. Categories & presets
5. Target management
6. Shell functions
7. Aliases reference
8. Pipx tools
9. Tips & tricks

Good for getting oriented or as a quick reference.
