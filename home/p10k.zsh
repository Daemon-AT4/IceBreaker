# Powerlevel10k configuration for IceBreaker — Rainbow/Powerline style
# Rose Pine dark colour palette with powerline arrow separators.
# Edit this file and run `nrs` to apply changes.
# Or run `p10k configure` to regenerate interactively (overwrites this file).

# Save and modify shell options so aliases/globs don't interfere
'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob

  # Wipe all p10k settings so we start clean
  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'

  # ================================================================
  # Rose Pine dark palette (hex → closest 256-colour approximations)
  # ================================================================
  # base00 (base)    = #191724 → 234
  # base01 (surface) = #1f1d2e → 235
  # base02 (overlay) = #26233a → 236
  # base03 (muted)   = #6e6a86 → 242
  # base04 (subtle)  = #908caa → 246
  # base05 (text)    = #e0def4 → 189
  # base08 (love)    = #eb6f92 → 204
  # base09 (gold)    = #f6c177 → 215
  # base0A (rose)    = #ebbcba → 217
  # base0B (foam)    = #9ccfd8 → 152
  # base0C (pine)    = #31748f → 30
  # base0D (iris)    = #c4a7e7 → 183
  # base0E (highlight med) = #403d52 → 238
  # base07 (highlight high) = #524f67 → 240

  # ================================================================
  # Mode / Icons — requires a Nerd Font (JetBrainsMono installed)
  # ================================================================
  typeset -g POWERLEVEL9K_MODE=nerdfont-v3
  typeset -g POWERLEVEL9K_ICON_PADDING=moderate

  # ================================================================
  # Prompt layout
  # ================================================================
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    os_icon
    context
    dir
    vcs
    newline
    prompt_char
  )

  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    status
    command_execution_time
    background_jobs
    virtualenv
    nix_shell
    my_vpn_ip
    my_ping
    time
  )

  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true

  # ================================================================
  # Rainbow/Powerline style — coloured segment backgrounds
  # ================================================================
  # Powerline arrow separators
  typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=$'\uE0B0'
  typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=$'\uE0B2'
  typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR=$'\uE0B1'
  typeset -g POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR=$'\uE0B3'

  typeset -g POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=$'\uE0B0'
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL=$'\uE0B2'

  # Small gap between left/right prompt segments
  typeset -g POWERLEVEL9K_LEFT_LEFT_WHITESPACE=
  typeset -g POWERLEVEL9K_LEFT_RIGHT_WHITESPACE=' '
  typeset -g POWERLEVEL9K_RIGHT_LEFT_WHITESPACE=' '
  typeset -g POWERLEVEL9K_RIGHT_RIGHT_WHITESPACE=

  # ================================================================
  # OS Icon — Rose Pine iris on overlay
  # ================================================================
  typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=183    # iris
  typeset -g POWERLEVEL9K_OS_ICON_BACKGROUND=236    # overlay
  # Force the NixOS glyph with trailing space — NF v3 U+F313
  # This makes the logo appear larger/more prominent in the prompt
  typeset -g POWERLEVEL9K_OS_ICON_CONTENT_EXPANSION=$'\uf313 '

  # ================================================================
  # Context  user@host — only shown when SSH or root
  # ================================================================
  typeset -g POWERLEVEL9K_CONTEXT_DEFAULT_FOREGROUND=189   # text
  typeset -g POWERLEVEL9K_CONTEXT_DEFAULT_BACKGROUND=236   # overlay
  typeset -g POWERLEVEL9K_CONTEXT_DEFAULT_CONTENT_EXPANSION='%n@%m'
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND=234      # base
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_BACKGROUND=204      # love
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_CONTENT_EXPANSION='%B%n@%m%b'
  typeset -g POWERLEVEL9K_CONTEXT_SSH_FOREGROUND=234       # base
  typeset -g POWERLEVEL9K_CONTEXT_SSH_BACKGROUND=215       # gold
  # Hide context when local and not root
  typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO}_{CONTENT,VISUAL}_EXPANSION=

  # ================================================================
  # Directory — iris on overlay
  # ================================================================
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=183                # iris
  typeset -g POWERLEVEL9K_DIR_BACKGROUND=236                # overlay
  # Add a leading space to the folder icon so it breathes more
  typeset -g POWERLEVEL9K_DIR_VISUAL_IDENTIFIER_EXPANSION=$' \uf07b'
  typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=246      # subtle
  typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=183         # iris
  typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
  typeset -g POWERLEVEL9K_SHORTEN_DELIMITER=
  typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
  typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=80
  typeset -g POWERLEVEL9K_DIR_TRUNCATE_BEFORE_MARKER=false
  typeset -g POWERLEVEL9K_DIR_HYPERLINK=false

  local anchor_files=(
    .git .svn
    package.json Cargo.toml setup.py pyproject.toml go.mod
    flake.nix default.nix
    Makefile CMakeLists.txt
  )
  typeset -g POWERLEVEL9K_SHORTEN_FOLDER_MARKER="(${(j:|:)anchor_files})"

  # ================================================================
  # VCS (Git) — foam/gold on overlay
  # ================================================================
  typeset -g POWERLEVEL9K_VCS_BRANCH_ICON=
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_ICON='?'

  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=152          # foam
  typeset -g POWERLEVEL9K_VCS_CLEAN_BACKGROUND=236          # overlay

  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=215       # gold
  typeset -g POWERLEVEL9K_VCS_MODIFIED_BACKGROUND=236       # overlay

  typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=215      # gold
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND=236      # overlay

  typeset -g POWERLEVEL9K_VCS_CONFLICTED_FOREGROUND=204     # love
  typeset -g POWERLEVEL9K_VCS_CONFLICTED_BACKGROUND=236     # overlay

  typeset -g POWERLEVEL9K_VCS_LOADING_FOREGROUND=242        # muted
  typeset -g POWERLEVEL9K_VCS_LOADING_BACKGROUND=236        # overlay

  typeset -g POWERLEVEL9K_VCS_BACKENDS=(git)

  # ================================================================
  # Prompt character  ❯ / ❮
  # ================================================================
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=152   # foam
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=204 # love
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='❯'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_CONTENT_EXPANSION='❮'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIVIS_CONTENT_EXPANSION='V'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIOWR_CONTENT_EXPANSION='▶'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OVERWRITE_STATE=true
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_LEFT_WHITESPACE=

  # ================================================================
  # Exit status — love on base (errors only)
  # ================================================================
  typeset -g POWERLEVEL9K_STATUS_EXTENDED_STATES=true

  typeset -g POWERLEVEL9K_STATUS_OK=false
  typeset -g POWERLEVEL9K_STATUS_OK_FOREGROUND=152          # foam
  typeset -g POWERLEVEL9K_STATUS_OK_BACKGROUND=235          # surface

  typeset -g POWERLEVEL9K_STATUS_OK_PIPE=true
  typeset -g POWERLEVEL9K_STATUS_OK_PIPE_FOREGROUND=152
  typeset -g POWERLEVEL9K_STATUS_OK_PIPE_BACKGROUND=235

  typeset -g POWERLEVEL9K_STATUS_ERROR=true
  typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=234       # base
  typeset -g POWERLEVEL9K_STATUS_ERROR_BACKGROUND=204       # love

  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_FOREGROUND=234
  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_BACKGROUND=204

  typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE=true
  typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE_FOREGROUND=234
  typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE_BACKGROUND=204

  # ================================================================
  # Command execution time — gold on surface
  # ================================================================
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=3
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=0
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=215   # gold
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND=235   # surface
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT='d h m s'

  # ================================================================
  # Background jobs — foam on surface
  # ================================================================
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE=false
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND=152    # foam
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_BACKGROUND=235    # surface

  # ================================================================
  # Python virtualenv — pine on surface
  # ================================================================
  typeset -g POWERLEVEL9K_VIRTUALENV_FOREGROUND=189          # text
  typeset -g POWERLEVEL9K_VIRTUALENV_BACKGROUND=30           # pine
  typeset -g POWERLEVEL9K_VIRTUALENV_SHOW_WITH_PYENV=false
  typeset -g POWERLEVEL9K_VIRTUALENV_{LEFT,RIGHT}_DELIMITER=

  # ================================================================
  # Nix shell indicator — text on pine
  # ================================================================
  typeset -g POWERLEVEL9K_NIX_SHELL_FOREGROUND=189           # text
  typeset -g POWERLEVEL9K_NIX_SHELL_BACKGROUND=30            # pine

  # ================================================================
  # Time — subtle on surface
  # ================================================================
  typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%H:%M}'
  typeset -g POWERLEVEL9K_TIME_FOREGROUND=246                # subtle
  typeset -g POWERLEVEL9K_TIME_BACKGROUND=235                # surface
  typeset -g POWERLEVEL9K_TIME_UPDATE_ON_COMMAND=false

  # ================================================================
  # Transient prompt — replaces accepted commands with short version
  # ================================================================
  typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=same-dir

  # ================================================================
  # Instant prompt mode
  # ================================================================
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=verbose

  # ================================================================
  # Custom segment: VPN IP — shows tun0/tun1 IP with lock icon,
  # falls back to primary LAN IP when no VPN is active
  # ================================================================
  # Colours: foam (VPN active), muted (LAN fallback)
  typeset -g POWERLEVEL9K_MY_VPN_IP_BACKGROUND=235             # surface
  # The segment content/colour is set dynamically in the function below

  function prompt_my_vpn_ip() {
    local ip iface icon color
    # Try VPN interfaces first
    if ip=$(ip -4 addr show tun0 2>/dev/null | grep -oP 'inet \K[^/]+') && [[ -n "$ip" ]]; then
      iface="tun0"
      icon="󰒄"    # VPN lock icon
      color=152    # foam — VPN active
    elif ip=$(ip -4 addr show tun1 2>/dev/null | grep -oP 'inet \K[^/]+') && [[ -n "$ip" ]]; then
      iface="tun1"
      icon="󰒄"
      color=152
    else
      # Fallback: primary LAN IP (eth0 → any non-loopback)
      ip=$(ip -4 route get 1.1.1.1 2>/dev/null | grep -oP 'src \K[^ ]+')
      [[ -z "$ip" ]] && ip=$(ip -4 addr show eth0 2>/dev/null | grep -oP 'inet \K[^/]+')
      [[ -z "$ip" ]] && return  # no network at all
      iface="lan"
      icon="󰈀"    # ethernet icon
      color=242    # muted — no VPN
    fi
    p10k segment -f "$color" -i "$icon" -t "$ip"
  }

  # ================================================================
  # Custom segment: Ping — shows latency to $TARGET or gateway
  # Updates asynchronously so it never blocks the prompt
  # ================================================================
  typeset -g POWERLEVEL9K_MY_PING_BACKGROUND=235               # surface

  function prompt_my_ping() {
    local target="${TARGET:-}"
    # If no target set, ping the default gateway
    if [[ -z "$target" ]]; then
      target=$(ip route show default 2>/dev/null | awk '/default/ {print $3; exit}')
    fi
    [[ -z "$target" ]] && return

    # Use a cached ping result (updated async in background)
    local cache_file="/tmp/.p10k_ping_cache_$$"
    local ms=""

    if [[ -f "$cache_file" ]]; then
      local age=$(( $(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || echo 0) ))
      if (( age < 10 )); then
        ms=$(<"$cache_file")
      fi
    fi

    # Kick off background ping refresh if stale or missing
    if [[ -z "$ms" || ! -f "$cache_file" ]] || (( age >= 10 )); then
      ( ping -c 1 -W 1 "$target" 2>/dev/null | grep -oP 'time=\K[0-9.]+' > "$cache_file" & ) 2>/dev/null
      # Use last cached value if available
      [[ -f "$cache_file" ]] && ms=$(<"$cache_file")
    fi

    [[ -z "$ms" ]] && return

    # Colour based on latency: green <50ms, gold 50-150ms, love >150ms
    local color=152    # foam (good)
    local ms_int=${ms%%.*}
    if (( ms_int > 150 )); then
      color=204        # love (bad)
    elif (( ms_int > 50 )); then
      color=215        # gold (okay)
    fi

    p10k segment -f "$color" -i "󰓅" -t "${ms_int}ms"
  }

  # Hot-reload when this file is sourced directly
  (( ! $+functions[p10k] )) || p10k reload

} "$@"

# Restore original shell options
(( ${#p10k_config_opts} )) && 'builtin' 'setopt' ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'
