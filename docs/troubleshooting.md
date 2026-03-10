```
 ┌─────────────────────────────────────────────────────────┐
 │  ICEBREAKER // FLATLINE RECOVERY                        │
 │  "The damage was done. It was irreversible."            │
 │  "...or was it?"                                        │
 └─────────────────────────────────────────────────────────┘
```

# Troubleshooting

Common issues and how to fix them. See `DEVLOG.md` for a detailed history of every bug encountered during development.

## Build Errors

### "The option 'X' does not exist"

**Cause:** You're using an option that doesn't exist in your version of nixpkgs or home-manager.

**Fix:**
```bash
# Search for the correct option name
nix search nixpkgs package-name

# Check if the package exists
nix eval nixpkgs#package-name.name
```

Common misnames — see [DEVLOG.md](../DEVLOG.md) for the full list:
- `impacket` → `python3Packages.impacket`
- `noto-fonts-emoji` → `noto-fonts-color-emoji`
- `du-dust` → `dust`
- `snmp` → `net-snmp`

### "attribute 'X' missing"

**Cause:** Package doesn't exist in nixpkgs-unstable.

**Fix:** Check if the package was removed or renamed:
```bash
ns package-name
```

If it doesn't exist, consider adding it via pipx instead:
```bash
pipx install package-name
```

### "conflicting definitions for option 'X'"

**Cause:** Two modules are trying to set the same option.

**Common case:** Stylix double-injection. If you added stylix to `home-manager.sharedModules`, remove it — the NixOS module auto-injects:
```nix
# DO NOT add to sharedModules:
# home-manager.sharedModules = [ stylix.homeModules.stylix ];
```

### Build timeout or OOM

**Cause:** Large packages (metasploit, ghidra) can be slow to build.

**Fix:**
- Increase swap space
- Build one category at a time
- Use `nrt` (test) instead of `nrs` for faster iteration

## Shell Issues

### Aliases not working ("command not found")

**Cause:** You're in bash, not zsh.

**Fix:**
```bash
exec zsh
```

Or verify your shell:
```bash
echo $SHELL       # Should be /run/current-system/sw/bin/zsh
```

### p10k prompt looks broken

**Cause:** Missing Nerd Font or terminal not configured for it.

**Fix:**
1. Ensure your terminal (Konsole) uses "JetBrainsMono Nerd Font"
2. If glyphs are boxes, the font isn't installed:
   ```bash
   fc-list | grep -i jetbrains
   ```
3. Run `p10k configure` to reconfigure

### p10k parse errors on shell start

**Cause:** Corrupted or incompatible `~/.p10k.zsh`.

**Fix:**
```bash
# Regenerate from the flake's copy
nrs

# Or reconfigure interactively
p10k configure
```

### ZSH hash errors with nix commands

**Cause:** `EXTENDED_GLOB` is enabled somewhere, making `#` a glob operator. This breaks flake refs like `~/IceBreaker#icebreaker`.

**Fix:** IceBreaker disables `EXTENDED_GLOB` by default. If you enabled it, disable it:
```bash
unsetopt EXTENDED_GLOB
```

### $TARGET / $LHOST not set in new terminals

**Cause:** `~/.target.env` doesn't exist yet.

**Fix:**
```bash
settarget 10.10.10.1
```

This creates `~/.target.env` which new shells auto-source.

## Theme Issues

### KDE black screen after rebuild

**Cause:** Stylix's Qt target conflicting with KDE Plasma 6.

**Fix:** Ensure this is set in `modules/system/stylix.nix`:
```nix
targets.qt.enable = false;
```

### Colours not applying

**Cause:** Need to log out and back in for KDE to pick up changes.

**Fix:**
1. `exec zsh` — reloads shell colours
2. Log out → log back in — applies KDE/GTK colours
3. Reboot if still not working

### FZF colour conflict

**Cause:** Custom FZF colours set alongside Stylix.

**Fix:** Remove any `programs.fzf.colors` settings. Let Stylix handle all colours.

## Nmap Issues

### nmap-init says "target not set"

**Fix:** Set the target first:
```bash
settarget 10.10.10.1
nmap-init
```

Or pass the target directly:
```bash
nmap-init 10.10.10.1
```

### nmap permission denied

**Cause:** SYN scans need raw sockets.

**Fix:** IceBreaker includes an SUID wrapper for nmap. If it's not working:
```bash
which nmap           # Should be /run/wrappers/bin/nmap
ls -la /run/wrappers/bin/nmap   # Should be setuid root
```

If the wrapper is missing, rebuild: `nrs`

## VPN Issues

### "htb: No such file or directory"

**Cause:** VPN config file not placed yet.

**Fix:**
```bash
# Download from HackTheBox/TryHackMe and save as:
cp ~/Downloads/your-config.ovpn ~/vpn/htb.ovpn
```

### VPN connected but can't reach target

**Fix:**
```bash
# Check tunnel is up
vpnstat
vpnip

# Verify routing
ip route | grep tun

# Try pinging the target
ping -c 1 $TARGET
```

## Proxychains Issues

### "proxychains.conf not found"

**Fix:** The config is created on first `nrs` rebuild by home-manager activation. If missing:
```bash
mkdir -p ~/.config/proxychains
cat > ~/.config/proxychains/proxychains.conf << 'EOF'
strict_chain
quiet_mode
proxy_dns

[ProxyList]
socks5  127.0.0.1 1080
EOF
```

## Recovery

### System won't boot after rebuild

1. Reboot
2. In GRUB, select a previous generation (arrow keys)
3. Boot into the working generation
4. Fix the config
5. Run `nrs`

### List available generations

```bash
ngen
```

### Roll back to a specific generation

```bash
sudo nix-env --profile /nix/var/nix/profiles/system --switch-generation 42
sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch
```

### Nuclear option — garbage collect everything

```bash
sudo nix-collect-garbage -d
nrs
```

This removes ALL old generations. Only the current one survives.

## Getting Help

- Check `DEVLOG.md` for historical issues and solutions
- Run `guide` for the interactive walkthrough
- Search nixpkgs issues: https://github.com/NixOS/nixpkgs/issues
- NixOS discourse: https://discourse.nixos.org
