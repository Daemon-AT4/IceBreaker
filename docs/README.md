<!-- markdownlint-disable -->
<div align="center">

<!-- ════════════════════════════════════════════════════════════════════════ -->
<!--  D Λ Σ M Ө П   //   I C E B R E A K E R   //   D O C S   I N D E X     -->
<!-- ════════════════════════════════════════════════════════════════════════ -->

```
╔══════════════════════════════════════════════════════════════════════════╗
║  $: DΛΣMӨП  ▌  cat /etc/daemon/docs.manifest  ▌  DAEMON-SEC // EYES ONLY ║
╚══════════════════════════════════════════════════════════════════════════╝
```
<p align="center">
  <img src="images/graphics/icebreaker-banner.png" alt="icebreaker banner"/>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/%24%3A_D%CE%9B%CE%A3M%D3%A8%D0%9F-signed-cbf7ad?style=flat-square&labelColor=0a0e14"/>
  <img src="https://img.shields.io/badge/CLEARANCE-TS%2F%2FSCI-eb6f92?style=flat-square&labelColor=0a0e14"/>
  <img src="https://img.shields.io/badge/CHANNEL-dead-7ee8fa?style=flat-square&labelColor=0a0e14"/>
  <img src="https://img.shields.io/badge/TRANSMISSION-live-cbf7ad?style=flat-square&labelColor=0a0e14"/>
</p>

<a href="https://github.com/daemonbreaker/IceBreaker"><img src="https://readme-typing-svg.demolab.com?font=JetBrains+Mono&weight=500&size=17&duration=4000&pause=1000&color=9CCFD8&center=true&vCenter=true&width=680&lines=%22Information+wants+to+be+free.%22+%E2%80%94+Stewart+Brand;%3E+loading+manifest...;%3E+12+guides+%2B+1+devlog+online." alt="Docs typewriter"/></a>

<br/>

<p align="center">
  <img src="https://img.shields.io/badge/DOCS-index-cbf7ad?style=for-the-badge&labelColor=0a0e14"/>
  <img src="https://img.shields.io/badge/GUIDES-11-c4a7e7?style=for-the-badge&labelColor=0a0e14"/>
  <img src="https://img.shields.io/badge/DEVLOG-1-524f67?style=for-the-badge&labelColor=0a0e14"/>
  <img src="https://img.shields.io/badge/STATE-live-cbf7ad?style=for-the-badge&labelColor=0a0e14"/>
  <a href="../README.md"><img src="https://img.shields.io/badge/%E2%86%A9_main_README-eb6f92?style=for-the-badge&labelColor=0a0e14"/></a>
</p>

<!-- Original slant banner preserved as secondary signature -->

```
▓▒░ ──────────────────────────────────────────────────────────────────── ░▒▓

 ██╗ ██████╗███████╗██████╗ ██████╗ ███████╗ █████╗ ██╗  ██╗███████╗██████╗
 ██║██╔════╝██╔════╝██╔══██╗██╔══██╗██╔════╝██╔══██╗██║ ██╔╝██╔════╝██╔══██╗
 ██║██║     █████╗  ██████╔╝██████╔╝█████╗  ███████║█████╔╝ █████╗  ██████╔╝
 ██║██║     ██╔══╝  ██╔══██╗██╔══██╗██╔══╝  ██╔══██║██╔═██╗ ██╔══╝  ██╔══██╗
 ██║╚██████╗███████╗██████╔╝██║  ██║███████╗██║  ██║██║  ██╗███████╗██║  ██║
 ╚═╝ ╚═════╝╚══════╝╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝

▓▒░ ── D Λ Σ M Ө П  ·  D O C S  ·  I N D E X  ·  L I V E ── ░▒▓
```

</div>

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

<table align="center">
<tr>
<td valign="top" width="50%">

<h3 align="center">▓▒░ <code>OFFENSIVE</code> ░▒▓</h3>

