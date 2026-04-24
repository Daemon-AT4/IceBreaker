<div align="center">

<!-- ════════════════════════════════════════════════════════════════════════ -->
<!--  I C E B R E A K E R   //   W E A P O N S   M A N I F E S T             -->
<!-- ════════════════════════════════════════════════════════════════════════ -->

```
▓▒░ ─── I C E B R E A K E R  //  W E A P O N S   M A N I F E S T ─── ░▒▓
```

<p align="center">
  <img src="https://img.shields.io/badge/SECTION-03_of_11-c4a7e7?style=for-the-badge&labelColor=191724"/>
  <img src="https://img.shields.io/badge/ARSENAL-12_categories-eb6f92?style=for-the-badge&labelColor=191724"/>
  <img src="https://img.shields.io/badge/PRESETS-4-eb6f92?style=for-the-badge&labelColor=191724"/>
  <a href="README.md"><img src="https://img.shields.io/badge/%E2%86%A9_docs_index-9ccfd8?style=for-the-badge&labelColor=191724"/></a>
  <a href="../README.md"><img src="https://img.shields.io/badge/%E2%86%A9_main_README-eb6f92?style=for-the-badge&labelColor=191724"/></a>
</p>

</div>

<div align="center">
  <img src="images/graphics/icebreaker-dividers/divider-e-dotmatrix-amber.png" width="100%"/>
</div>

```
 ┌─────────────────────────────────────────────────────────┐
 │  ICEBREAKER // WEAPONS MANIFEST                         │
 │  "He'd operated on an almost permanent adrenaline       │
 │   high."  — Neuromancer                                 │
 └─────────────────────────────────────────────────────────┘
```

# Categories & Presets

IceBreaker organises pentesting tools into 12 categories. Each can be toggled independently in `configuration.nix`, or you can use a preset to enable groups at once.

## Categories

### network
**Toggle:** `pentesting.categories.network = true;`

Core reconnaissance and network scanning.

| Tool | Description |
|------|-------------|
| `nmap` | Port scanner (SUID-wrapped for raw sockets) |
| `masscan` | Fastest port scanner |
| `rustscan` | Fast port scanner with nmap integration |
| `wireshark` | Network protocol analyser (GUI + tshark) |
| `tcpdump` | Command-line packet capture |
| `netcat-gnu` | Network Swiss Army knife |
| `socat` | Multipurpose relay |
| `dnsutils` | dig, nslookup, nsupdate |
| `whois` | Domain registration lookup |
| `naabu` | Fast port scanner (ProjectDiscovery) |
| `httpx` | HTTP probe (ProjectDiscovery) |
| `katana` | Web crawler (ProjectDiscovery) |
| `uncover` | Shodan/Censys/Fofa wrapper |
| `interactsh` | OOB interaction server |
| `nbtscan` | NetBIOS name scanner |
| `net-snmp` | SNMP tools (snmpwalk, snmpget, etc.) |
| `enum4linux-ng` | SMB/LDAP/RPC enumeration |

### web
**Toggle:** `pentesting.categories.web = true;`

Web application testing tools.

| Tool | Description |
|------|-------------|
| `burpsuite` | Intercept proxy (unfree) |
| `nikto` | Web server scanner |
| `nuclei` | Template-based vulnerability scanner |
| `wpscan` | WordPress security scanner |
| `sqlmap` | Automatic SQL injection |
| `ghauri` | Advanced SQL injection (sqlmap alternative) |
| `commix` | Command injection exploitation |
| `wafw00f` | WAF detection & fingerprinting |
| `gobuster` | Directory/DNS/vhost brute-forcer |
| `ffuf` | Fast web fuzzer |
| `feroxbuster` | Recursive content discovery |
| `dirb` | Classic directory brute-forcer |
| `whatweb` | Web technology fingerprinting |
| `dalfox` | Parameter analysis & XSS scanner |
| `hakrawler` | Fast web crawler for endpoint discovery |
| `httpie` | Human-friendly HTTP client |
| `curl` / `wget` | HTTP clients |
| `python3Packages.jwt` | JWT manipulation |
| `cewl` | Custom wordlist generator from URLs |
| `seclists` | Security wordlist collection |

### activeDirectory
**Toggle:** `pentesting.categories.activeDirectory = true;`

Windows/Active Directory exploitation.

| Tool | Description |
|------|-------------|
| `bloodhound-py` | AD relationship mapper (Python ingestor) |
| `bloodhound-ce` | BloodHound Community Edition |
| `python3Packages.impacket` | Windows protocol toolkit (psexec, secretsdump, etc.) |
| `netexec` | CrackMapExec successor (nxc) |
| `responder` | LLMNR/NBT-NS/MDNS poisoner |
| `evil-winrm` | WinRM shell |
| `kerbrute` | Kerberos brute-force / user enumeration |
| `coercer` | Windows authentication coercion (PetitPotam, etc.) |
| `smbmap` | SMB share enumeration & access checking |
| `openldap` | LDAP tools (ldapsearch, etc.) |
| `samba` | SMB tools (smbclient, rpcclient, etc.) |

### password
**Toggle:** `pentesting.categories.password = true;`

Password cracking and brute-force tools.

