#!/usr/bin/env bash
# =============================================================================
# IceBreaker — HTB/CTF Tmux Layout
# Creates a tmux session with a pentesting-friendly layout:
#   - Main terminal (top 60%)
#   - Notes in nvim (bottom-left)
#   - Listener ready message (bottom-right)
#
# Usage:
#   ./scripts/tmux-htb.sh          # auto-names from $TARGET or current dir
#   htb-tmux                       # alias
# =============================================================================

set -euo pipefail

# ── Session name ─────────────────────────────────────────────────────────────
if [[ -n "${TARGET:-}" ]]; then
  SESSION="htb-${TARGET}"
else
  SESSION="htb-$(basename "$(pwd)")"
fi

# Sanitise session name (tmux doesn't like dots/colons)
SESSION="${SESSION//[.:]/-}"

# ── If session exists, attach ────────────────────────────────────────────────
if tmux has-session -t "$SESSION" 2>/dev/null; then
  echo "[*] Reconnecting to existing node: $SESSION"
  exec tmux attach-session -t "$SESSION"
fi

# ── Create new session ──────────────────────────────────────────────────────
echo ""
echo -e '\033[0;36m  ╔═══════════════════════════════════════════╗\033[0m'
echo -e '\033[0;36m  ║\033[1m  ICEBREAKER // COMBAT INFORMATION CENTER \033[0m\033[0;36m ║\033[0m'
echo -e '\033[0;36m  ║\033[0m  Initialising node: '"$SESSION"'              \033[0;36m\033[0m'
echo -e '\033[0;36m  ╚═══════════════════════════════════════════╝\033[0m'
echo ""

# Main pane (top 60%)
tmux new-session -d -s "$SESSION" -x "$(tput cols)" -y "$(tput lines)"

# Bottom split (40% height)
tmux split-window -v -p 40 -t "$SESSION"

# Split bottom into left/right
tmux split-window -h -t "$SESSION"

# ── Configure panes (pane-base-index is 1 from tmux config) ─────────────────
# Pane 1: main terminal (top)
# Pane 2: bottom-left → notes
# Pane 3: bottom-right → listener info

# Bottom-left: open notes in nvim
NOTES_FILE=""
if [[ -f "./notes.md" ]]; then
  NOTES_FILE="./notes.md"
elif [[ -f "$HOME/targets/current/notes.md" ]]; then
  NOTES_FILE="$HOME/targets/current/notes.md"
fi

if [[ -n "$NOTES_FILE" ]]; then
  tmux send-keys -t "$SESSION:1.2" "nvim $NOTES_FILE" C-m
else
  tmux send-keys -t "$SESSION:1.2" "echo '[*] No notes.md found — create with: newbox <name> <ip>'" C-m
fi

# Bottom-right: show listener info
tmux send-keys -t "$SESSION:1.3" "echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'" C-m
tmux send-keys -t "$SESSION:1.3" "echo '  Listener ready — run:'" C-m
tmux send-keys -t "$SESSION:1.3" "echo '  rlisten   (nc -lvnp 4444)'" C-m
tmux send-keys -t "$SESSION:1.3" "echo '  rlisten2  (nc -lvnp 4445)'" C-m
tmux send-keys -t "$SESSION:1.3" "echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'" C-m
if [[ -n "${TARGET:-}" ]]; then
  tmux send-keys -t "$SESSION:1.3" "echo '  TARGET=$TARGET'" C-m
fi
if [[ -n "${LHOST:-}" ]]; then
  tmux send-keys -t "$SESSION:1.3" "echo '  LHOST=$LHOST  LPORT=${LPORT:-4444}'" C-m
fi

# Focus on the main pane
tmux select-pane -t "$SESSION:1.1"

# Attach
exec tmux attach-session -t "$SESSION"
