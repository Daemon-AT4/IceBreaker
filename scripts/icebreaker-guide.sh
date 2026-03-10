#!/usr/bin/env bash
# =============================================================================
# IceBreaker — Interactive Walkthrough Guide
# A terminal-based guide for NixOS beginners using the IceBreaker flake.
#
# Usage:
#   ./scripts/icebreaker-guide.sh    (or just type 'guide' from anywhere)
# =============================================================================

set -euo pipefail

# ── Colours ──────────────────────────────────────────────────────────────────
BOLD='\033[1m'
DIM='\033[2m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
RED='\033[0;31m'
NC='\033[0m'

header() {
  echo ""
  echo -e "${BOLD}${CYAN}══════════════════════════════════════════════════════════════${NC}"
  echo -e "${BOLD}${CYAN}  $1${NC}"
  echo -e "${BOLD}${CYAN}══════════════════════════════════════════════════════════════${NC}"
  echo ""
}

subheader() {
  echo -e "${BOLD}${MAGENTA}  ── $1 ──${NC}"
  echo ""
}

info() {
  echo -e "  ${GREEN}$1${NC}"
}

dim() {
  echo -e "  ${DIM}$1${NC}"
}

warn() {
  echo -e "  ${YELLOW}$1${NC}"
}

pause() {
  echo ""
  echo -e "  ${DIM}Press Enter to continue, or 'q' to quit...${NC}"
  read -r input
  [[ "$input" == "q" || "$input" == "Q" ]] && echo "" && exit 0
}

# ── Section: Welcome ────────────────────────────────────────────────────────
section_welcome() {
  clear
  echo ""
  echo -e "${CYAN}"
  cat << 'BANNER'
    _______________  ____  ____  ______ ___    __ __ ______ ____
   /  _/ ____/ __ )/ __ \/ __ \/ ____//   |  / //_// ____// __ \
   / // /   / __  / /_/ / /_/ / __/  / /| | / ,<  / __/  / /_/ /
 _/ // /___/ /_/ / _, _/ ____/ /___ / ___ |/ /| |/ /___ / _, _/
/___/\____/_____/_/ |_/_/   /_____//_/  |_/_/ |_/_____//_/ |_|
BANNER
  echo -e "${NC}"
  echo -e "  ${DIM}\"The sky above the port was the colour of television,${NC}"
  echo -e "  ${DIM} tuned to a dead channel.\"  — William Gibson${NC}"
  echo ""
  echo -e "  IceBreaker is a ${BOLD}modular NixOS pentesting environment${NC} built as a Nix flake."
  echo ""
  echo "  Everything lives in ~/IceBreaker/ — your system is fully defined by code."
  echo "  This guide will walk you through how it all works."
  echo ""
  echo "  Sections:"
  echo -e "    ${CYAN} 1${NC}  What is NixOS?"
  echo -e "    ${CYAN} 2${NC}  IceBreaker structure"
  echo -e "    ${CYAN} 3${NC}  Rebuilding your system"
  echo -e "    ${CYAN} 4${NC}  Categories & presets"
  echo -e "    ${CYAN} 5${NC}  Target management"
  echo -e "    ${CYAN} 6${NC}  Shell functions"
  echo -e "    ${CYAN} 7${NC}  Aliases reference"
  echo -e "    ${CYAN} 8${NC}  Pipx tools (extras not in nixpkgs)"
  echo -e "    ${CYAN} 9${NC}  Updating & maintenance"
  echo -e "    ${CYAN}10${NC}  Tips & tricks"
  pause
}

# ── Section: What is NixOS ──────────────────────────────────────────────────
section_nixos() {
  header "What is NixOS?"
  echo "  NixOS is a Linux distribution built on the Nix package manager."
  echo "  Unlike Ubuntu or Arch, your entire system is defined declaratively"
  echo "  in configuration files — not by running install commands."
  echo ""
  subheader "Key Differences"
  info "Declarative:    You describe WHAT you want, not HOW to install it"
  info "Reproducible:   Same config = same system, every time"
  info "Atomic:         Rebuilds either fully succeed or fully fail"
  info "Rollback:       Every rebuild creates a new generation you can boot into"
  info "Isolated:       Packages don't conflict — each has its own dependency tree"
  echo ""
  subheader "What This Means for You"
  echo "  - You never run 'apt install' or 'pacman -S' — you add packages to .nix files"
  echo "  - If a rebuild breaks something, you can reboot and select a previous generation"
  echo "  - Your entire system can be rebuilt from scratch using just the IceBreaker folder"
  pause
}

