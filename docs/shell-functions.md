<div align="center">

<!-- ════════════════════════════════════════════════════════════════════════ -->
<!--  I C E B R E A K E R   //   R U N   P R O T O C O L S                    -->
<!-- ════════════════════════════════════════════════════════════════════════ -->

```
▓▒░ ─── I C E B R E A K E R  //  R U N   P R O T O C O L S ─── ░▒▓
```

<p align="center">
  <img src="https://img.shields.io/badge/SECTION-05_of_11-c4a7e7?style=for-the-badge&labelColor=191724"/>
  <img src="https://img.shields.io/badge/SHELL-9_functions-9ccfd8?style=for-the-badge&labelColor=191724"/>
  <a href="README.md"><img src="https://img.shields.io/badge/%E2%86%A9_docs_index-9ccfd8?style=for-the-badge&labelColor=191724"/></a>
  <a href="../README.md"><img src="https://img.shields.io/badge/%E2%86%A9_main_README-eb6f92?style=for-the-badge&labelColor=191724"/></a>
</p>

</div>

<div align="center">
  <img src="images/graphics/icebreaker-dividers/divider-c-double-rose.png" width="100%"/>
</div>

```
 ┌─────────────────────────────────────────────────────────┐
 │  ICEBREAKER // COMBAT SUBROUTINES                       │
 │  "He'd found his vocation, his calling."                │
 │                                        — Neuromancer    │
 └─────────────────────────────────────────────────────────┘
```

# Shell Functions

IceBreaker includes ZSH functions for managing targets, running nmap, and more. These are defined in `home/zsh.nix` and available in every shell session.

Unlike aliases, these are full functions that can accept arguments, modify environment variables, and change directories.

## Target Management

### settarget

Set the current target IP, auto-detect your attack IP, and persist for new shells.

```bash
settarget <IP> [LPORT]
```

**What it does:**
- Sets `$TARGET` to the given IP
- Auto-detects `$LHOST` from tun0 → tun1 → eth0 (first one with an IP)
- Sets `$LPORT` (default: 4444)
- Saves all three to `~/.target.env` so new terminal tabs pick them up

**Examples:**
```bash
settarget 10.10.10.161              # LPORT defaults to 4444
settarget 10.10.10.161 9001         # Custom LPORT

# Check current values
settarget                           # Shows current TARGET/LHOST/LPORT
echo $TARGET $LHOST $LPORT          # Use anywhere in commands
```

**How persistence works:**
Every new ZSH shell automatically sources `~/.target.env` at startup. So if you run `settarget` in one terminal, all new terminals will have the same `$TARGET`/`$LHOST`/`$LPORT`.

### newbox

Create a structured directory for a new engagement target.

```bash
newbox <name> [IP]
```

**What it does:**
- Creates `~/targets/<name>/` with subdirectories:
  - `nmap/` — nmap scan output
  - `loot/` — captured files, hashes, etc.
  - `exploits/` — exploit scripts
  - `www/` — files to serve via HTTP
- Creates `flags.txt`, `creds.txt`, and a `notes.md` template
- Symlinks `~/targets/current` → the new directory
- Changes directory into the new box
- Calls `settarget <IP>` if IP is provided

**Examples:**
```bash
newbox forest 10.10.10.161          # Create + set target
newbox jerry                        # Create without IP (set later)
```

**The notes.md template includes sections for:**
- Recon
- Foothold
- PrivEsc
- Flags
- Credentials
- Notes

### flag

Log a captured flag with timestamp.

```bash
flag <value> [description]
```

**Where it saves:**
1. `./flags.txt` if it exists in the current directory
2. `~/targets/current/flags.txt` as fallback

**Examples:**
```bash
flag abc123def456                   # Just the flag value
flag abc123def456 "user.txt"        # With description
flag HTB{s0m3_fl4g} "root flag"    # HTB-style flag
```

**Output in flags.txt:**
```
[2026-03-08 14:30] abc123def456  # user.txt
[2026-03-08 15:45] HTB{s0m3_fl4g}  # root flag
```

### cred

Log discovered credentials with timestamp.

```bash
cred <username> <password> [service]
```

**Where it saves:**
1. `./creds.txt` if it exists in the current directory
2. `~/targets/current/creds.txt` as fallback

**Examples:**
```bash
cred admin Password1 ssh            # With service
cred sa passw0rd! mssql             # Database creds
cred administrator P@ssw0rd        # Without service
```

**Output in creds.txt:**
```
[2026-03-08 14:30] admin:Password1  (ssh)
[2026-03-08 14:35] sa:passw0rd!  (mssql)
```

## Nmap Helpers

All nmap functions auto-create a `./nmap/` directory and save output in all formats (`-oA`).

