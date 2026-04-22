# ┌─────────────────────────────────────────────────────────────┐
# │  IceBreaker — XFCE Ricing, Rofi, Dunst                    │
# │                                                            │
# │  Keyboard shortcuts (set via xfconf-query on activation):  │
# │    Super+Space    → rofi app launcher (drun)               │
# │    Super+R        → rofi run prompt                        │
# │    Super+W        → rofi window switcher                   │
# │    Super+F        → rofi file browser                      │
# │    Super+Return   → Alacritty                              │
# │    Ctrl+Alt+T     → Alacritty                              │
# │    Super+E        → Thunar file manager                    │
# │    Print          → Flameshot GUI                          │
# │    Shift+Print    → Flameshot region                       │
# │    Super+L        → lock screen                            │
# └─────────────────────────────────────────────────────────────┘
{ config, pkgs, lib, ... }:

let
  # ── Rose Pine dark palette ─────────────────────────────────────
  rp = {
    base    = "#191724";
    surface = "#1f1d2e";
    overlay = "#26233a";
    muted   = "#6e6a86";
    subtle  = "#908caa";
    text    = "#e0def4";
    love    = "#eb6f92";
    gold    = "#f6c177";
    pine    = "#31748f";
    foam    = "#9ccfd8";
    iris    = "#c4a7e7";
  };

  # ── Rofi Rose Pine theme ───────────────────────────────────────
  rofiTheme = pkgs.writeText "rose-pine.rasi" ''
    /* Rose Pine Dark — IceBreaker Rofi theme */
    * {
      bg:      ${rp.base};
      surface: ${rp.surface};
      overlay: ${rp.overlay};
      fg:      ${rp.text};
      muted:   ${rp.muted};
      accent:  ${rp.iris};
      foam:    ${rp.foam};
      love:    ${rp.love};
      gold:    ${rp.gold};
      background-color: transparent;
      text-color:       @fg;
    }

    window {
      background-color: @bg;
      border:           2px solid;
      border-color:     @accent;
      border-radius:    10px;
      padding:          0;
      width:            660px;
    }

    mainbox {
      background-color: transparent;
      padding:          0;
      spacing:          0;
    }

    inputbar {
      background-color: @surface;
      border-radius:    10px 10px 0 0;
      padding:          14px 16px;
      spacing:          10px;
      children:         [ prompt, entry ];
    }

    prompt {
      background-color: transparent;
      text-color:       @accent;
      font:             "JetBrainsMono Nerd Font Bold 12";
    }

    entry {
      background-color: transparent;
      text-color:       @fg;
      placeholder:      "Search...";
      placeholder-color: @muted;
    }

    listview {
      background-color: @bg;
      padding:          8px;
      spacing:          2px;
      fixed-height:     true;
      lines:            8;
      scrollbar:        true;
    }

    element {
      background-color: transparent;
      border-radius:    6px;
      padding:          8px 12px;
      spacing:          10px;
      orientation:      horizontal;
    }

    element normal.normal,
    element alternate.normal {
      background-color: transparent;
      text-color:       @fg;
    }

    element selected.normal {
      background-color: @overlay;
      text-color:       @foam;
    }

    element-icon {
      background-color: transparent;
      size:             1.5em;
    }

    element-text {
      background-color: transparent;
      text-color:       inherit;
      vertical-align:   0.5;
    }

    mode-switcher {
      background-color: @surface;
      border-radius:    0 0 10px 10px;
      padding:          6px 10px;
      spacing:          4px;
    }

    button {
      background-color: transparent;
      border-radius:    4px;
      padding:          4px 14px;
      text-color:       @muted;
    }

    button selected {
      background-color: @overlay;
      text-color:       @accent;
    }

    scrollbar {
      background-color: @surface;
      border-radius:    4px;
      handle-color:     @muted;
      handle-width:     4px;
      width:            6px;
      margin:           0 2px;
    }
  '';