# ── Section: IceBreaker structure ───────────────────────────────────────────────
section_structure() {
  header "IceBreaker Flake Structure"
  echo -e "  ${DIM}~/IceBreaker/${NC}"
  echo -e "  ├── flake.nix                  ${DIM}← Entry point${NC}"
  echo -e "  ├── flake.lock                 ${DIM}← Pinned dependency versions${NC}"
  echo -e "  ├── configuration.nix          ${DIM}← Your main config (toggle categories here)${NC}"
  echo -e "  ├── hardware-configuration.nix ${DIM}← Auto-generated, don't edit${NC}"
  echo -e "  │"
  echo -e "  ├── modules/system/"
  echo -e "  │   ├── base.nix               ${DIM}← Boot, KDE, users, core packages${NC}"
  echo -e "  │   ├── nix-helpers.nix         ${DIM}← Flake tooling (nh, comma, nil)${NC}"
  echo -e "  │   └── stylix.nix             ${DIM}← Theme (Rose Pine dark)${NC}"
  echo -e "  │"
  echo -e "  ├── modules/pentesting/"
  echo -e "  │   ├── default.nix             ${DIM}← Category option definitions${NC}"
  echo -e "  │   ├── network.nix             ${DIM}← nmap, masscan, wireshark, etc.${NC}"
  echo -e "  │   ├── web.nix                 ${DIM}← burpsuite, ffuf, sqlmap, dalfox${NC}"
  echo -e "  │   ├── active-directory.nix    ${DIM}← bloodhound, impacket, netexec${NC}"
  echo -e "  │   ├── password.nix            ${DIM}← hashcat, john, hydra${NC}"
  echo -e "  │   ├── wireless.nix            ${DIM}← aircrack-ng, kismet, wifite2${NC}"
  echo -e "  │   ├── forensics.nix           ${DIM}← volatility3, binwalk, sleuthkit${NC}"
  echo -e "  │   ├── reverse-engineering.nix ${DIM}← ghidra, radare2, gdb, pwntools${NC}"
  echo -e "  │   ├── mitm.nix               ${DIM}← bettercap, ettercap, dsniff${NC}"
  echo -e "  │   ├── blue-team.nix           ${DIM}← suricata, snort, yara, zeek${NC}"
  echo -e "  │   ├── exploitation.nix        ${DIM}← metasploit, exploitdb${NC}"
  echo -e "  │   ├── post-exploitation.nix   ${DIM}← chisel, ligolo-ng, havoc, villain${NC}"
  echo -e "  │   ├── cloud.nix              ${DIM}← awscli2, gcloud, azure-cli, terraform${NC}"
  echo -e "  │   └── presets.nix             ${DIM}← Preset system (ctf, engagement, etc.)${NC}"
  echo -e "  │"
  echo -e "  ├── home/"
  echo -e "  │   ├── default.nix             ${DIM}← Home-manager (git, tmux, fzf, etc.)${NC}"
  echo -e "  │   ├── zsh.nix                 ${DIM}← ZSH + oh-my-zsh + powerlevel10k + functions${NC}"
  echo -e "  │   ├── aliases.nix             ${DIM}← All shell aliases${NC}"
  echo -e "  │   └── p10k.zsh               ${DIM}← Prompt config${NC}"
  echo -e "  │"
  echo -e "  └── scripts/"
  echo -e "      ├── install-pipx-tools.sh   ${DIM}← Extra tools via pipx/gem${NC}"
  echo -e "      ├── revshell.sh             ${DIM}← Reverse shell payload generator${NC}"
  echo -e "      ├── tmux-htb.sh             ${DIM}← HTB/CTF tmux layout${NC}"
  echo -e "      ├── setup.sh                ${DIM}← First-time setup script${NC}"
  echo -e "      └── icebreaker-guide.sh         ${DIM}← This guide!${NC}"
  pause
}