### nmap-init

Initial reconnaissance scan.

```bash
nmap-init [target]
```

**Runs:** `nmap -sV -sC -O --open -oA ./nmap/initial <target>`

- Version detection (`-sV`)
- Default scripts (`-sC`)
- OS detection (`-O`)
- Only open ports (`--open`)

Uses `$TARGET` if no argument given.

### nmap-allports

Full port scan (all 65535 ports).

```bash
nmap-allports [target]
```

**Runs:** `nmap -p- -T4 --open -oA ./nmap/allports <target>`

Use this after `nmap-init` to find ports the initial scan missed.

### nmap-targeted

Targeted scan on specific ports found by `nmap-allports`.

```bash
nmap-targeted <target> <ports>
```

**Runs:** `nmap -sV -sC -p<ports> -oA ./nmap/targeted <target>`

**Example:**
```bash
nmap-targeted 10.10.10.161 22,80,445,8080
```

Both arguments are required (no `$TARGET` fallback for this one).

### Typical nmap workflow

```bash
newbox forest 10.10.10.161         # Set up box
nmap-init                          # Quick scan with scripts
nmap-allports                      # Find all open ports
nmap-targeted $TARGET 88,389,445   # Deep scan specific ports
```

All output goes to `./nmap/` with `.nmap`, `.gnmap`, and `.xml` files.

## Hashcat Mode Reference

### hcmode

Print common hashcat mode numbers.

```bash
hcmode [filter]
```

**Without filter — shows all:**
```bash
hcmode
# 0       MD5
# 100     SHA1
# 500     md5crypt (Unix)
# 1000    NTLM
# ...
```

**With filter — grep for keyword:**
```bash
hcmode ntlm
# 1000    NTLM
# 5500    NetNTLMv1
# 5600    NetNTLMv2

hcmode kerb
# 7500    Kerberos 5 AS-REQ Pre-Auth (etype 23)
# 13100   Kerberos 5 TGS-REP (Kerberoast, etype 23)
# 18200   Kerberos 5 AS-REP (AS-REP Roast, etype 23)

hcmode wpa
# 2500    WPA-EAPOL-PBKDF2
# 16800   WPA-PMKID-PBKDF2
# 22000   WPA-PBKDF2-PMKID+EAPOL
```

**Included modes:**
| Mode | Hash Type |
|------|-----------|
| 0 | MD5 |
| 100 | SHA1 |
| 500 | md5crypt (Unix) |
| 1000 | NTLM |
| 1400 | SHA256 |
| 1700 | SHA512 |
| 1800 | sha512crypt (Unix) |
| 2100 | DCC2 |
| 2500 | WPA-EAPOL |
| 3000 | LM |
| 3200 | bcrypt |
| 5500 | NetNTLMv1 |
| 5600 | NetNTLMv2 |
| 7500 | Kerberos AS-REQ |
| 13100 | Kerberoast |
| 13400 | KeePass |
| 18200 | AS-REP Roast |
| 22000 | WPA-PMKID+EAPOL |

## Proxy Management

### setproxy

Change the SOCKS5 port in your proxychains config.

```bash
setproxy [port]
```

**Default port:** 1080

**Examples:**
```bash
setproxy              # Reset to 1080
setproxy 9050         # Tor default port
setproxy 1337         # Custom port
```

Edits `~/.config/proxychains/proxychains.conf` in place.

Use with chisel, ligolo-ng, or SSH tunnels:
```bash
# Set up SOCKS proxy via SSH
ssh -D 1080 user@pivot-host

# Or via chisel
chisel server -p 8888 --socks5
chisel client pivot-ip:8888 socks

# Then use proxychains
setproxy 1080
proxychains nmap -sT -Pn 172.16.0.0/24
```

## Environment Variables

These are always available after running `settarget`:

| Variable | Description | Example |
|----------|-------------|---------|
| `$TARGET` | Target IP | `10.10.10.161` |
| `$LHOST` | Your attack IP (VPN) | `10.10.14.5` |
| `$LPORT` | Listener port | `4444` |
| `$WORDLISTS` | Seclists path | `/run/current-system/sw/share/seclists` |
| `$ROCKYOU` | rockyou.txt path | `...seclists/Passwords/Leaked-Databases/rockyou.txt` |
| `$PROXYCHAINS_CONF_FILE` | Proxychains config path | `~/.config/proxychains/proxychains.conf` |

Use them in any command:
```bash
ffuf -w $WORDLISTS/Discovery/Web-Content/common.txt -u http://$TARGET/FUZZ
hashcat -m 1000 hashes.txt $ROCKYOU
nmap -sV -sC $TARGET
```
