# ┌─────────────────────────────────────────────────────────────┐
# │  IceBreaker — Main Configuration                           │
# │  This is your primary config file. It imports all modules  │
# │  and lets you toggle pentesting categories on/off.         │
# │                                                            │
# │  After editing, rebuild with:  nrs                         │
# │  Check for errors first:       nfc                         │
# └─────────────────────────────────────────────────────────────┘
{ config, pkgs, inputs, ... }:

{
  imports = [
    # System foundation — boot, XFCE, users, core packages
    ./modules/system/base.nix

    # Nix tooling — nh, comma, formatters, nix-index
    ./modules/system/nix-helpers.nix

    # Theming — Rose Pine dark via Stylix (system-wide)
    ./modules/system/stylix.nix

    # Pentesting options tree + all category modules
    ./modules/pentesting/default.nix

    # To add a new system module, import it here:
    # ./modules/system/my-module.nix
  ];

  # ============================================================
  # Pentesting Categories — Toggle as needed for each engagement
  # ============================================================
  #
  # Each category maps to a .nix file in modules/pentesting/
  # that installs the relevant packages. Set true to install,
  # false to skip. Rebuild (nrs) after changing.
  #
  # Or use a preset to enable groups at once:
  #   "ctf"        — network, web, password, forensics, reverseEngineering, exploitation
  #   "engagement" — network, web, activeDirectory, password, mitm, exploitation, postExploitation, cloud
  #   "full"       — all 12 categories
  #   "blue"       — network, forensics, blueTeam
  #
  # Individual toggles below ALWAYS override presets.
  #
  # ============================================================
  pentesting = {
    enable = true;

    # Uncomment ONE preset, or use manual toggles below:
    # preset = "ctf";
    # preset = "engagement";
    # preset = "full";
    # preset = "blue";

    categories = {
      # Core recon: nmap, masscan, rustscan, wireshark, dns tools
      network          = true;

      # Web testing: burpsuite, ffuf, feroxbuster, sqlmap, nikto, dalfox
      web              = true;

      # Windows/AD: bloodhound, impacket, netexec, enum4linux-ng, evil-winrm
      activeDirectory  = true;

      # Cracking: hashcat, john, hydra, crunch + seclists wordlists
      password         = true;

      # Wireless: aircrack-ng, kismet, wifite2, hostapd (needs compatible adapter)
      wireless         = false;

      # DFIR: volatility3, binwalk, sleuthkit, foremost, exiftool
      forensics        = false;

      # RE: ghidra, radare2, gdb+gef, pwntools, angr
      reverseEngineering = false;

      # MITM: bettercap, ettercap, dsniff, responder
      mitm             = false;

      # Defensive: suricata, snort, yara, zeek, chainsaw, hayabusa
      blueTeam         = false;

      # Exploitation: metasploit, exploitdb/searchsploit
      exploitation     = false;

      # Post-exploitation: chisel, ligolo-ng, proxychains, havoc, villain
      postExploitation = true;

      # Cloud: awscli2, google-cloud-sdk, azure-cli, terraform
      cloud            = false;
    };
  };

  # ============================================================
  # System identity
  # ============================================================
  # Change hostName if you fork this for a different machine.
  # Must also update the flake output name in flake.nix to match.
  networking.hostName = "icebreaker";

  # ============================================================
  # Bluetooth — opt-in (off by default in modules/system/base.nix)
  # Flip both to true on a laptop install. Leave false for VMs
  # and headless boxes to keep the surface area minimal.
  # ============================================================
  # hardware.bluetooth.enable = true;
  # services.blueman.enable   = true;

  # NixOS release version — do NOT change unless doing a full migration.
  # See: https://nixos.org/manual/nixos/stable/#sec-upgrading
  system.stateVersion = "25.11";
}