# ── Section: Rebuilding ─────────────────────────────────────────────────────
section_rebuilding() {
  header "Rebuilding Your System"
  echo "  After editing any .nix file, you need to rebuild for changes to take effect."
  echo ""
  subheader "Rebuild Commands"
  info "nrs    Full rebuild — switch immediately (most common)"
  info "nrt    Test rebuild — switch but don't add boot entry"
  info "nrb    Boot rebuild — build + add boot entry, don't switch yet"
  echo ""
  subheader "What Happens During a Rebuild"
  echo "  1. Nix evaluates all your .nix files"
  echo "  2. Downloads/builds any new packages"
  echo "  3. Creates a new system generation"
  echo "  4. Switches to it (with nrs) or queues it for next boot (with nrb)"
  echo ""
  subheader "If Something Goes Wrong"
  echo "  - Reboot → select a previous generation from the GRUB menu"
  echo "  - Check recent generations: ngen"
  echo "  - Garbage collect old generations: nhc"
  echo ""
  warn "Tip: Always run 'nfc' (nix flake check) before rebuilding to catch errors early."
  pause
}

# ── Section: Categories & presets ───────────────────────────────────────────
section_categories() {
  header "Categories & Presets"
  echo "  IceBreaker organises tools into categories that you toggle on/off in"
  echo -e "  ${BOLD}configuration.nix${NC}."
  echo ""
  subheader "Available Categories (12)"
  echo -e "  ${GREEN}network${NC}            nmap, masscan, rustscan, wireshark, dns tools"
  echo -e "  ${GREEN}web${NC}                burpsuite, ffuf, sqlmap, nuclei, nikto, dalfox"
  echo -e "  ${GREEN}activeDirectory${NC}    bloodhound, impacket, netexec, evil-winrm"
  echo -e "  ${GREEN}password${NC}           hashcat, john, hydra, crunch + seclists"
  echo -e "  ${GREEN}wireless${NC}           aircrack-ng, kismet, wifite2, hostapd"
  echo -e "  ${GREEN}forensics${NC}          volatility3, binwalk, sleuthkit, foremost"
  echo -e "  ${GREEN}reverseEngineering${NC} ghidra, radare2, gdb, pwntools, cutter"
  echo -e "  ${GREEN}mitm${NC}              bettercap, ettercap, dsniff"
  echo -e "  ${GREEN}blueTeam${NC}           suricata, snort, yara, zeek, chainsaw"
  echo -e "  ${GREEN}exploitation${NC}       metasploit, exploitdb/searchsploit"
  echo -e "  ${GREEN}postExploitation${NC}   chisel, ligolo-ng, proxychains, havoc, villain"
  echo -e "  ${GREEN}cloud${NC}              awscli2, google-cloud-sdk, azure-cli, terraform"
  echo ""
  subheader "Toggling Categories"
  echo "  Edit ~/IceBreaker/configuration.nix:"
  echo ""
  echo -e "    ${DIM}pentesting.categories.activeDirectory = true;${NC}"
  echo -e "    ${DIM}pentesting.categories.cloud           = true;${NC}"
  echo ""
  echo "  Then run: nrs"
  echo ""
  subheader "Presets (Quick Profiles)"
  echo "  Instead of toggling individually, use a preset:"
  echo ""
  echo -e "  ${CYAN}\"ctf\"${NC}         network, web, password, forensics, reverseEngineering, exploitation"
  echo -e "  ${CYAN}\"engagement\"${NC}  network, web, activeDirectory, password, mitm, exploitation, postExploitation, cloud"
  echo -e "  ${CYAN}\"full\"${NC}        all 12 categories"
  echo -e "  ${CYAN}\"blue\"${NC}        network, forensics, blueTeam"
  echo ""
  echo "  Usage in configuration.nix:"
  echo -e "    ${DIM}pentesting.preset = \"engagement\";${NC}"
  echo ""
  warn "Individual category toggles always override presets."
  pause
}

