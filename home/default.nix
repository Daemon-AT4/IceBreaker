# ┌─────────────────────────────────────────────────────────────┐
# │  IceBreaker — Home Manager Configuration                   │
# │  User-level programs, dotfiles, and settings.              │
# │  This file is the root of the home-manager config —        │
# │  it imports zsh.nix and aliases.nix.                       │
# │                                                            │
# │  Home Manager is embedded as a NixOS module (not           │
# │  standalone), so `nrs` rebuilds both system AND home.      │
# │  Do NOT also run `nh home switch`.                         │
# │                                                            │
# │  To add user-level packages, add them to home.packages.    │
# │  For system-wide packages, use modules/system/base.nix.    │
# └─────────────────────────────────────────────────────────────┘
{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./zsh.nix       # ZSH config, plugins, functions
    ./aliases.nix   # all shell aliases
    ./xfce.nix      # XFCE ricing, Rofi, Dunst, Polybar
    ./firefox.nix   # Firefox profile, bookmarks, settings
  ];

  # ── Identity ───────────────────────────────────────────────────
  # Change these if you fork IceBreaker for a different user.
  # Also update: modules/system/base.nix (users.users.*)
  #              flake.nix (users.USERNAME = import ./home/default.nix)
  home.username      = "archangel";
  home.homeDirectory = "/home/archangel";
  home.stateVersion  = "25.11";

  programs.home-manager.enable = true;

  # ── User packages (not system-wide) ────────────────────────────
  # These are only available to this user, not root.
  # For system-wide packages, use modules/system/base.nix.
  home.packages = with pkgs; [
    # ── Better shell utilities ──────────────────────────────────
    lsd
    eza
    bat
    fd
    ripgrep
    fzf
    zoxide
    tldr
    procs     # modern ps
    dust      # du + rust
    duf       # df alternative

    # ── Data tools ──────────────────────────────────────────────
    jq
    yq
    gron      # make JSON greppable

    # ── Git ─────────────────────────────────────────────────────
    lazygit
    git-extras
    delta     # better git diffs

    # ── HTTP ────────────────────────────────────────────────────
    curlie    # curl + httpie syntax
    xh        # fast httpie clone

    # ── Terminal multiplexer extras ─────────────────────────────
    tmux
    tmate     # pair programming via tmux

    # ── Process viewer ──────────────────────────────────────────
    btop

    # ── Misc ────────────────────────────────────────────────────
    fastfetch
    figlet
    lolcat

    # ── GUI tools ───────────────────────────────────────────────
    gitkraken    # Git GUI client

    # ── Add your user packages below ────────────────────────────
    # example: obsidian  spotify  discord
  ];

  # ── Git ────────────────────────────────────────────────────────
  # Change user.name and user.email to your details
  programs.git = {
    enable = true;
    settings = {
      user.name          = "archangel";
      user.email         = "archangel@icebreaker";
      init.defaultBranch = "main";
      core.editor        = "nvim";
      pull.rebase        = false;
    };
  };

  # ── Delta (better git diffs) ───────────────────────────────────
  programs.delta = {
    enable                 = true;
    enableGitIntegration   = true;
  };

  # ┌─────────────────────────────────────────────────────────────┐
  # │  Tmux — Rose Pine Dawn Theme                               │
  # │  Full config managed by NixOS. Plugins installed via Nix.  │
  # │  Prefix key: Ctrl+a                                        │
  # │                                                            │
  # │  Rose Pine Dawn palette (light theme):                     │
  # │    base=#faf4ed  surface=#fffaf3  overlay=#f2e9e1          │
  # │    text=#464261  muted=#9893a5    subtle=#797593            │
  # │    love=#b4637a  gold=#ea9d34     rose=#d7827e              │
  # │    pine=#286983  foam=#56949f     iris=#907aa9              │
  # │    hlLow=#f4ede8  hlMed=#dfdad9  hlHigh=#cecacd            │
  # └─────────────────────────────────────────────────────────────┘
  programs.tmux = {
    enable       = true;
    terminal     = "tmux-256color";
    historyLimit = 100000;
    keyMode      = "vi";
    prefix       = "C-a";
    mouse        = true;
    escapeTime   = 0;        # no delay after pressing Esc (crucial for neovim)
    baseIndex    = 1;         # windows start at 1

    # ── Plugins (installed via Nix, no TPM needed) ───────────────
    plugins = with pkgs.tmuxPlugins; [
      # Sane defaults everyone agrees on
      sensible

      # System clipboard integration (y to copy in copy mode)
      yank

      # Save/restore tmux sessions across restarts
      # prefix + Ctrl-s = save, prefix + Ctrl-r = restore
      resurrect

      # Auto-save sessions every 15 min, auto-restore on tmux start
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '15'
        '';
      }

      # Standardised pane navigation keybindings
      # prefix + h/j/k/l to navigate, H/J/K/L to resize
      pain-control

      # Seamless navigation between tmux panes and neovim splits
      # Ctrl+h/j/k/l moves between panes AND vim splits
      vim-tmux-navigator

      # Fuzzy-find and extract text from terminal output
      # prefix + tab to activate
      extrakto

      # Open highlighted file/URL from copy mode
      # o = open, Ctrl-o = open in editor
      open

      # Fuzzy URL picker from terminal output
      # prefix + u to list URLs
      fzf-tmux-url

      # Visual feedback when prefix key is pressed
      prefix-highlight

      # Vimium-style jump to any character on screen
      # prefix + J to activate
      jump

      # Copy text by selecting with hints (like vimium)
      tmux-thumbs

      # Quick session management with fzf + zoxide
      tmux-sessionx

      # Logging — prefix + P to toggle, prefix + Alt-p to save buffer
      logging

      # Sidebar — prefix + Tab for directory tree
      sidebar
    ];

    extraConfig = ''
      # ── True colour support ──────────────────────────────────────
      set -ag terminal-overrides ",xterm-256color:RGB"
      set -ag terminal-overrides ",alacritty:RGB"

      # ── Rose Pine Dawn palette variables ─────────────────────────
      # Define colours as tmux variables for easy reference
      RP_BASE="#faf4ed"
      RP_SURFACE="#fffaf3"
      RP_OVERLAY="#f2e9e1"
      RP_MUTED="#9893a5"
      RP_SUBTLE="#797593"
      RP_TEXT="#464261"
      RP_LOVE="#b4637a"
      RP_GOLD="#ea9d34"
      RP_ROSE="#d7827e"
      RP_PINE="#286983"
      RP_FOAM="#56949f"
      RP_IRIS="#907aa9"
      RP_HL_LOW="#f4ede8"
      RP_HL_MED="#dfdad9"
      RP_HL_HIGH="#cecacd"

      # ── Window settings ──────────────────────────────────────────
      setw -g pane-base-index 1
      set -g renumber-windows on
      set -g allow-rename off
      set -g set-titles on
      set -g set-titles-string "#S / #W"

      # ── Status bar — Rose Pine Dawn ──────────────────────────────
      set -g status-position bottom
      set -g status-interval 5
      set -g status-justify left

      # Status bar background: overlay
      set -g status-style "bg=$RP_OVERLAY,fg=$RP_TEXT"

      # Left: session name in pine on surface
      set -g status-left-length 30
      set -g status-left "#[fg=$RP_BASE,bg=$RP_PINE,bold]  #S #[fg=$RP_PINE,bg=$RP_OVERLAY,nobold]"

      # Right: prefix indicator + host + time
      set -g status-right-length 80
      set -g status-right "#{prefix_highlight} #[fg=$RP_HL_HIGH,bg=$RP_OVERLAY]#[fg=$RP_SUBTLE,bg=$RP_HL_HIGH] 󰒍 #H #[fg=$RP_FOAM,bg=$RP_HL_HIGH]#[fg=$RP_BASE,bg=$RP_FOAM,bold] 󰃰 %H:%M #[fg=$RP_PINE,bg=$RP_FOAM]#[fg=$RP_BASE,bg=$RP_PINE,bold] %d/%m "

      # ── Window tabs ──────────────────────────────────────────────
      # Inactive windows: muted text on overlay
      set -g window-status-format "#[fg=$RP_OVERLAY,bg=$RP_HL_LOW]#[fg=$RP_MUTED,bg=$RP_HL_LOW] #I  #W #[fg=$RP_HL_LOW,bg=$RP_OVERLAY]"

      # Active window: pine on surface (bold)
      set -g window-status-current-format "#[fg=$RP_OVERLAY,bg=$RP_PINE]#[fg=$RP_BASE,bg=$RP_PINE,bold] #I  #W #[fg=$RP_PINE,bg=$RP_OVERLAY]"

      # Window separator
      set -g window-status-separator ""

      # Activity indicator
      set -g window-status-activity-style "fg=$RP_GOLD,bg=$RP_OVERLAY"
      set -g monitor-activity on
      set -g visual-activity off

      # ── Pane borders ─────────────────────────────────────────────
      set -g pane-border-style "fg=$RP_HL_HIGH"
      set -g pane-active-border-style "fg=$RP_PINE"
      set -g pane-border-lines heavy
      set -g pane-border-indicators colour

      # ── Message / command prompt ─────────────────────────────────
      set -g message-style "bg=$RP_PINE,fg=$RP_BASE,bold"
      set -g message-command-style "bg=$RP_GOLD,fg=$RP_BASE,bold"

      # ── Copy mode ────────────────────────────────────────────────
      set -g mode-style "bg=$RP_HL_MED,fg=$RP_TEXT"

      # ── Clock mode ──────────────────────────────────────────────
      set -g clock-mode-colour "$RP_PINE"
      set -g clock-mode-style 24

      # ── Popup style ──────────────────────────────────────────────
      set -g popup-border-style "fg=$RP_PINE"

      # ── Keybindings ──────────────────────────────────────────────

      # Split panes (preserving current directory)
      bind v split-window -h -c "#{pane_current_path}"
      bind s split-window -v -c "#{pane_current_path}"
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # New window in current directory
      bind c new-window -c "#{pane_current_path}"

      # Resize panes with prefix + Alt+arrow
      bind -r M-Up    resize-pane -U 5
      bind -r M-Down  resize-pane -D 5
      bind -r M-Left  resize-pane -L 5
      bind -r M-Right resize-pane -R 5

      # Navigate panes without prefix (Alt+arrow)
      bind -n M-Left  select-pane -L
      bind -n M-Right select-pane -R
      bind -n M-Up    select-pane -U
      bind -n M-Down  select-pane -D

      # Swap windows left/right with prefix + < / >
      bind -r < swap-window -t -1 \; select-window -t -1
      bind -r > swap-window -t +1 \; select-window -t +1

      # Toggle zoom on current pane
      bind z resize-pane -Z

      # Kill pane/window without confirmation
      bind x kill-pane
      bind X kill-window

      # Reload config
      bind r source-file ~/.config/tmux/tmux.conf \; display "  Config reloaded!"

      # ── Vi copy mode keybindings ─────────────────────────────────
      bind -T copy-mode-vi v   send -X begin-selection
      bind -T copy-mode-vi C-v send -X rectangle-toggle
      bind -T copy-mode-vi y   send -X copy-selection-and-cancel
      bind -T copy-mode-vi H   send -X start-of-line
      bind -T copy-mode-vi L   send -X end-of-line

      # ── Prefix highlight plugin config ───────────────────────────
      set -g @prefix_highlight_fg "$RP_BASE"
      set -g @prefix_highlight_bg "$RP_LOVE"
      set -g @prefix_highlight_show_copy_mode 'on'
      set -g @prefix_highlight_copy_mode_attr "fg=$RP_BASE,bg=$RP_GOLD,bold"

      # ── Extrakto config ─────────────────────────────────────────
      set -g @extrakto_key 'tab'
      set -g @extrakto_split_direction 'p'

      # ── Tmux-thumbs config ──────────────────────────────────────
      set -g @thumbs-key F
      set -g @thumbs-fg-color "$RP_PINE"
      set -g @thumbs-hint-fg-color "$RP_LOVE"

      # ── Sessionx config ─────────────────────────────────────────
      set -g @sessionx-bind 'o'
      set -g @sessionx-zoxide-mode 'on'

      # ── Resurrect config ────────────────────────────────────────
      set -g @resurrect-capture-pane-contents 'on'
      set -g @resurrect-strategy-nvim 'session'

      # ── fzf-url config ──────────────────────────────────────────
      set -g @fzf-url-bind 'u'

      # ── Jump config ─────────────────────────────────────────────
      set -g @jump-key 'J'
    '';
  };

  # ┌─────────────────────────────────────────────────────────────┐
  # │  Alacritty — GPU-accelerated terminal emulator              │
  # │  Stylix automatically handles: colours, font, opacity.      │
  # │  We configure everything else: scrollback, keybindings,     │
  # │  cursor, padding, window behaviour.                         │
  # │                                                            │
  # │  Alacritty uses TOML config (v0.13+). The home-manager     │
  # │  module translates the Nix attrset to TOML automatically.  │
  # └─────────────────────────────────────────────────────────────┘
  programs.alacritty = {
    enable = true;
    settings = {
      # ── Window ─────────────────────────────────────────────────
      window = {
        # Padding (pixels) inside the terminal window
        padding = { x = 8; y = 6; };
        # "full" lets the WM handle decorations (best for tiling)
        decorations = "full";
        # Start maximised — useful on VM where screen space is tight
        startup_mode = "Maximized";
        # Slight transparency — Stylix also applies opacity.terminal
        # but this controls the whole window including padding
        dynamic_padding = true;
        # Window title
        title = "Alacritty";
        dynamic_title = true;
      };

      # ── Scrolling ──────────────────────────────────────────────
      scrolling = {
        history = 50000;       # lines of scrollback
        multiplier = 3;        # scroll speed
      };

      # ── Cursor ─────────────────────────────────────────────────
      cursor = {
        style = {
          shape = "Block";
          blinking = "On";
        };
        blink_interval = 500;
        blink_timeout = 0;     # never stop blinking
        unfocused_hollow = true;
        vi_mode_style = {
          shape = "Underline";
          blinking = "Off";
        };
      };

      # ── Selection ──────────────────────────────────────────────
      selection = {
        save_to_clipboard = true;  # auto-copy selections
      };

      # ── Mouse ──────────────────────────────────────────────────
      mouse = {
        hide_when_typing = true;
      };

      # ── Bell ───────────────────────────────────────────────────
      bell = {
        animation = "EaseOutExpo";
        duration = 100;
      };

      # ── Terminal ───────────────────────────────────────────────
      terminal = {
        shell = { program = "zsh"; };
        osc52 = "CopyPaste";   # clipboard via OSC52 escape sequences
      };

      # ── Environment ────────────────────────────────────────────
      env = {
        TERM = "xterm-256color";
      };

      # ── Keyboard shortcuts ─────────────────────────────────────
      # Alacritty uses TOML keybinding format (v0.13+)
      keyboard.bindings = [
        # Font size
        { key = "Plus";     mods = "Control|Shift"; action = "IncreaseFontSize"; }
        { key = "Minus";    mods = "Control";        action = "DecreaseFontSize"; }
        { key = "Key0";     mods = "Control";        action = "ResetFontSize"; }

        # Copy/paste — standard shortcuts
        { key = "C";        mods = "Control|Shift"; action = "Copy"; }
        { key = "V";        mods = "Control|Shift"; action = "Paste"; }

        # Scrolling
        { key = "PageUp";   mods = "Shift";         action = "ScrollPageUp"; }
        { key = "PageDown"; mods = "Shift";         action = "ScrollPageDown"; }
        { key = "Home";     mods = "Shift";         action = "ScrollToTop"; }
        { key = "End";      mods = "Shift";         action = "ScrollToBottom"; }

        # Vi mode (for scrollback search)
        { key = "Space";    mods = "Control|Shift"; action = "ToggleViMode"; }

        # Search (in vi mode, / already works)
        { key = "F";        mods = "Control|Shift"; action = "SearchForward"; }
        { key = "B";        mods = "Control|Shift"; action = "SearchBackward"; }

        # New window (spawns another Alacritty instance)
        { key = "N";        mods = "Control|Shift"; action = "CreateNewWindow"; }
      ];

      # ── Colours / Font / Opacity ───────────────────────────────
      # DO NOT set colors, font, or window.opacity here.
      # Stylix manages all of these automatically using the
      # Rose Pine dark base16 scheme. Setting them here would
      # cause "conflicting definitions" errors on rebuild.
    };
  };

  # ── Bat ────────────────────────────────────────────────────────
  # Theme is managed by stylix (rose-pine via base16)
  programs.bat.enable = true;

  # ── FZF ────────────────────────────────────────────────────────
  programs.fzf = {
    enable               = true;
    enableZshIntegration = true;
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
      "--inline-info"
    ];
    # Colours managed by stylix (rose-pine palette applied automatically)
  };

  # ── Zoxide (smarter cd) ────────────────────────────────────────
  programs.zoxide = {
    enable               = true;
    enableZshIntegration = true;
  };

  # ── Direnv (auto-load .envrc) ──────────────────────────────────
  programs.direnv = {
    enable               = true;
    enableZshIntegration = true;
    nix-direnv.enable    = true;
  };

  # ── SSH client defaults ────────────────────────────────────────
  programs.ssh = {
    enable                = true;
    enableDefaultConfig   = false;
    matchBlocks."*" = {
      extraOptions = {
        ServerAliveInterval = "60";
        ServerAliveCountMax = "10";
        AddKeysToAgent      = "yes";
      };
    };
  };

  # ── XDG dirs ──────────────────────────────────────────────────
  xdg.enable = true;

  # ── GTK cleanup (stylix needs to overwrite existing GTK files) ──
  # XFCE uses GTK natively so stylix GTK targets work well. This
  # activation removes stale GTK config files so stylix can manage them.
  home.activation.removeExistingGtk = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
    rm -f ~/.gtkrc-2.0
    rm -f ~/.config/gtk-3.0/settings.ini
    rm -f ~/.config/gtk-3.0/gtk.css
    rm -f ~/.config/gtk-4.0/settings.ini
    rm -f ~/.config/gtk-4.0/gtk.css
  '';

  # ── Default directories ───────────────────────────────────────
  # These create placeholder files so the directories exist on first boot
  home.file."vpn/.keep".text = "";      # ~/vpn/ for HTB/THM .ovpn files
  home.file."ctf/.keep".text = "";      # ~/ctf/ for CTF work
  home.file."targets/.keep".text = "";  # ~/targets/ for engagement notes

  # ── Proxychains default config (mutable — setproxy edits it) ──
  # Uses home.activation so the file is only created if it doesn't
  # exist. This keeps it mutable — the `setproxy` function in
  # zsh.nix modifies it with sed.
  home.activation.createProxychainsConf = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    PCONF="$HOME/.config/proxychains/proxychains.conf"
    if [ ! -f "$PCONF" ]; then
      mkdir -p "$(dirname "$PCONF")"
      cat > "$PCONF" << 'PCEOF'
# Proxychains configuration — managed by IceBreaker (setproxy edits this)
strict_chain
quiet_mode
proxy_dns

[ProxyList]
socks5  127.0.0.1 1080
PCEOF
    fi
  '';
}