in
{
  # ── Extra packages ───────────────────────────────────────────────
  home.packages = with pkgs; [
    papirus-icon-theme   # icon theme (Papirus-Dark — dark variant)
    flameshot            # screenshot tool (Print shortcut)
    xdotool              # needed by some rofi modes
    polybar              # status bar (replaces XFCE top panel)
  ];

  # ── Disable Stylix targets we manage ourselves ─────────────────
  # These are home-manager scoped targets — must live here, not in stylix.nix
  stylix.targets.dunst.enable = false;   # we set our own dunst theme below
  stylix.targets.rofi.enable  = false;   # we set our own rofi theme below

  # ── Rofi — Application launcher ────────────────────────────────
  programs.rofi = {
    enable   = true;
    terminal = "${pkgs.alacritty}/bin/alacritty";
    theme    = "${rofiTheme}";
    extraConfig = {
      modi                = "drun,run,window,filebrowser";
      show-icons          = true;
      drun-display-format = "{name}";
      display-drun        = "  Apps";
      display-run         = "  Run";
      display-window      = "󰖯  Windows";
      display-filebrowser = "  Files";
      icon-theme          = "Papirus-Dark";
      sidebar-mode        = true;
      sort                = true;
      matching            = "fuzzy";
      steal-focus         = false;
    };
  };

  # ── Dunst — Notification daemon (replaces xfce4-notifyd) ───────
  services.dunst = {
    enable = true;
    settings = {
      global = {
        width            = "(240, 420)";
        height           = 220;
        offset           = "16x50";
        origin           = "top-right";
        transparency     = 8;
        frame_width      = 2;
        frame_color      = rp.iris;
        corner_radius    = 8;
        gap_size         = 6;
        font             = "JetBrainsMono Nerd Font 11";
        line_height      = 2;
        markup           = "full";
        format           = "<b>%s</b>\\n%b";
        alignment        = "left";
        vertical_alignment = "center";
        show_age_threshold = 60;
        word_wrap        = "yes";
        ignore_newline   = "no";
        sort             = true;
        icon_theme       = "Papirus-Dark,Adwaita";
        enable_recursive_icon_lookup = true;
        icon_position    = "left";
        min_icon_size    = 32;
        max_icon_size    = 64;
        sticky_history   = "yes";
        history_length   = 20;
        show_indicators  = "yes";
        mouse_left_click   = "close_current";
        mouse_middle_click = "do_action, close_current";
        mouse_right_click  = "close_all";
      };

      urgency_low = {
        background  = rp.surface;
        foreground  = rp.text;
        frame_color = rp.muted;
        timeout     = 4;
      };

      urgency_normal = {
        background  = rp.surface;
        foreground  = rp.text;
        frame_color = rp.iris;
        timeout     = 8;
      };

      urgency_critical = {
        background  = rp.overlay;
        foreground  = rp.love;
        frame_color = rp.love;
        timeout     = 0;    # stay until dismissed
      };
    };
  };

  # ── Polybar — Rose Pine top bar (replaces XFCE panel-1) ────────
  # VMware-safe: solid colours only, no transparency, no GPU effects.
  # Autostarts via XDG (XFCE session picks it up on login).
  # Keyboard shortcut to reload: Super+P (set below in xfconf).

  # Launch script — kills old instance then starts fresh
  xdg.configFile."polybar/launch.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      killall -q polybar || true
      while pgrep -u "$UID" -x polybar >/dev/null; do sleep 0.2; done
      polybar top 2>/tmp/polybar.log &
    '';
  };

  # XDG autostart — XFCE session manager runs this on login
  xdg.configFile."autostart/polybar.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Polybar
    Comment=IceBreaker status bar
    Exec=${config.xdg.configHome}/polybar/launch.sh
    Hidden=false
    X-GNOME-Autostart-enabled=true
  '';

  # Polybar config — Rose Pine dark, full configuration, VMware-safe
  # No pseudo-transparency, no GPU effects — solid colours only.
  xdg.configFile."polybar/config.ini".text = ''
    ; ╔══════════════════════════════════════════════════════════════╗
    ; ║  IceBreaker Polybar — Rose Pine Dark                        ║
    ; ║  VMware-safe: solid colours, no transparency, no GPU.       ║
    ; ╚══════════════════════════════════════════════════════════════╝

    ; ── Rose Pine dark palette ────────────────────────────────────
    [colors]
    base      = #191724
    surface   = #1f1d2e
    overlay   = #26233a
    muted     = #6e6a86
    subtle    = #908caa
    text      = #e0def4
    love      = #eb6f92
    gold      = #f6c177
    pine      = #31748f
    foam      = #9ccfd8
    iris      = #c4a7e7
    ; Separator arrow colours (powerline style)
    sep-base-surface  = #191724
    sep-surface-base  = #1f1d2e

    ; ── Bar ───────────────────────────────────────────────────────
    [bar/top]
    width        = 100%
    height       = 32
    fixed-center = true

    ; Solid background — VMware safe, no GPU compositing needed
    background = ''${colors.base}
    foreground = ''${colors.text}

    ; Bottom border in iris for a subtle accent line
    border-bottom-size  = 2
    border-bottom-color = ''${colors.iris}

    line-size  = 2
    line-color = ''${colors.iris}

    padding-left  = 0
    padding-right = 0

    module-margin-left  = 0
    module-margin-right = 0

    ; font-0: main text  font-1: bold  font-2: icons (NF v3)
    ; The ;N at the end is vertical offset to centre glyphs
    font-0 = JetBrainsMono Nerd Font:style=Regular:size=11;3
    font-1 = JetBrainsMono Nerd Font:style=Bold:size=11;3
    font-2 = JetBrainsMono Nerd Font Mono:style=Regular:size=14;4

    ;            logo   ws     sep    title          sep    vpn    sep    cpu    mem    sep    net    sep    date   tray
    modules-left   = nixos sep-nixos-ws workspaces sep-ws-base xwindow
    modules-center = date
    modules-right  = vpn sep-base-vpn cpu memory sep-stats-net network sep-net-clock clock tray-spacer

    tray-position   = right
    tray-padding    = 6
    tray-background = ''${colors.base}
    tray-maxsize    = 18

    cursor-click  = pointer
    cursor-scroll = ns-resize

    ; ── Powerline separators ──────────────────────────────────────
    ; Hard right-arrow  for block transitions
    [module/sep-nixos-ws]
    type             = custom/text
    content          = ""
    content-font     = 3
    content-foreground = ''${colors.overlay}
    content-background = ''${colors.base}

    [module/sep-ws-base]
    type             = custom/text
    content          = ""
    content-font     = 3
    content-foreground = ''${colors.base}
    content-background = ''${colors.base}

    [module/sep-base-vpn]
    type             = custom/text
    content          = ""
    content-font     = 3
    content-foreground = ''${colors.surface}
    content-background = ''${colors.base}

    [module/sep-stats-net]
    type             = custom/text
    content          = ""
    content-font     = 3
    content-foreground = ''${colors.overlay}
    content-background = ''${colors.surface}

    [module/sep-net-clock]
    type             = custom/text
    content          = ""
    content-font     = 3
    content-foreground = ''${colors.surface}
    content-background = ''${colors.overlay}

    [module/tray-spacer]
    type             = custom/text
    content          = "  "
    content-background = ''${colors.base}

    ; ── NixOS logo ────────────────────────────────────────────────
    [module/nixos]
    type               = custom/text
    ; NixOS snowflake glyph (NF v3 U+F313)
    content            = "  "
    content-font       = 3
    content-foreground = ''${colors.iris}
    content-background = ''${colors.overlay}
    content-padding    = 1

    ; ── Workspaces ────────────────────────────────────────────────
    [module/workspaces]
    type = internal/xworkspaces

    ; Show icons alongside workspace names if set in XFCE
    icon-default =

    label-active            = "  %name%  "
    label-active-font       = 2
    label-active-foreground = ''${colors.text}
    label-active-background = ''${colors.overlay}
    label-active-underline  = ''${colors.iris}

    label-occupied            = "  %name%  "
    label-occupied-foreground = ''${colors.subtle}
    label-occupied-background = ''${colors.base}

    label-urgent            = "  %name%  "
    label-urgent-foreground = ''${colors.love}
    label-urgent-background = ''${colors.base}
    label-urgent-underline  = ''${colors.love}

    label-empty            = "  %name%  "
    label-empty-foreground = ''${colors.muted}
    label-empty-background = ''${colors.base}

    ; ── Active window title ───────────────────────────────────────
    [module/xwindow]
    type             = internal/xwindow
    label            = %title:0:60:…%
    label-foreground = ''${colors.subtle}
    label-padding    = 2

    ; ── VPN / network IP ─────────────────────────────────────────
    ; Shows tun0 IP when VPN is active, LAN IP otherwise.
    ; Uses a shell script so it stays VMware-safe (no extra deps).
    [module/vpn]
    type     = custom/script
    interval = 5
    ; Try tun0 first (HTB/THM VPN), then LAN fallback
    exec     = ip -4 addr show tun0 2>/dev/null | grep -oP 'inet \K[^/]+' | head -1 | grep . && echo " $(ip -4 addr show tun0 2>/dev/null | grep -oP 'inet \K[^/]+')" || echo " $(ip -4 route get 1.1.1.1 2>/dev/null | grep -oP 'src \K[^ ]+' | head -1)"
    format-foreground = ''${colors.foam}
    format-background = ''${colors.surface}
    format-padding    = 2

    ; ── CPU ───────────────────────────────────────────────────────
    [module/cpu]
    type     = internal/cpu
    interval = 2

    format          = <label>
    format-prefix   = " "
    format-prefix-font = 3
    format-prefix-foreground = ''${colors.foam}
    format-foreground        = ''${colors.text}
    format-background        = ''${colors.surface}
    format-padding           = 1

    label = %percentage:2%%

    ; Turn red when >80%
    format-warn          = <label-warn>
    format-warn-prefix   = " "
    format-warn-prefix-font = 3
    format-warn-prefix-foreground = ''${colors.love}
    format-warn-foreground        = ''${colors.love}
    format-warn-background        = ''${colors.surface}
    format-warn-padding           = 1
    label-warn = %percentage:2%%
    format-warn-underline = ''${colors.love}

    ; ── Memory ────────────────────────────────────────────────────
    [module/memory]
    type     = internal/memory
    interval = 2

    format          = <label>
    format-prefix   = " "
    format-prefix-font = 3
    format-prefix-foreground = ''${colors.pine}
    format-foreground        = ''${colors.text}
    format-background        = ''${colors.surface}
    format-padding           = 1

    label = %percentage_used:2%%

    ; ── Network ───────────────────────────────────────────────────
    [module/network]
    type           = internal/network
    interface-type = wired
    interval       = 3

    ; Connected
    format-connected          = <label-connected>
    format-connected-prefix   = " "
    format-connected-prefix-font = 3
    format-connected-prefix-foreground = ''${colors.gold}
    format-connected-foreground        = ''${colors.text}
    format-connected-background        = ''${colors.overlay}
    format-connected-padding           = 1
    label-connected = %local_ip%

    ; Disconnected
    format-disconnected          = <label-disconnected>
    format-disconnected-prefix   = "󰌙 "
    format-disconnected-prefix-font = 3
    format-disconnected-prefix-foreground = ''${colors.muted}
    format-disconnected-foreground        = ''${colors.muted}
    format-disconnected-background        = ''${colors.overlay}
    format-disconnected-padding           = 1
    label-disconnected = offline

    ; ── Date ──────────────────────────────────────────────────────
    [module/date]
    type     = internal/date
    interval = 30

    date      = %A, %d %b %Y
    label     =  %date%
    label-foreground = ''${colors.subtle}

    ; ── Clock ─────────────────────────────────────────────────────
    [module/clock]
    type     = internal/date
    interval = 5

    time      = %H:%M
    label     = " %time%"
    label-font = 2
    label-foreground = ''${colors.text}
    label-background = ''${colors.surface}
    label-padding    = 2
  '';

  # ── XFCE settings + keyboard shortcuts ─────────────────────────
  # Uses xfconf-query so changes are additive — no existing defaults lost.
  # Runs at home-manager activation (i.e. after every `nrs`).
  # Safe to run repeatedly: --create only sets the key if it doesn't exist.
  home.activation.xfceRicing = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    _xfq() { ${pkgs.xfconf}/bin/xfconf-query "$@" 2>/dev/null || true; }

    # ── xfwm4 built-in compositor (works on VMware, picom does not) ─
    _xfq -c xfwm4 -p /general/use_compositing -s true --create -t bool

    # ── Icon theme ───────────────────────────────────────────────
    _xfq -c xsettings -p /Net/IconThemeName -s "Papirus-Dark" --create -t string

    # ── Cursor ──────────────────────────────────────────────────
    _xfq -c xsettings -p /Gtk/CursorThemeName -s "Adwaita" --create -t string
    _xfq -c xsettings -p /Gtk/CursorThemeSize  -s 24       --create -t int

    # ── Font rendering ───────────────────────────────────────────
    _xfq -c xsettings -p /Xft/Antialias -s 1        --create -t int
    _xfq -c xsettings -p /Xft/Hinting   -s 1        --create -t int
    _xfq -c xsettings -p /Xft/HintStyle -s hintfull --create -t string
    _xfq -c xsettings -p /Xft/RGBA      -s rgb      --create -t string

    # ── xfwm4 window manager tweaks ─────────────────────────────
    _xfq -c xfwm4 -p /general/title_font      -s "JetBrainsMono Nerd Font Bold 11" --create -t string
    _xfq -c xfwm4 -p /general/title_alignment  -s center --create -t string
    # Button layout: close on right, minimise+maximise on right
    _xfq -c xfwm4 -p /general/button_layout    -s "O|HMC" --create -t string
    _xfq -c xfwm4 -p /general/snap_to_windows  -s true  --create -t bool
    _xfq -c xfwm4 -p /general/snap_to_border   -s true  --create -t bool
    _xfq -c xfwm4 -p /general/wrap_windows     -s false --create -t bool
    _xfq -c xfwm4 -p /general/wrap_workspaces  -s false --create -t bool
    # Titlebar double-click → maximise
    _xfq -c xfwm4 -p /general/double_click_action -s maximize --create -t string

    # ── Hide XFCE top panel (polybar replaces it) ────────────────
    # autohide-behavior=2 = always hidden; size=1 = 1px (invisible)
    _xfq -c xfce4-panel -p /panels/panel-1/autohide-behavior -s 2 -t uint --create
    _xfq -c xfce4-panel -p /panels/panel-1/size              -s 1 -t uint --create

    # ── Rofi keyboard shortcuts ──────────────────────────────────
    # App launcher
    _xfq -c xfce4-keyboard-shortcuts \
      -p "/commands/custom/<Super>space" -s "rofi -show drun" --create -t string
    # Run prompt
    _xfq -c xfce4-keyboard-shortcuts \
      -p "/commands/custom/<Super>r" -s "rofi -show run" --create -t string
    # Window switcher
    _xfq -c xfce4-keyboard-shortcuts \
      -p "/commands/custom/<Super>w" -s "rofi -show window" --create -t string
    # File browser
    _xfq -c xfce4-keyboard-shortcuts \
      -p "/commands/custom/<Super>f" -s "rofi -show filebrowser" --create -t string

    # ── Other useful shortcuts ────────────────────────────────────
    # Terminal — Super+Enter and Ctrl+Alt+T
    _xfq -c xfce4-keyboard-shortcuts \
      -p "/commands/custom/<Super>Return" -s "alacritty" --create -t string
    _xfq -c xfce4-keyboard-shortcuts \
      -p "/commands/custom/<Primary><Alt>t" -s "alacritty" --create -t string
    # File manager
    _xfq -c xfce4-keyboard-shortcuts \
      -p "/commands/custom/<Super>e" -s "thunar" --create -t string
    # Screenshot (full GUI)
    _xfq -c xfce4-keyboard-shortcuts \
      -p "/commands/custom/Print" -s "flameshot gui" --create -t string
    # Screenshot (region only)
    _xfq -c xfce4-keyboard-shortcuts \
      -p "/commands/custom/<Shift>Print" -s "flameshot screen" --create -t string
    # Lock screen
    _xfq -c xfce4-keyboard-shortcuts \
      -p "/commands/custom/<Super>l" -s "xflock4" --create -t string
    # Reload polybar
    _xfq -c xfce4-keyboard-shortcuts \
      -p "/commands/custom/<Super>p" -s "$HOME/.config/polybar/launch.sh" --create -t string
  '';
}