# ── Section: Target Management ──────────────────────────────────────────────
section_targets() {
  header "Target Management"
  echo "  IceBreaker includes shell functions for managing engagement targets."
  echo "  These set environment variables and create structured directories."
  echo ""
  subheader "Setting a Target"
  echo -e "  ${GREEN}\$${NC} settarget 10.10.10.1           ${DIM}# auto-detects LHOST, LPORT=4444${NC}"
  echo -e "  ${GREEN}\$${NC} settarget 10.10.10.1 9001      ${DIM}# custom LPORT${NC}"
  echo ""
  echo "  Sets: \$TARGET, \$LHOST (from tun0/tun1/eth0), \$LPORT"
  echo "  Persists to ~/.target.env — new shells pick it up automatically."
  echo ""
  subheader "Creating a New Box"
  echo -e "  ${GREEN}\$${NC} newbox forest 10.10.10.161"
  echo ""
  echo "  Creates:"
  echo -e "    ~/targets/forest/"
  echo -e "    ├── nmap/       ${DIM}← nmap output files${NC}"
  echo -e "    ├── loot/       ${DIM}← captured data${NC}"
  echo -e "    ├── exploits/   ${DIM}← exploit scripts${NC}"
  echo -e "    ├── www/        ${DIM}← files to serve via HTTP${NC}"
  echo -e "    ├── flags.txt   ${DIM}← captured flags${NC}"
  echo -e "    ├── creds.txt   ${DIM}← found credentials${NC}"
  echo -e "    └── notes.md    ${DIM}← engagement notes template${NC}"
  echo ""
  echo "  Also symlinks ~/targets/current → the new box."
  echo ""
  subheader "Logging Flags & Credentials"
  echo -e "  ${GREEN}\$${NC} flag abc123def456              ${DIM}# appends timestamped flag${NC}"
  echo -e "  ${GREEN}\$${NC} flag abc123 \"user.txt\"          ${DIM}# with description${NC}"
  echo -e "  ${GREEN}\$${NC} cred admin Password1 ssh        ${DIM}# username:password (service)${NC}"
  pause
}

# ── Section: Shell Functions ────────────────────────────────────────────────
section_functions() {
  header "Shell Functions"
  echo "  These functions are available in every ZSH session."
  echo ""
  subheader "Nmap Helpers"
  echo -e "  ${GREEN}nmap-init${NC} [target]              ${DIM}Initial scan: -sV -sC -O --open${NC}"
  echo -e "  ${GREEN}nmap-allports${NC} [target]          ${DIM}Full port scan: -p- -T4 --open${NC}"
  echo -e "  ${GREEN}nmap-targeted${NC} <target> <ports>  ${DIM}Targeted: -sV -sC -p<ports>${NC}"
  echo ""
  echo "  All save output to ./nmap/ (auto-created)."
  echo "  Uses \$TARGET if no argument given (except nmap-targeted)."
  echo ""
  subheader "Hashcat Mode Reference"
  echo -e "  ${GREEN}hcmode${NC}         ${DIM}Print all common hashcat modes${NC}"
  echo -e "  ${GREEN}hcmode ntlm${NC}    ${DIM}Filter by keyword${NC}"
  echo -e "  ${GREEN}hcmode kerb${NC}    ${DIM}Show Kerberos-related modes${NC}"
  echo ""
  subheader "Proxy Management"
  echo -e "  ${GREEN}setproxy${NC} [port]  ${DIM}Set proxychains SOCKS5 port (default 1080)${NC}"
  echo ""
  subheader "Reverse Shell Generator"
  echo -e "  ${GREEN}revshell bash${NC}       ${DIM}Generate bash reverse shell payload${NC}"
  echo -e "  ${GREEN}revshell --list${NC}     ${DIM}Show available types${NC}"
  echo -e "  ${GREEN}revshell --all${NC}      ${DIM}Print all payloads${NC}"
  echo ""
  echo "  Uses \$LHOST and \$LPORT from settarget."
  echo ""
  subheader "HTB Tmux Layout"
  echo -e "  ${GREEN}htb-tmux${NC}   ${DIM}Launch 3-pane tmux: main + notes + listener info${NC}"
  pause
}

