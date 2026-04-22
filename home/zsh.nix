# ┌─────────────────────────────────────────────────────────────┐
# │  IceBreaker — ZSH Configuration                            │
# │  Shell plugins, keybindings, completion, and functions.     │
# │  Imported by home/default.nix.                              │
# │                                                            │
# │  Structure:                                                │
# │    programs.zsh.plugins     — extra ZSH plugins            │
# │    programs.zsh.oh-my-zsh   — oh-my-zsh framework plugins  │
# │    programs.zsh.initContent — shell init code (functions,  │
# │                               keybindings, zoxide, p10k)   │
# │    programs.zsh.sessionVariables — environment variables   │
# │                                                            │
# │  Nix escaping rules for ''...'' strings:                   │
# │    ${var}  → must be written as ''${var}                   │
# │    $VAR    → safe as-is (no braces)                         │
# │    $(cmd)  → safe as-is                                     │
# │                                                            │
# │  NOTE: initExtraFirst / initExtra are deprecated.           │
# │  We use initContent with lib.mkBefore for the p10k         │
# │  instant prompt (must load first).                         │
# └─────────────────────────────────────────────────────────────┘
{ config, pkgs, lib, ... }:

{
  programs.zsh = {
    enable = true;

    # Lock in legacy dotDir behaviour (silences deprecation warning)
    dotDir = "${config.home.homeDirectory}";

    # ── Completion ───────────────────────────────────────────────
    enableCompletion = true;

    # ── Built-in plugins (home-manager managed) ──────────────────
    autosuggestion.enable       = true;
    syntaxHighlighting.enable   = true;
    historySubstringSearch.enable = true;

    # ── History ──────────────────────────────────────────────────
    history = {
      size        = 100000;
      save        = 100000;
      path        = "${config.xdg.dataHome}/zsh/history";
      ignoreDups  = true;
      ignoreSpace = true;
      extended    = true;
      share       = true;
    };

    # ── Oh My Zsh framework ───────────────────────────────────────
    oh-my-zsh = {
      enable = true;
      # Theme is empty — Powerlevel10k takes over
      theme   = "";
      plugins = [
        "git"
        "sudo"             # press ESC twice to prefix last cmd with sudo
        "docker"
        "docker-compose"
        "tmux"
        "fzf"
        "z"                # jump to frecent directories
        "colored-man-pages"
        "command-not-found"
        "extract"          # `extract archive.tar.gz` — any format
        "jsontools"        # pp_json, is_json, urlencode_json, urldecode_json
        "dirhistory"       # alt+left/right to navigate dir history
        "copyfile"         # copy file contents to clipboard
        "copypath"         # copy current path to clipboard
        "history"          # h, hs, hsi aliases for history search
        "web-search"       # google / ddg / bing from terminal
        "python"           # py, mkv aliases
        "pip"              # pip completion
        "systemd"          # sc-* aliases for systemctl
        "git-extras"       # extra git helpers
      ];
    };

    # ── Extra plugins (beyond oh-my-zsh) ─────────────────────────
    plugins = [
      # Powerlevel10k theme
      {
        name = "powerlevel10k";
        src  = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      # Show a reminder when an alias exists for a command you typed
      {
        name = "you-should-use";
        src  = pkgs.zsh-you-should-use;
        file = "share/zsh/plugins/you-should-use/you-should-use.plugin.zsh";
      }
      # Nix shell integration (shows nix-shell in prompt, fixes PATH)
      {
        name = "zsh-nix-shell";
        src  = pkgs.zsh-nix-shell;
        file = "share/zsh-nix-shell/nix-shell.plugin.zsh";
      }
      # Extra completion definitions
      {
        name = "zsh-completions";
        src  = pkgs.zsh-completions;
        file = "share/zsh/site-functions";
      }
      # Replace default tab completion with fzf
      {
        name = "fzf-tab";
        src  = pkgs.zsh-fzf-tab;
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
      }
    ];

    # ── Initialisation content ────────────────────────────────────
    # lib.mkBefore (priority 500) ensures the instant prompt block is
    # placed before oh-my-zsh / plugin loading in the generated .zshrc.
    initContent = lib.mkMerge [
      (lib.mkBefore ''
        # Powerlevel10k instant prompt — must stay at the top of .zshrc
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '')
      ''
      # ── Completion settings ──────────────────────────────────
      zstyle ':completion:*' menu select
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
      zstyle ':completion:*:descriptions' format '%F{green}-- %d --%f'
      zstyle ':completion:*:warnings' format '%F{red}No matches%f'
      # Case-insensitive tab completion
      zstyle ':completion:*' completer _expand _complete _ignored _approximate

      # ── Key bindings ─────────────────────────────────────────
      # History substring search (arrow keys)
      bindkey '^[[A' history-substring-search-up
      bindkey '^[[B' history-substring-search-down
      # Also bind for vi mode
      bindkey -M vicmd 'k' history-substring-search-up
      bindkey -M vicmd 'j' history-substring-search-down
      # Ctrl+R for history search
      bindkey '^R' history-incremental-search-backward
      # Home/End keys
      bindkey '^[[H' beginning-of-line
      bindkey '^[[F' end-of-line

      # ── Better directory navigation ───────────────────────────
      setopt AUTO_CD
      setopt AUTO_PUSHD
      setopt PUSHD_IGNORE_DUPS
      setopt PUSHD_SILENT

      # ── Misc options ─────────────────────────────────────────
      setopt CORRECT             # auto correct mistakes
      setopt INTERACTIVE_COMMENTS # allow # comments in shell
      setopt GLOB_DOTS           # include dotfiles in globs
      # NOTE: EXTENDED_GLOB makes # a glob operator which breaks nix flake refs
      # (e.g. .#icebreaker). Disabled — use setopt EXTENDED_GLOB in scripts if needed.
      # setopt EXTENDED_GLOB

      # ── Zoxide initialisation (must be after compinit) ────────
      eval "$(zoxide init zsh)"

      # ── Source p10k config ────────────────────────────────────
      # Edit ~/IceBreaker/home/p10k.zsh then run: home-manager switch
      # Or run 'p10k configure' for the interactive wizard
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

      # ── Target & Engagement Management ─────────────────────

      # settarget <IP> [LPORT] — set $TARGET, auto-detect $LHOST, persist to ~/.target.env
      settarget() {
        if [[ -z "''${1:-}" ]]; then
          echo "Usage: settarget <IP> [LPORT]"
          echo "Current: TARGET=''${TARGET:-unset}  LHOST=''${LHOST:-unset}  LPORT=''${LPORT:-unset}"
          return 1
        fi
        export TARGET="$1"
        export LPORT="''${2:-4444}"
        # Auto-detect LHOST from tun0 → tun1 → eth0
        export LHOST=$(ip -4 addr show tun0 2>/dev/null | grep -oP 'inet \K[^/]+' || \
                       ip -4 addr show tun1 2>/dev/null | grep -oP 'inet \K[^/]+' || \
                       ip -4 addr show eth0 2>/dev/null | grep -oP 'inet \K[^/]+' || \
                       echo "127.0.0.1")
        # Persist so new shells pick it up
        cat > "$HOME/.target.env" <<EOF
      export TARGET="$TARGET"
      export LHOST="$LHOST"
      export LPORT="$LPORT"
      EOF
        echo "[+] TARGET=$TARGET  LHOST=$LHOST  LPORT=$LPORT"
        echo "[+] Saved to ~/.target.env"
      }

      # newbox <name> [IP] — create engagement directory scaffold
      newbox() {
        if [[ -z "''${1:-}" ]]; then
          echo "Usage: newbox <name> [IP]"
          return 1
        fi
        local name="$1"
        local ip="''${2:-}"
        local boxdir="$HOME/targets/$name"

        mkdir -p "$boxdir"/{nmap,loot,exploits,www}

        # Create flags.txt and creds.txt if they don't exist
        [[ -f "$boxdir/flags.txt" ]] || echo "# Flags for $name" > "$boxdir/flags.txt"
        [[ -f "$boxdir/creds.txt" ]] || echo "# Credentials for $name" > "$boxdir/creds.txt"

        # Create notes template if it doesn't exist
        if [[ ! -f "$boxdir/notes.md" ]]; then
          cat > "$boxdir/notes.md" <<EOF
      # $name
      **IP:** ''${ip:-TBD}
      **Date:** $(date +%Y-%m-%d)

      ## Recon


      ## Foothold


      ## PrivEsc


      ## Flags


      ## Credentials


      ## Notes

      EOF
        fi

        # Symlink ~/targets/current → this box
        ln -sfn "$boxdir" "$HOME/targets/current"

        echo "[+] Created $boxdir"
        echo "[+] Symlinked ~/targets/current → $boxdir"
        cd "$boxdir"

        # Set target if IP provided
        if [[ -n "$ip" ]]; then
          settarget "$ip"
        fi
      }

      # flag <value> [description] — append timestamped flag
      flag() {
        if [[ -z "''${1:-}" ]]; then
          echo "Usage: flag <value> [description]"
          return 1
        fi
        local flagfile="./flags.txt"
        [[ -f "$flagfile" ]] || flagfile="$HOME/targets/current/flags.txt"
        if [[ ! -f "$flagfile" ]]; then
          echo "[-] No flags.txt found (run newbox first or cd into a target dir)"
          return 1
        fi
        local ts=$(date '+%Y-%m-%d %H:%M')
        echo "[$ts] $1  ''${2:+# $2}" >> "$flagfile"
        echo "[+] Flag saved to $flagfile"
      }

      # cred <username> <password> [service] — append timestamped credential
      cred() {
        if [[ -z "''${1:-}" || -z "''${2:-}" ]]; then
          echo "Usage: cred <username> <password> [service]"
          return 1
        fi
        local credfile="./creds.txt"
        [[ -f "$credfile" ]] || credfile="$HOME/targets/current/creds.txt"
        if [[ ! -f "$credfile" ]]; then
          echo "[-] No creds.txt found (run newbox first or cd into a target dir)"
          return 1
        fi
        local ts=$(date '+%Y-%m-%d %H:%M')
        echo "[$ts] $1:$2  ''${3:+($3)}" >> "$credfile"
        echo "[+] Credential saved to $credfile"
      }

      # hcmode [filter] — hashcat mode quick-reference
      hcmode() {
        local modes=(
          "0       MD5"
          "100     SHA1"
          "500     md5crypt (Unix)"
          "1000    NTLM"
          "1400    SHA256"
          "1700    SHA512"
          "1800    sha512crypt (Unix)"
          "2100    Domain Cached Credentials 2 (DCC2)"
          "2500    WPA-EAPOL-PBKDF2"
          "3000    LM"
          "3200    bcrypt"
          "5500    NetNTLMv1"
          "5600    NetNTLMv2"
          "7500    Kerberos 5 AS-REQ Pre-Auth (etype 23)"
          "8600    Lotus Notes/Domino 5"
          "11300   Bitcoin/Litecoin wallet.dat"
          "13100   Kerberos 5 TGS-REP (Kerberoast, etype 23)"
          "13400   KeePass 1/2"
          "16800   WPA-PMKID-PBKDF2"
          "18200   Kerberos 5 AS-REP (AS-REP Roast, etype 23)"
          "22000   WPA-PBKDF2-PMKID+EAPOL"
        )
        if [[ -n "''${1:-}" ]]; then
          printf '%s\n' "''${modes[@]}" | grep -i "$1"
        else
          printf '%s\n' "''${modes[@]}"
        fi
      }

      # nmap-init [target] — initial nmap scan with version/scripts/OS detection
      nmap-init() {
        local t="''${1:-$TARGET}"
        if [[ -z "$t" ]]; then
          echo "Usage: nmap-init [target]  (or set \$TARGET with settarget)"
          return 1
        fi
        mkdir -p ./nmap
        echo "[+] Running: nmap -sV -sC -O --open -oA ./nmap/initial $t"
        nmap -sV -sC -O --open -oA ./nmap/initial "$t"
      }

      # nmap-allports [target] — full port scan
      nmap-allports() {
        local t="''${1:-$TARGET}"
        if [[ -z "$t" ]]; then
          echo "Usage: nmap-allports [target]  (or set \$TARGET with settarget)"
          return 1
        fi
        mkdir -p ./nmap
        echo "[+] Running: nmap -p- -T4 --open -oA ./nmap/allports $t"
        nmap -p- -T4 --open -oA ./nmap/allports "$t"
      }

      # nmap-targeted <target> <ports> — targeted scan on specific ports
      nmap-targeted() {
        if [[ -z "''${1:-}" || -z "''${2:-}" ]]; then
          echo "Usage: nmap-targeted <target> <ports>"
          echo "  e.g. nmap-targeted 10.10.10.1 22,80,445"
          return 1
        fi
        mkdir -p ./nmap
        echo "[+] Running: nmap -sV -sC -p$2 -oA ./nmap/targeted $1"
        nmap -sV -sC -p"$2" -oA ./nmap/targeted "$1"
      }

      # setproxy [port] — update proxychains SOCKS5 port
      setproxy() {
        local port="''${1:-1080}"
        local conf="$HOME/.config/proxychains/proxychains.conf"
        if [[ ! -f "$conf" ]]; then
          echo "[-] $conf not found"
          return 1
        fi
        sed -i "s|socks5.*127.0.0.1.*|socks5  127.0.0.1 $port|" "$conf"
        echo "[+] Proxychains SOCKS5 port set to $port"
      }

      # ── Source persisted target env ─────────────────────────
      [[ -f "$HOME/.target.env" ]] && source "$HOME/.target.env"
    ''
    ];  # end mkMerge

    # ── Environment variables ─────────────────────────────────────
    sessionVariables = {
      EDITOR  = "nvim";
      VISUAL  = "nvim";
      PAGER   = "bat --paging=always";
      MANPAGER = "sh -c 'col -bx | bat -l man -p'";

      # pipx installs tools here
      PATH = "$HOME/.local/bin:$PATH";

      # Colours for ls/lsd
      LS_COLORS = "di=1;34:ln=1;36:so=1;32:pi=1;33:ex=1;31";

      # Pentest helpers
      WORDLISTS = "/run/current-system/sw/share/seclists";
      ROCKYOU   = "/run/current-system/sw/share/seclists/Passwords/Leaked-Databases/rockyou.txt";

      # Proxychains config (mutable — managed by setproxy function)
      PROXYCHAINS_CONF_FILE = "$HOME/.config/proxychains/proxychains.conf";
    };
  };

  # ── p10k config file ──────────────────────────────────────────
  # Managed by the flake — edit home/p10k.zsh and rebuild to apply.
  home.file.".p10k.zsh".source = ./p10k.zsh;
}
