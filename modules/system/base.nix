# ┌─────────────────────────────────────────────────────────────┐
# │  IceBreaker — System Foundation                            │
# │  Boot, desktop, networking, users, and base packages.      │
# │  Everything here is always installed regardless of which   │
# │  pentesting categories are enabled.                        │
# │                                                            │
# │  To add a package that should ALWAYS be available, add it  │
# │  to environment.systemPackages below.                      │
# │  For pentesting-specific tools, use a category module      │
# │  in modules/pentesting/ instead.                           │
# └─────────────────────────────────────────────────────────────┘
{ config, pkgs, ... }:

{
  # ============================================================
  # Boot — change device if your disk isn't /dev/sda
  # For UEFI systems, switch to systemd-boot:
  #   boot.loader.systemd-boot.enable = true;
  #   boot.loader.efi.canTouchEfiVariables = true;
  # ============================================================
  boot.loader.grub.enable       = true;
  boot.loader.grub.device       = "/dev/sda";
  boot.loader.grub.useOSProber  = true;
  boot.kernelPackages            = pkgs.linuxPackages_latest;

  # ============================================================
  # Networking
  # ============================================================
  networking.networkmanager.enable = true;

  # Firewall disabled for pentesting — re-enable for production
  networking.firewall.enable = false;

  # IP forwarding — needed for MITM, routing, pivoting
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward"            = 1;
    "net.ipv6.conf.all.forwarding"   = 1;
    # Let non-root users do raw socket ops (nmap SYN scans etc.)
    "net.ipv4.ping_group_range"      = "0 2147483647";
  };

  # ============================================================
  # Locale / Timezone — change for your region
  # ============================================================
  time.timeZone      = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS        = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT    = "en_GB.UTF-8";
    LC_MONETARY       = "en_GB.UTF-8";
    LC_NAME           = "en_GB.UTF-8";
    LC_NUMERIC        = "en_GB.UTF-8";
    LC_PAPER          = "en_GB.UTF-8";
    LC_TELEPHONE      = "en_GB.UTF-8";
    LC_TIME           = "en_GB.UTF-8";
  };

  # ============================================================
  # Desktop — XFCE (lightweight, reliable, Stylix-friendly)
  # ============================================================
  services.xserver.enable = true;

  # LightDM display manager (default for XFCE, lightweight)
  # NOTE: LightDM options are under services.xserver.displayManager — NOT
  # services.displayManager (that namespace only has sddm/gdm currently).
  services.xserver.displayManager.lightdm = {
    enable = true;
    greeters.slick = {
      enable = true;
      draw-user-backgrounds = true;
    };
  };

  # XFCE desktop environment
  services.xserver.desktopManager.xfce.enable = true;

  # Default session — tells LightDM which desktop to launch.
  # Without this, LightDM may fail with "Failed to start session"
  # because it doesn't know which session type to use.
  services.displayManager.defaultSession = "xfce";

  # Keyboard layout — change "gb" to "us", "de", etc.
  services.xserver.xkb = {
    layout  = "gb";
    variant = "";
  };
  console.keyMap = "uk";

  # ============================================================
  # Audio — PipeWire (modern replacement for PulseAudio)
  # ============================================================
  services.pulseaudio.enable = false;
  security.rtkit.enable      = true;
  services.pipewire = {
    enable            = true;
    alsa.enable       = true;
    alsa.support32Bit = true;
    pulse.enable      = true;
  };

  # ============================================================
  # Printing
  # ============================================================
  services.printing.enable = true;

  # ============================================================
  # Virtualisation — hypervisor guest tools
  # ============================================================
  # Enable the ONE matching your hypervisor. The others MUST be false
  # or commented out — enabling the wrong guest tools causes systemd
  # service failures and potential boot issues.
  #
  # Nix flakes use pure evaluation, so we CANNOT auto-detect the
  # hypervisor at build time (builtins.pathExists / builtins.readFile
  # on /sys/class/dmi/ paths is impure and will fail without --impure).
  # Instead, set the correct option here for your VM platform.
  #
  # Supported platforms:
  #   VMware  (Fusion, Workstation, ESXi)  → virtualisation.vmware.guest.enable
  #   QEMU/KVM (UTM, virt-manager, Proxmox) → services.qemuGuest.enable
  #   VirtualBox                            → virtualisation.virtualbox.guest.enable
  #
  # SPICE agent (clipboard, display resize) should only be enabled for
  # QEMU/KVM VMs using SPICE display — it fails on VMware/VirtualBox.
  # ============================================================

  # ── VMware (Fusion, Workstation, ESXi) ────────────────────────
  # Installs open-vm-tools for clipboard, drag-drop, display resize
  virtualisation.vmware.guest.enable = true;

  # ── QEMU/KVM (UTM, virt-manager, Proxmox) ────────────────────
  # Uncomment these and set vmware to false if running on QEMU/KVM:
  # virtualisation.vmware.guest.enable = false;
  # services.qemuGuest.enable          = true;
  # services.spice-vdagentd.enable     = true;   # only for SPICE display

  # ── VirtualBox ────────────────────────────────────────────────
  # Uncomment this and set vmware to false if running on VirtualBox:
  # virtualisation.vmware.guest.enable          = false;
  # virtualisation.virtualbox.guest.enable      = true;

  # Docker — container runtime for tooling and labs
  virtualisation.docker = {
    enable           = true;
    autoPrune.enable = true;   # auto-clean unused images
  };

  # ============================================================
  # SSH server
  # ============================================================
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin             = "no";
      PasswordAuthentication      = true;
    };
  };

  # ============================================================
  # Users — change "archangel" to your username
  # Also update: home/default.nix, flake.nix (users.USERNAME)
  # ============================================================
  users.users.archangel = {
    isNormalUser = true;
    description  = "archangel";
    shell        = pkgs.zsh;
    # Default password for first login — CHANGE THIS after setup!
    # Run:  passwd
    # This is set via initialPassword so it only applies if no password
    # has been set yet. Once you change it with passwd, NixOS won't
    # overwrite it on rebuild.
    initialPassword = "icebreaker";
    extraGroups  = [
      "wheel"           # sudo access
      "networkmanager"  # manage wifi/vpn
      "docker"          # run containers without sudo
      "wireshark"       # packet capture without root
      "video"
      "audio"
      "dialout"         # serial ports (IoT/embedded testing)
    ];
    # User-specific GUI apps (not needed system-wide)
    # mousepad + xfce4-terminal are included by XFCE automatically
    packages = with pkgs; [
      # Add user GUI apps here, e.g.: obsidian  flameshot  chromium
    ];
  };

  # ============================================================
  # System-wide programs & wrappers
  # ============================================================
  # Firefox is managed by home-manager (home/firefox.nix) — profile, bookmarks, settings
  programs.zsh.enable       = true;
  programs.wireshark.enable = true;   # also adds the wireshark group

  # SUID wrapper so nmap can do SYN/OS scans without sudo
  # Add more wrappers here if tools need raw socket access
  security.wrappers = {
    nmap = {
      setuid = true;
      owner  = "root";
      group  = "root";
      source = "${pkgs.nmap}/bin/nmap";
    };
  };

  # ============================================================
  # Base packages — always installed
  # ============================================================
  # Add tools here that should be available regardless of which
  # pentesting categories are enabled. For category-specific tools,
  # add them to the relevant modules/pentesting/*.nix file instead.
  #
  # Find packages:  nix search nixpkgs <name>
  # Test first:     nix run nixpkgs#<name>
  # ============================================================
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # ── Editors ─────────────────────────────────────────────
    vim
    neovim
    nano

    # ── Terminal utilities ──────────────────────────────────
    tmux
    screen
    htop
    btop
    tree
    file
    rlwrap     # readline wrapper (used by rlisten aliases)

    # ── File management / modern CLI replacements ───────────
    ranger     # terminal file manager
    lsd        # modern ls with icons
    eza        # another ls replacement
    fd         # modern find
    ripgrep    # modern grep (rg)
    bat        # cat with syntax highlighting
    fzf        # fuzzy finder
    zoxide     # smart cd (z)

    # ── Archive tools ───────────────────────────────────────
    unzip  zip  p7zip  gzip  xz

    # ── Data / scripting ────────────────────────────────────
    jq         # JSON processor
    yq         # YAML processor
    python3    # scripting / exploit dev
    ruby       # ruby tools (evil-winrm gem, etc.)

    # ── Python tool isolation ───────────────────────────────
    pipx       # install Python CLIs in isolated venvs

    # ── Network basics (always needed) ──────────────────────
    wget  curl  git
    netcat-gnu socat
    iproute2   net-tools
    dnsutils   whois

    # ── Clipboard (X11) ────────────────────────────────────
    xclip  xsel

    # ── VPN support ─────────────────────────────────────────
    openvpn
    wireguard-tools

    # ── Fonts (Nerd Fonts for p10k prompt glyphs) ──────────
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.hack

    # ── Add your always-available tools below ───────────────
    # example: obsidian  flameshot  chromium
  ];

  # OpenVPN3 integration for HackTheBox / TryHackMe VPN profiles
  programs.openvpn3.enable = true;

  # GnuPG agent (key management + SSH agent)
  programs.gnupg.agent = {
    enable           = true;
    enableSSHSupport = true;
  };

  # Enable default font packages (stylix handles the theme fonts)
  fonts.enableDefaultPackages = true;
}