# ── Section: Aliases ────────────────────────────────────────────────────────
section_aliases() {
  header "Aliases Reference"

  subheader "NixOS / Flake"
  echo -e "  ${GREEN}nrs${NC}     Rebuild & switch       ${DIM}nh os switch ~/IceBreaker${NC}"
  echo -e "  ${GREEN}nrt${NC}     Test rebuild            ${DIM}nh os test ~/IceBreaker${NC}"
  echo -e "  ${GREEN}nrb${NC}     Boot rebuild            ${DIM}nh os boot ~/IceBreaker${NC}"
  echo -e "  ${GREEN}nfu${NC}     Flake update            ${DIM}nix flake update${NC}"
  echo -e "  ${GREEN}nfc${NC}     Flake check             ${DIM}nix flake check ~/IceBreaker${NC}"
  echo -e "  ${GREEN}nfsh${NC}    Flake show              ${DIM}nix flake show ~/IceBreaker${NC}"
  echo -e "  ${GREEN}ns${NC}      Search packages         ${DIM}nix search nixpkgs${NC}"
  echo -e "  ${GREEN}nhc${NC}     Garbage collect         ${DIM}nh clean all --keep 3${NC}"
  echo -e "  ${GREEN}nrun${NC}    Run without installing  ${DIM}nix run nixpkgs#${NC}"
  echo -e "  ${GREEN}ngen${NC}    List generations        ${DIM}nix-env --list-generations ...${NC}"
  echo ""

  subheader "Navigation & Listing"
  echo -e "  ${GREEN}..${NC}      cd ..        ${GREEN}...${NC}  cd ../..     ${GREEN}....${NC}  cd ../../.."
  echo -e "  ${GREEN}ls${NC}      lsd          ${GREEN}ll${NC}   lsd -la      ${GREEN}la${NC}    lsd -a"
  echo -e "  ${GREEN}lt${NC}      lsd --tree   ${GREEN}llt${NC}  lsd --tree -l"
  echo ""

  subheader "Better Defaults"
  echo -e "  ${GREEN}cat${NC}     bat          ${GREEN}grep${NC}  grep --color  ${GREEN}find${NC}  fd"
  echo -e "  ${GREEN}top${NC}     btop         ${GREEN}ps${NC}    procs         ${GREEN}df${NC}    duf"
  echo -e "  ${GREEN}du${NC}      dust"
  echo ""

  subheader "VPN"
  echo -e "  ${GREEN}htb${NC}       Connect to HackTheBox VPN"
  echo -e "  ${GREEN}thm${NC}       Connect to TryHackMe VPN"
  echo -e "  ${GREEN}vpnstop${NC}   Kill OpenVPN"
  echo -e "  ${GREEN}vpnstat${NC}   Show tunnel interfaces"
  echo -e "  ${GREEN}vpnip${NC}     Show VPN IP (tun0/tun1)"
  echo ""

  subheader "Network"
  echo -e "  ${GREEN}myip${NC}        Public IP    ${GREEN}localip${NC}   Local IPs"
  echo -e "  ${GREEN}ports${NC}       All ports    ${GREEN}listen${NC}    Listening ports"
  echo -e "  ${GREEN}nmap-quick${NC}  Quick scan   ${GREEN}nmap-full${NC}  Full port scan"
  echo -e "  ${GREEN}nmap-udp${NC}    Top 200 UDP  ${GREEN}nmap-vuln${NC}  Vuln scripts"
  echo ""

  subheader "Listeners & Shells"
  echo -e "  ${GREEN}rlisten${NC}    rlwrap nc -lvnp 4444"
  echo -e "  ${GREEN}rlisten2${NC}   rlwrap nc -lvnp 4445"
  echo -e "  ${GREEN}serve${NC}      python3 -m http.server 8080"
  echo -e "  ${GREEN}revshell${NC}   Reverse shell generator"
  echo -e "  ${GREEN}htb-tmux${NC}   HTB tmux layout"
  echo ""

  subheader "Misc"
  echo -e "  ${GREEN}guide${NC}    This guide       ${GREEN}c${NC}       clear"
  echo -e "  ${GREEN}reload${NC}   Restart zsh      ${GREEN}py${NC}      python3"
  echo -e "  ${GREEN}pyhttp${NC}   HTTP server      ${GREEN}ctf${NC}     cd ~/ctf"
  pause
}

# ── Section: Pipx tools ────────────────────────────────────────────────────
section_pipx() {
  header "Pipx Tools (Extras)"
  echo "  Some pentesting tools are broken or missing in nixpkgs."
  echo "  The pipx installer script handles these separately."
  echo ""
  subheader "Running the Installer"
  echo -e "  ${GREEN}\$${NC} ~/IceBreaker/scripts/install-pipx-tools.sh"
  echo -e "  ${GREEN}\$${NC} ~/IceBreaker/scripts/install-pipx-tools.sh --update"
  echo ""
  subheader "What It Installs"
  echo -e "  ${CYAN}Network/Exploit:${NC}  impacket, netexec"
  echo -e "  ${CYAN}Active Directory:${NC} certipy-ad, bloodhound-ce, ldapdomaindump, sprayhound"
  echo -e "  ${CYAN}Post-Exploit:${NC}     lsassy, donpapi, manspider, pygpoabuse, pwncat-cs"
  echo -e "  ${CYAN}Web:${NC}              mitmproxy, arjun, droopescan, xsstrike"
  echo -e "  ${CYAN}OSINT:${NC}            shodan"
  echo -e "  ${CYAN}Recon:${NC}            recon-ng, theHarvester, dnstwist"
  echo -e "  ${CYAN}Password:${NC}         name-that-hash, haiti-hash, cupp"
  echo -e "  ${CYAN}Ruby Gems:${NC}        evil-winrm"
  echo ""
  warn "Run this after every 'nrs' rebuild to ensure tools are available."
  pause
}

