# ┌─────────────────────────────────────────────────────────────┐
# │  IceBreaker — Shell Aliases                                │
# │  All ZSH aliases live here. Imported by home/default.nix.  │
# │                                                            │
# │  Tips:                                                     │
# │  - Use $HOME instead of ~ (tilde won't expand in quotes)   │
# │  - Aliases that need to modify the current shell (export,  │
# │    cd) should be ZSH functions in home/zsh.nix instead     │
# │  - Group related aliases under section headers             │
# │  - After editing, rebuild with: nrs                        │
# └─────────────────────────────────────────────────────────────┘
{ config, lib, ... }:

{
  programs.zsh.shellAliases = {
    # ── Navigation ──────────────────────────────────────────────
    ".."   = "cd ..";
    "..."  = "cd ../..";
    "...." = "cd ../../..";

    # ── Listing (lsd / eza) ─────────────────────────────────────
    "ls"  = "lsd";
    "ll"  = "lsd -la";
    "la"  = "lsd -a";
    "lt"  = "lsd --tree";
    "llt" = "lsd --tree -l";

    # ── Safety ──────────────────────────────────────────────────
    "cp" = "cp -i";
    "mv" = "mv -i";
    "rm" = "rm -I";  # prompt when removing > 3 files

    # ── Better defaults ─────────────────────────────────────────
    "cat"   = "bat --paging=never";
    "less"  = "bat --paging=always";
    "grep"  = "grep --color=auto";
    "find"  = "fd";
    "top"   = "btop";
    "ps"    = "procs";
    "df"    = "duf";
    "du"    = "dust";

    # ── NixOS / Flake helpers ───────────────────────────────────
    # Rebuild system (uses absolute path — works from any directory)
    "nrs"  = "nh os switch $HOME/IceBreaker";
    "nrt"  = "nh os test  $HOME/IceBreaker";
    "nrb"  = "nh os boot  $HOME/IceBreaker";

    # Flake management
    "nfu"  = "cd ~/IceBreaker && nix flake update && cd -";
    "nfc"  = "nix flake check ~/IceBreaker";
    "nfsh" = "nix flake show ~/IceBreaker";

    # Nix search & index
    "ns"   = "nix search nixpkgs";
    "nsi"  = "nix-index";   # rebuild the index

    # Garbage collect (keep 3 most recent generations)
    "nhc"  = "nh clean all --keep 3";

    # Run a package without installing
    "nrun" = "nix run nixpkgs#";

    # NixOS generations
    "ngen" = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";

    # ── VPN — HackTheBox / TryHackMe ────────────────────────────
    # Place your .ovpn files in ~/vpn/ and adjust filenames below
    "htb" = "sudo openvpn ~/vpn/htb.ovpn";
    "thm" = "sudo openvpn ~/vpn/thm.ovpn";
    "vpnstop" = "sudo pkill openvpn";
    "vpnstat" = "ip tuntap show";

    # ── Network helpers ─────────────────────────────────────────
    "myip"     = "curl -s https://ifconfig.me";
    "localip"  = "ip -4 addr show | grep inet | awk '{print $2}' | cut -d/ -f1 | grep -v 127";
    "ports"    = "ss -tulpn";
    "listen"   = "sudo ss -tulpn | grep LISTEN";

    # Quick nmap presets (for full nmap wrappers see zsh.nix functions)
    "nmap-quick"  = "nmap -sV -sC -O --open";
    "nmap-full"   = "nmap -sV -sC -O -p- --open -T4";
    "nmap-udp"    = "sudo nmap -sU --top-ports 200";
    "nmap-vuln"   = "nmap -sV --script vuln";
    "nmap-smb"    = "nmap -p 445 --script smb-vuln*";

    # ── HTB / CTF shortcuts ─────────────────────────────────────
    "ctf"    = "cd ~/ctf";
    "targets"= "cd ~/targets";
    "notes"  = "nvim ~/targets/notes.md";

    # Extract common archive formats
    "untar"  = "tar -xvf";
    "ungzip" = "tar -xzvf";
    "unbzip" = "tar -xjvf";

    # Python
    "py"     = "python3";
    "pyhttp" = "python3 -m http.server";
    "pyhttp-upload" = "python3 -m uploadserver";

    # ── Listeners ───────────────────────────────────────────────
    # rlwrap gives readline (history, editing) to netcat listeners
    "rlisten"  = "rlwrap nc -lvnp 4444";
    "rlisten2" = "rlwrap nc -lvnp 4445";

    # ── VPN IP ──────────────────────────────────────────────────
    # Shows tun0 IP, falls back to tun1
    "vpnip" = "ip -4 addr show tun0 2>/dev/null | grep inet | awk '{print $2}' | cut -d/ -f1 | grep . || ip -4 addr show tun1 2>/dev/null | grep inet | awk '{print $2}' | cut -d/ -f1";

    # Quick HTTP server on port 8080
    "serve" = "python3 -m http.server 8080";

    # ── IceBreaker scripts ──────────────────────────────────────
    "revshell"   = "$HOME/IceBreaker/scripts/revshell.sh";
    "htb-tmux"   = "$HOME/IceBreaker/scripts/tmux-htb.sh";
    "guide"      = "$HOME/IceBreaker/scripts/icebreaker-guide.sh";

    # ── HTB Pirate runbook (auto-exploitation + benchmark harness) ─
    # NixOS-safe: /etc/hosts is managed declaratively; phase 0 detects
    # the declarative hosts file, prints the networking.extraHosts snippet,
    # and continues with --dc-ip flags + local krb5.conf.
    #
    # Usage:
    #   htb-pirate --target 10.129.1.12
    #   htb-pirate --target 10.129.1.12 --use-bench      # wrap with icebreaker-bench
    #   htb-pirate --target 10.129.1.12 --phases 0-9     # just recon + foothold
    #   htb-pirate --target 10.129.1.12 --tool-soak      # chain + tool battery
    #   htb-pirate --target 10.129.1.12 --tool-soak-only # tool battery only (no chain)
    # See docs/htb-pirate.md for methodology + per-phase resource comparison,
    # docs/ligolo-ng.md for the WEB01 pivot + evil-winrm creds reference.
    "htb-pirate" = "$HOME/IceBreaker/scripts/htb-pirate.sh";

    # ── HTB Garfield runbook (auto-exploitation + benchmark harness) ─
    # Fully self-contained: 22 phases from recon → RODC Golden Ticket →
    # Key List attack → Administrator shell. Operator-guided pauses for
    # the ligolo tunnel upload and the RODC post-exploit (Rubeus
    # asktgs /keyList) — everything else is automated. NixOS-safe.
    #
    # Usage:
    #   htb-garfield --target 10.129.78.103
    #   htb-garfield --target 10.129.78.103 --use-bench      # wrap with icebreaker-bench
    #   htb-garfield --target 10.129.78.103 --phases 0-10    # pre-tunnel chain only
    #   htb-garfield --target 10.129.78.103 --auto           # skip operator prompts
    #   htb-garfield --target 10.129.78.103 --tool-soak      # chain + tool battery
    #   htb-garfield --target 10.129.78.103 --tool-soak-only # tool battery only
    "htb-garfield" = "$HOME/IceBreaker/scripts/htb-garfield.sh";

    # ── ligolo-ng fetcher ───────────────────────────────────────
    # Mirrors ligolo-ng release assets into $HOME/hacktools/ligolo-ng/
    # Usage:
    #   ligolo-fetch                 # default: latest release, Pirate-relevant platforms
    #   ligolo-fetch --mode latest   # latest release, every platform
    #   ligolo-fetch --mode all      # every historical release (~2-3 GB)
    # See docs/ligolo-ng.md for the Pirate-specific tunnel walkthrough.
    "ligolo-fetch" = "$HOME/IceBreaker/scripts/ligolo-fetch.sh";

    # ── Performance benchmarking (honours research) ──────────────
    # See docs/benchmarking.md for methodology.
    # Usage:
    #   bench-idle nixos-idle-1                       # 5-min idle baseline
    #   bench-load nixos-nmap-1 -- nmap -sV -p- 10.0.0.1   # workload run
    #   bench-diff ~/icebreaker-bench/A ~/icebreaker-bench/B
    "bench"      = "icebreaker-bench";
    "bench-idle" = "icebreaker-bench idle     --duration 300 --interval 5 --label";
    "bench-load" = "icebreaker-bench workload --duration 300 --interval 5 --label";
    "bench-diff" = "icebreaker-bench compare";

    # ── Misc ────────────────────────────────────────────────────
    "c"      = "clear";
    "h"      = "history";
    "reload" = "exec zsh";
    "path"   = "echo $PATH | tr ':' '\\n'";
    "now"    = "date +'%Y-%m-%d %H:%M:%S'";
    "week"   = "date +%V";

    # ── Pentesting tool aliases ─────────────────────────────────
    # netexec binary is 'nxc' upstream — both names now work
    "netexec" = "nxc";

    # ── Add your aliases below ──────────────────────────────────
    # example: "burp" = "burpsuite &";
  };
}
