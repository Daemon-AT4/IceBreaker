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
    "revshell" = "$HOME/IceBreaker/scripts/revshell.sh";
    "htb-tmux" = "$HOME/IceBreaker/scripts/tmux-htb.sh";
    "guide"    = "$HOME/IceBreaker/scripts/icebreaker-guide.sh";

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