<p align="center">
<img src="https://img.shields.io/badge/%E2%80%A2_12-pentesting_categories-eb6f92?style=flat-square&labelColor=0a0e14"/><br/>
<img src="https://img.shields.io/badge/%E2%80%A2_4-preset_profiles-eb6f92?style=flat-square&labelColor=0a0e14"/><br/>
<img src="https://img.shields.io/badge/%E2%80%A2_14-reverse_shell_payloads-eb6f92?style=flat-square&labelColor=0a0e14"/><br/>
<img src="https://img.shields.io/badge/%E2%80%A2_9-workflow_shell_functions-eb6f92?style=flat-square&labelColor=0a0e14"/><br/>
<img src="https://img.shields.io/badge/%E2%80%A2_50%2B-shell_aliases-eb6f92?style=flat-square&labelColor=0a0e14"/><br/>
<img src="https://img.shields.io/badge/%E2%80%A2_25%2B-pipx_tools-eb6f92?style=flat-square&labelColor=0a0e14"/><br/>
<img src="https://img.shields.io/badge/%E2%80%A2_HTB_tmux-3--pane_layout-eb6f92?style=flat-square&labelColor=0a0e14"/>
</p>

</td>
<td valign="top" width="50%">

<h3 align="center">▓▒░ <code>ENVIRONMENT</code> ░▒▓</h3>

<p align="center">
<img src="https://img.shields.io/badge/%E2%80%A2_Rose_Pine-system--wide_dark-c4a7e7?style=flat-square&labelColor=0a0e14"/><br/>
<img src="https://img.shields.io/badge/%E2%80%A2_Powerlevel10k-powerline_prompt-c4a7e7?style=flat-square&labelColor=0a0e14"/><br/>
<img src="https://img.shields.io/badge/%E2%80%A2_Prompt-VPN_IP_%2B_ping-c4a7e7?style=flat-square&labelColor=0a0e14"/><br/>
<img src="https://img.shields.io/badge/%E2%80%A2_Alacritty-Nerd_Fonts-c4a7e7?style=flat-square&labelColor=0a0e14"/><br/>
<img src="https://img.shields.io/badge/%E2%80%A2_tmux-15_plugins_%2B_persist-c4a7e7?style=flat-square&labelColor=0a0e14"/><br/>
<img src="https://img.shields.io/badge/%E2%80%A2_XFCE-LightDM_greeter-c4a7e7?style=flat-square&labelColor=0a0e14"/><br/>
<img src="https://img.shields.io/badge/%E2%80%A2_flake-x86__64_%2B_aarch64-c4a7e7?style=flat-square&labelColor=0a0e14"/>
</p>

</td>
</tr>
</table>

---

## // DOCUMENTATION INDEX

<div align="center">

| # | Guide | Badge | What's inside |
|--:|-------|-------|---------------|
| 01 | [Getting Started](getting-started.md) | <img src="https://img.shields.io/badge/BOOT_SEQUENCE-install-c4a7e7?style=flat-square&labelColor=0a0e14"/> | Installation, first rebuild, basic usage |
| 02 | [GitHub Setup](github-setup.md) | <img src="https://img.shields.io/badge/UPLINK-git-c4a7e7?style=flat-square&labelColor=0a0e14"/> | Push to GitHub, rebuild from GitHub, secrets |
| 03 | [Categories & Presets](categories.md) | <img src="https://img.shields.io/badge/WEAPONS_MANIFEST-arsenal-eb6f92?style=flat-square&labelColor=0a0e14"/> | All 12 tool categories and preset profiles |
| 04 | [Aliases Reference](aliases.md) | <img src="https://img.shields.io/badge/SHORTHAND-shell-cbf7ad?style=flat-square&labelColor=0a0e14"/> | Complete alias listing with descriptions |
| 05 | [Shell Functions](shell-functions.md) | <img src="https://img.shields.io/badge/RUN_PROTOCOLS-shell-cbf7ad?style=flat-square&labelColor=0a0e14"/> | settarget, newbox, flag, cred, nmap helpers |
| 06 | [Scripts](scripts.md) | <img src="https://img.shields.io/badge/PAYLOADS-scripts-eb6f92?style=flat-square&labelColor=0a0e14"/> | revshell, tmux layout, setup, pipx installer |
| 07 | [Engagement Workflow](workflow.md) | <img src="https://img.shields.io/badge/ENGAGEMENT-runbook-ffb347?style=flat-square&labelColor=0a0e14"/> | Step-by-step: box setup to flag capture |
| 08 | [Customisation](customisation.md) | <img src="https://img.shields.io/badge/MODIFY_THE_RIG-config-c4a7e7?style=flat-square&labelColor=0a0e14"/> | Add packages, create categories, change theme |
| 09 | [Theming](theming.md) | <img src="https://img.shields.io/badge/VISUAL_LAYER-theme-c4a7e7?style=flat-square&labelColor=0a0e14"/> | Stylix, Rose Pine, fonts, prompt customisation |
| 10 | [Troubleshooting](troubleshooting.md) | <img src="https://img.shields.io/badge/FLATLINE_RECOVERY-rescue-eb6f92?style=flat-square&labelColor=0a0e14"/> | Common issues and fixes |
| 11 | [Benchmarking](benchmarking.md) | <img src="https://img.shields.io/badge/EMPIRICAL_PROOF-benchmark-ffb347?style=flat-square&labelColor=0a0e14"/> | NixOS vs Kali — methodology & full data |
| ∙∙ | [DEVLOG](../DEVLOG.md) | <img src="https://img.shields.io/badge/DEVLOG-history-524f67?style=flat-square&labelColor=0a0e14"/> | Development history — every bug and how it was fixed |

