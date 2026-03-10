```
    _______________  ____  ____  ______ ___    __ __ ______ ____
   /  _/ ____/ __ )/ __ \/ __ \/ ____//   |  / //_// ____// __ \
   / // /   / __  / /_/ / /_/ / __/  / /| | / ,<  / __/  / /_/ /
 _/ // /___/ /_/ / _, _/ ____/ /___ / ___ |/ /| |/ /___ / _, _/
/___/\____/_____/_/ |_/_/   /_____//_/  |_/_/ |_/_____//_/ |_|

  ///  N I X O S   P E N T E S T I N G   E N V I R O N M E N T  ///
  -------------------------------------------------------------------
   "The sky above the port was the colour of television,
    tuned to a dead channel."  — William Gibson, Neuromancer
```

# IceBreaker

A fully modular NixOS pentesting environment built as a Nix flake. Your entire workstation — tools, shell, theme, aliases, workflow automation — defined in code.

One command rebuilds everything. One git push backs it all up. One git clone restores it on any machine.

## What's Inside

- **12 pentesting categories** you toggle on/off — from network recon to cloud pentesting
- **Preset system** — `ctf`, `engagement`, `full`, `blue` profiles that enable groups of categories
- **50+ shell aliases** — nix helpers, nmap presets, listeners, VPN shortcuts
- **9 ZSH functions** — target management, nmap wrappers, hashcat reference, proxy config
- **Reverse shell generator** — 14 payload types, auto-uses your VPN IP
- **HTB tmux layout** — 3-pane workspace with notes + listener
- **Rose Pine dark theme** — system-wide via Stylix (terminal, GTK, Qt)
- **Powerlevel10k prompt** — powerline style with Rose Pine colours
- **Pipx installer** — 25+ Python tools that aren't in nixpkgs

## Quick Start

```bash
# Clone the repo
git clone https://github.com/YOUR_USERNAME/icebreaker.git ~/IceBreaker

# Run first-time setup
cd ~/IceBreaker && ./scripts/setup.sh

# Start a new shell
exec zsh

# Install pipx tools
~/IceBreaker/scripts/install-pipx-tools.sh

# Read the interactive guide
guide
```

## Documentation

| Guide | Description |
|-------|-------------|
| [Getting Started](getting-started.md) | Installation, first rebuild, basic usage |
| [GitHub Setup](github-setup.md) | Upload to GitHub, rebuild from GitHub, secrets |
| [Categories & Presets](categories.md) | All 12 tool categories and preset profiles |
| [Aliases Reference](aliases.md) | Complete alias listing with descriptions |
| [Shell Functions](shell-functions.md) | Target management, nmap helpers, hcmode |
| [Scripts](scripts.md) | revshell, tmux layout, setup, pipx installer |
| [Engagement Workflow](workflow.md) | Step-by-step: box setup to flag capture |
| [Customisation](customisation.md) | Add packages, create categories, change theme |
| [Theming](theming.md) | Stylix, Rose Pine, fonts, prompt customisation |
| [Troubleshooting](troubleshooting.md) | Common issues and fixes |

## Architecture

```
flake.nix                         <- Entry point
├── configuration.nix             <- Toggle categories here
├── modules/system/
│   ├── base.nix                  <- Boot, KDE, users, core packages
│   ├── nix-helpers.nix           <- Flake tooling (nh, comma, nil)
│   └── stylix.nix                <- System-wide theming
├── modules/pentesting/
│   ├── default.nix               <- Options tree (12 categories)
│   ├── network.nix .. cloud.nix  <- Category modules
│   └── presets.nix               <- Preset system
├── home/
│   ├── default.nix               <- Home-manager (git, tmux, fzf, etc.)
│   ├── zsh.nix                   <- ZSH + plugins + workflow functions
│   ├── aliases.nix               <- Shell aliases
│   └── p10k.zsh                  <- Powerlevel10k prompt config
└── scripts/
    ├── setup.sh                  <- First-time setup
    ├── install-pipx-tools.sh     <- Python/Ruby tool installer
    ├── revshell.sh               <- Reverse shell generator
    ├── tmux-htb.sh               <- HTB tmux layout
    └── icebreaker-guide.sh           <- Interactive guide
```

## Requirements

- NixOS (nixos-unstable channel)
- x86_64-linux
- Internet connection for first build

## License

Do whatever you want with it. Hack the planet.