| Tool | Description |
|------|-------------|
| `hashcat` | GPU-accelerated password cracker |
| `john` | John the Ripper (CPU cracker) |
| `hydra` | Network login brute-forcer |
| `medusa` | Parallel network login brute-forcer |
| `crunch` | Wordlist generator |
| `seclists` | Wordlists including rockyou.txt |

### wireless
**Toggle:** `pentesting.categories.wireless = true;`

Wireless network testing (requires compatible WiFi adapter).

| Tool | Description |
|------|-------------|
| `aircrack-ng` | WiFi cracking suite |
| `kismet` | Wireless network detector/sniffer |
| `wifite2` | Automated WiFi attack tool |
| `reaver` | WPS brute-force |
| `hostapd` | Access point daemon |
| `iw` | Wireless configuration tool |

### forensics
**Toggle:** `pentesting.categories.forensics = true;`

Digital forensics and incident response.

| Tool | Description |
|------|-------------|
| `volatility3` | Memory forensics framework |
| `binwalk` | Firmware analysis / extraction |
| `sleuthkit` | Disk forensics (fls, icat, etc.) |
| `foremost` | File carving |
| `exiftool` | Metadata extraction |
| `steghide` | Steganography |
| `stegseek` | Fast steghide cracker |

### reverseEngineering
**Toggle:** `pentesting.categories.reverseEngineering = true;`

Binary analysis and exploit development.

| Tool | Description |
|------|-------------|
| `ghidra` | NSA reverse engineering suite |
| `radare2` | CLI reverse engineering framework |
| `gdb` | GNU debugger (with GEF) |
| `python3Packages.pwntools` | CTF exploit development library |
| `python3Packages.angr` | Binary analysis framework |
| `ltrace` / `strace` | Library/system call tracing |

### mitm
**Toggle:** `pentesting.categories.mitm = true;`

Man-in-the-middle and traffic interception.

| Tool | Description |
|------|-------------|
| `bettercap` | Network attack and monitoring |
| `ettercap` | MITM attack suite |
| `dsniff` | Network auditing tools (arpspoof, etc.) |
| `responder` | LLMNR/NBT-NS poisoner |

### blueTeam
**Toggle:** `pentesting.categories.blueTeam = true;`

Defensive security and DFIR.

| Tool | Description |
|------|-------------|
| `suricata` | IDS/IPS engine |
| `snort` | Network intrusion detection |
| `yara` | Malware pattern matching |
| `clamav` | Antivirus engine |
| `lynis` | Security auditing tool |
| `zeek` | Network security monitoring |
| `chainsaw` | Windows event log analysis |
| `hayabusa-sec` | Windows event log fast forensics |
| `sigma-cli` | SIEM rule conversion |
| `lnav` | Log file navigator |

### exploitation
**Toggle:** `pentesting.categories.exploitation = true;`

Exploitation frameworks and payload tools.

| Tool | Description |
|------|-------------|
| `metasploit` | The exploitation framework |
| `exploitdb` | Exploit database + searchsploit CLI |

### postExploitation
**Toggle:** `pentesting.categories.postExploitation = true;`

Post-exploitation, tunnelling, and C2.

| Tool | Description |
|------|-------------|
| `chisel` | TCP/UDP tunnelling over HTTP |
| `ligolo-ng` | Tunnelling/pivoting tool |
| `proxychains-ng` | Force TCP through proxy |
| `sshuttle` | VPN over SSH |
| `rlwrap` | Readline wrapper for dumb shells |
| `pwncat` | Post-exploitation platform |
| `havoc` | C2 framework |
| `villain` | C2 framework (Python-based) |

### cloud
**Toggle:** `pentesting.categories.cloud = true;`

Cloud platform pentesting tools.

| Tool | Description |
|------|-------------|
| `awscli2` | AWS CLI v2 |
| `google-cloud-sdk` | gcloud, gsutil, bq |
| `azure-cli` | az CLI |
| `terraform` | IaC enumeration & misconfiguration analysis |

<div align="center">
  <img src="images/graphics/icebreaker-dividers/divider-e-dotmatrix-amber.png" width="100%"/>
</div>

## Presets

Instead of toggling categories individually, use a preset in `configuration.nix`:

```nix
pentesting.preset = "engagement";
```

### Available Presets

| Preset | Categories Enabled | Use Case |
|--------|--------------------|----------|
| `"ctf"` | network, web, password, forensics, reverseEngineering, exploitation | CTF competitions |
| `"engagement"` | network, web, activeDirectory, password, mitm, exploitation, postExploitation, cloud | Professional pentests |
| `"full"` | All 12 categories | Everything installed |
| `"blue"` | network, forensics, blueTeam | Defensive / DFIR work |

### How Presets Work

Presets use `mkDefault`, which means **individual category toggles always win**:

```nix
# Use engagement preset but disable cloud
pentesting.preset = "engagement";
pentesting.categories.cloud = false;   # This overrides the preset
```

```nix
# Use CTF preset but add wireless
pentesting.preset = "ctf";
pentesting.categories.wireless = true;  # This adds to the preset
```

### Switching Presets

```nix
# In configuration.nix:
pentesting.preset = "full";
```

Then rebuild:
```bash
nrs
```

The first rebuild after switching presets may take longer as it downloads new packages.

## Pipx Tools (Supplementary)

Some tools are broken or missing in nixpkgs. These are installed separately via pipx:

```bash
~/IceBreaker/scripts/install-pipx-tools.sh
```

See [Scripts](scripts.md) for the full list.