</div>

---

## // ARCHITECTURE

```
 ░▒▓ S Y S T E M   W I R I N G ▓▒░

 flake.nix                             ◉  entry point
  │
  ├── configuration.nix                ⚙  toggle categories here
  ├── modules/system/
  │   ├── base.nix                     ▸  boot, XFCE, LightDM, users, packages
  │   ├── nix-helpers.nix              ▸  nh, comma, nil, nix-index
  │   └── stylix.nix                   ▸  Rose Pine theming
  ├── modules/pentesting/
  │   ├── default.nix                  ☰  options tree (12 categories)
  │   ├── network.nix .. cloud.nix     ⚔  category modules
  │   └── presets.nix                  ☰  preset system
  ├── home/
  │   ├── default.nix                  ◈  home-manager (git, tmux, alacritty, fzf)
  │   ├── zsh.nix                      ◈  ZSH + plugins + workflow functions
  │   ├── aliases.nix                  ◈  shell aliases
  │   └── p10k.zsh                     ◈  powerlevel10k prompt config
  └── scripts/
      ├── setup.sh                     ▶  first-time setup
      ├── install-pipx-tools.sh        ▶  Python/Ruby tool installer
      ├── revshell.sh                  ▶  reverse shell generator
      ├── tmux-htb.sh                  ▶  HTB tmux layout
      └── icebreaker-guide.sh          ▶  interactive guide
```

---

## // REQUIREMENTS

<p align="center">
  <img src="https://img.shields.io/badge/NIXOS-any_channel-c4a7e7?style=for-the-badge&logo=nixos&logoColor=cbf7ad&labelColor=0a0e14"/>
  <img src="https://img.shields.io/badge/x86__64-linux-7ee8fa?style=for-the-badge&labelColor=0a0e14"/>
  <img src="https://img.shields.io/badge/aarch64-linux-7ee8fa?style=for-the-badge&labelColor=0a0e14"/>
  <img src="https://img.shields.io/badge/VMware_%2F_QEMU_%2F_VBox_%2F_bare-supported-cbf7ad?style=for-the-badge&labelColor=0a0e14"/>
  <img src="https://img.shields.io/badge/internet-first_build-ffb347?style=for-the-badge&labelColor=0a0e14"/>
</p>

- NixOS (any channel — the flake pins nixos-unstable)
- x86_64-linux or aarch64-linux
- VMware, QEMU/KVM, VirtualBox, or bare metal
- Internet connection for first build

---

<div align="center">

```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃  ░▒▓█  C L A S S I F I E D   ·   EYES ONLY   ·   DAEMON-SEC  █▓▒░      ┃
┃                                                                          ┃
┃         ░░  LICENCE :: Hack the planet.  ░░                              ┃
┃         ░░  Do whatever you want with it. ░░                             ┃
┃                                                                          ┃
┃  ░▒▓█  D E C L A S S I F I E D   ·   open access   ·   forever  █▓▒░    ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```



<p align="center">
  <img src="https://img.shields.io/badge/ALL_SYSTEMS-operational-cbf7ad?style=for-the-badge&labelColor=0a0e14"/>
  <img src="https://img.shields.io/badge/SIGNATURE-%24%3A_D%CE%9B%CE%A3M%D3%A8%D0%9F-c4a7e7?style=for-the-badge&labelColor=0a0e14"/>
  <img src="https://img.shields.io/badge/UPLINK-stable-7ee8fa?style=for-the-badge&labelColor=0a0e14"/>
</p>

<p align="center">
  <img src="images/graphics/Avatar.jpg" alt="alt text" width="200" height="200"/>
</p>
<sub><i>▓▒░ docs layer — jacked in · signed: $: DΛΣMӨП ░▒▓</i></sub>

</div>