# ── Section: Updating ──────────────────────────────────────────────────────
section_updating() {
  header "Updating & Maintenance"

  subheader "Update Nixpkgs (Get Latest Packages)"
  echo -e "  ${GREEN}\$${NC} nfu                       ${DIM}# updates flake.lock${NC}"
  echo -e "  ${GREEN}\$${NC} nrs                       ${DIM}# rebuild with new packages${NC}"
  echo ""

  subheader "Update a Single Flake Input"
  echo -e "  ${GREEN}\$${NC} nix flake update stylix   ${DIM}# update just stylix${NC}"
  echo ""

  subheader "Garbage Collection"
  echo "  Old system generations accumulate over time and use disk space."
  echo ""
  echo -e "  ${GREEN}\$${NC} nhc                       ${DIM}# keep 3 most recent, delete rest${NC}"
  echo -e "  ${GREEN}\$${NC} nix-collect-garbage -d    ${DIM}# nuclear option: delete everything${NC}"
  echo ""

  subheader "Check for Errors Before Rebuilding"
  echo -e "  ${GREEN}\$${NC} nfc                       ${DIM}# nix flake check${NC}"
  echo ""

  subheader "Rollback"
  echo "  If a rebuild breaks something:"
  echo "  1. Reboot"
  echo "  2. In GRUB, select an older generation"
  echo "  3. Fix the config, then run nrs again"
  pause
}

# ── Section: Tips ───────────────────────────────────────────────────────────
section_tips() {
  header "Tips & Tricks"

  echo -e "  ${CYAN}1.${NC} Search for packages before adding them:"
  echo -e "     ${GREEN}\$${NC} ns <name>                ${DIM}# nix search nixpkgs <name>${NC}"
  echo ""
  echo -e "  ${CYAN}2.${NC} Try a package without installing:"
  echo -e "     ${GREEN}\$${NC} nix run nixpkgs#cowsay"
  echo ""
  echo -e "  ${CYAN}3.${NC} Open a shell with a package temporarily:"
  echo -e "     ${GREEN}\$${NC} nix shell nixpkgs#python312"
  echo ""
  echo -e "  ${CYAN}4.${NC} Find which package provides a command:"
  echo -e "     ${GREEN}\$${NC} , <command>              ${DIM}# comma runs it and finds the package${NC}"
  echo ""
  echo -e "  ${CYAN}5.${NC} Check package names carefully — nixpkgs-unstable renames things often."
  echo -e "     See ~/IceBreaker/DEVLOG.md (Session 1) for a list of known name pitfalls."
  echo ""
  echo -e "  ${CYAN}6.${NC} Seclists are at: /run/current-system/sw/share/seclists"
  echo ""
  echo -e "  ${CYAN}7.${NC} VPN configs go in ~/vpn/ — use 'htb' or 'thm' aliases to connect."
  echo ""
  echo -e "  ${CYAN}8.${NC} Start an engagement quickly:"
  echo -e "     ${GREEN}\$${NC} newbox forest 10.10.10.161"
  echo -e "     ${GREEN}\$${NC} htb-tmux"
  echo -e "     ${GREEN}\$${NC} nmap-init"
  echo ""
  echo -e "  ${CYAN}9.${NC} Edit .nix files, run nrs. That's the entire workflow."
  echo ""

  echo -e "${BOLD}${CYAN}══════════════════════════════════════════════════════════════${NC}"
  echo -e "${BOLD}${CYAN}  Connection Established${NC}"
  echo -e "${BOLD}${CYAN}══════════════════════════════════════════════════════════════${NC}"
  echo ""
  echo -e "  ${DIM}\"Case jacked in and found himself surrounded by${NC}"
  echo -e "  ${DIM} the nonspace of the matrix.\"${NC}"
  echo ""
  echo "  You're jacked in. Start hacking."
  echo "  Run 'guide' any time to see this again."
  echo ""
}

# ── Main ────────────────────────────────────────────────────────────────────
section_welcome
section_nixos
section_structure
section_rebuilding
section_categories
section_targets
section_functions
section_aliases
section_pipx
section_updating
section_tips
