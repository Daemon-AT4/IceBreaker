```
 ┌─────────────────────────────────────────────────────────┐
 │  ICEBREAKER // HOTKEY NEURAL MAP                        │
 │  "He knew every circuit in the deck by heart."          │
 │                                        — Neuromancer    │
 └─────────────────────────────────────────────────────────┘
```

# Aliases Reference

All aliases are defined in `home/aliases.nix` and available in every ZSH session.

## NixOS / Flake Management

| Alias | Command | Description |
|-------|---------|-------------|
| `nrs` | `nh os switch ~/IceBreaker` | Full rebuild and switch (most common) |
| `nrt` | `nh os test ~/IceBreaker` | Test rebuild (switch but no boot entry) |
| `nrb` | `nh os boot ~/IceBreaker` | Build + boot entry, don't switch yet |
| `nfu` | `cd ~/IceBreaker && nix flake update && cd -` | Update all flake inputs |
| `nfc` | `nix flake check ~/IceBreaker` | Check for evaluation errors |
| `nfsh` | `nix flake show ~/IceBreaker` | Show flake outputs |
| `ns` | `nix search nixpkgs` | Search for packages |
| `nsi` | `nix-index` | Rebuild the command-not-found index |
| `nhc` | `nh clean all --keep 3` | Garbage collect, keep 3 generations |
| `nrun` | `nix run nixpkgs#` | Run a package without installing |
| `ngen` | `sudo nix-env --list-generations ...` | List system generations |

## Navigation & Listing

| Alias | Command | Description |
|-------|---------|-------------|
| `..` | `cd ..` | Up one directory |
| `...` | `cd ../..` | Up two directories |
| `....` | `cd ../../..` | Up three directories |
| `ls` | `lsd` | Modern ls with icons |
| `ll` | `lsd -la` | Long listing with hidden files |
| `la` | `lsd -a` | List all including hidden |
| `lt` | `lsd --tree` | Tree view |
| `llt` | `lsd --tree -l` | Tree view with details |

## Better Defaults

| Alias | Command | Description |
|-------|---------|-------------|
| `cat` | `bat --paging=never` | Syntax-highlighted file viewer |
| `less` | `bat --paging=always` | Paged file viewer |
| `grep` | `grep --color=auto` | Coloured grep |
| `find` | `fd` | Modern find replacement |
| `top` | `btop` | Modern process viewer |
| `ps` | `procs` | Modern ps replacement |
| `df` | `duf` | Modern disk usage |
| `du` | `dust` | Modern directory size |

## Safety

| Alias | Command | Description |
|-------|---------|-------------|
| `cp` | `cp -i` | Prompt before overwrite |
| `mv` | `mv -i` | Prompt before overwrite |
| `rm` | `rm -I` | Prompt when removing >3 files |

## VPN

| Alias | Command | Description |
|-------|---------|-------------|
| `htb` | `sudo openvpn ~/vpn/htb.ovpn` | Connect to HackTheBox |
| `thm` | `sudo openvpn ~/vpn/thm.ovpn` | Connect to TryHackMe |
| `vpnstop` | `sudo pkill openvpn` | Kill VPN connection |
| `vpnstat` | `ip tuntap show` | Show tunnel interfaces |
| `vpnip` | `ip ... tun0 \|\| ... tun1` | Show your VPN IP address |

## Network

| Alias | Command | Description |
|-------|---------|-------------|
| `myip` | `curl -s https://ifconfig.me` | Show public IP |
| `localip` | `ip -4 addr show ...` | Show local IPs |
| `ports` | `ss -tulpn` | Show all open ports |
| `listen` | `sudo ss -tulpn \| grep LISTEN` | Show listening ports |

## Nmap Presets

| Alias | Command | Description |
|-------|---------|-------------|
| `nmap-quick` | `nmap -sV -sC -O --open` | Version + scripts + OS detection |
| `nmap-full` | `nmap -sV -sC -O -p- --open -T4` | All ports with scripts |
| `nmap-udp` | `sudo nmap -sU --top-ports 200` | Top 200 UDP ports |
| `nmap-vuln` | `nmap -sV --script vuln` | Vulnerability scripts |
| `nmap-smb` | `nmap -p 445 --script smb-vuln*` | SMB vulnerability scripts |

## Listeners & Shells

| Alias | Command | Description |
|-------|---------|-------------|
| `rlisten` | `rlwrap nc -lvnp 4444` | Readline-wrapped listener on 4444 |
| `rlisten2` | `rlwrap nc -lvnp 4445` | Readline-wrapped listener on 4445 |
| `serve` | `python3 -m http.server 8080` | Quick HTTP server on 8080 |
| `revshell` | `~/IceBreaker/scripts/revshell.sh` | Reverse shell generator |
| `htb-tmux` | `~/IceBreaker/scripts/tmux-htb.sh` | HTB tmux layout |

## HTB / CTF Shortcuts

| Alias | Command | Description |
|-------|---------|-------------|
| `ctf` | `cd ~/ctf` | Jump to CTF directory |
| `targets` | `cd ~/targets` | Jump to targets directory |
| `notes` | `nvim ~/targets/notes.md` | Open notes |

## Python

| Alias | Command | Description |
|-------|---------|-------------|
| `py` | `python3` | Python 3 shortcut |
| `pyhttp` | `python3 -m http.server` | HTTP server (default port) |
| `pyhttp-upload` | `python3 -m uploadserver` | HTTP server with upload |

## Archive

| Alias | Command | Description |
|-------|---------|-------------|
| `untar` | `tar -xvf` | Extract tar |
| `ungzip` | `tar -xzvf` | Extract tar.gz |
| `unbzip` | `tar -xjvf` | Extract tar.bz2 |

## Misc

| Alias | Command | Description |
|-------|---------|-------------|
| `guide` | `~/IceBreaker/scripts/icebreaker-guide.sh` | Interactive guide |
| `c` | `clear` | Clear screen |
| `h` | `history` | Show history |
| `reload` | `exec zsh` | Restart shell |
| `path` | `echo $PATH \| tr ':' '\n'` | Show PATH entries |
| `now` | `date +'%Y-%m-%d %H:%M:%S'` | Current datetime |
| `week` | `date +%V` | Current week number |

## Adding Your Own Aliases

Edit `home/aliases.nix` and add to the `shellAliases` set:

```nix
"myalias" = "some command here";
```

Then rebuild: `nrs`

**Tips:**
- Use `$HOME` instead of `~` in paths (tilde doesn't expand in double quotes)
- Test the command manually before adding it as an alias
- Check for conflicts with existing aliases: `alias | grep myalias`
