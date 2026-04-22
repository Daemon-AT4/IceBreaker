```
    _______________  ____  ____  ______ ___    __ __ ______ ____
   /  _/ ____/ __ )/ __ \/ __ \/ ____//   |  / //_// ____// __ \
   / // /   / __  / /_/ / /_/ / __/  / /| | / ,<  / __/  / /_/ /
 _/ // /___/ /_/ / _, _/ ____/ /___ / ___ |/ /| |/ /___ / _, _/
/___/\____/_____/_/ |_/_/   /_____//_/  |_/_/ |_/_____//_/ |_|

  ///  D O C U M E N T A T I O N   I N D E X  ///
  -------------------------------------------------
   "Information wants to be free."
                  — Stewart Brand
```

---

## // QUICK START

```bash
nix-shell -p git                                          # get git on fresh NixOS
git clone https://github.com/YOUR_USERNAME/IceBreaker.git ~/IceBreaker
# Change "archangel" to your NixOS username in: base.nix, nix-helpers.nix, home/default.nix, flake.nix
cd ~/IceBreaker && ./scripts/setup.sh                     # handles everything
sudo reboot                                               # reboot into IceBreaker
exec zsh                                                  # start configured shell
~/IceBreaker/scripts/install-pipx-tools.sh                # install pipx tools
guide                                                     # interactive walkthrough
```

Default user is `archangel` — change it to match the username you created during NixOS installation.

---

## // WHAT'S INSIDE

```
 OFFENSIVE                              ENVIRONMENT
 ─────────────────────────────────      ─────────────────────────────────
 12 pentesting categories               Rose Pine dark — system-wide
 4 preset profiles                      Powerlevel10k powerline prompt
 14 reverse shell payload types         VPN IP + ping latency in prompt
 9 workflow shell functions             Alacritty terminal, Nerd Fonts
 50+ shell aliases                      15 tmux plugins, session persist
 25+ pipx tools                         XFCE desktop, LightDM greeter
 HTB tmux 3-pane layout                 x86_64 + aarch64 outputs
```

---

## // DOCUMENTATION INDEX

| Guide | Description |
|-------|-------------|
| [Getting Started](getting-started.md) | Installation, first rebuild, basic usage |
| [GitHub Setup](github-setup.md) | Push to GitHub, rebuild from GitHub, secrets |
| [Categories & Presets](categories.md) | All 12 tool categories and preset profiles |
| [Aliases Reference](aliases.md) | Complete alias listing with descriptions |
| [Shell Functions](shell-functions.md) | settarget, newbox, flag, cred, nmap helpers |
| [Scripts](scripts.md) | revshell, tmux layout, setup, pipx installer |
| [Engagement Workflow](workflow.md) | Step-by-step: box setup to flag capture |
| [Customisation](customisation.md) | Add packages, create categories, change theme |
| [Theming](theming.md) | Stylix, Rose Pine, fonts, prompt customisation |
| [Troubleshooting](troubleshooting.md) | Common issues and fixes |
| [DEVLOG](../DEVLOG.md) | Development history — every bug and how it was fixed |

---

## // ARCHITECTURE

```
flake.nix                         <<< entry point
|
+-- configuration.nix             <<< toggle categories here
+-- modules/system/
|   +-- base.nix                  <<< boot, XFCE, LightDM, users, packages
|   +-- nix-helpers.nix           <<< nh, comma, nil, nix-index
|   +-- stylix.nix                <<< Rose Pine theming
+-- modules/pentesting/
|   +-- default.nix               <<< options tree (12 categories)
|   +-- network.nix .. cloud.nix  <<< category modules
|   +-- presets.nix               <<< preset system
+-- home/
|   +-- default.nix               <<< home-manager (git, tmux, alacritty, fzf)
|   +-- zsh.nix                   <<< ZSH + plugins + workflow functions
|   +-- aliases.nix               <<< shell aliases
|   +-- p10k.zsh                  <<< powerlevel10k prompt config
+-- scripts/
    +-- setup.sh                  <<< first-time setup
    +-- install-pipx-tools.sh     <<< Python/Ruby tool installer
    +-- revshell.sh               <<< reverse shell generator
    +-- tmux-htb.sh               <<< HTB tmux layout
    +-- icebreaker-guide.sh       <<< interactive guide
```

---

## // REQUIREMENTS

- NixOS (any channel — the flake pins nixos-unstable)
- x86_64-linux or aarch64-linux
- VMware, QEMU/KVM, VirtualBox, or bare metal
- Internet connection for first build

---

```
 LICENSE: Do whatever you want with it. Hack the planet.
```
