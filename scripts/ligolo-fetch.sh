#!/usr/bin/env bash
# =============================================================================
# IceBreaker — ligolo-ng Fetcher
# -----------------------------------------------------------------------------
# Pulls ligolo-ng release assets from github.com/Nicocha30/ligolo-ng and lays
# them out under $HOME/hacktools/ligolo-ng/ so both the Pirate runbook and
# future HTB AD boxes can pivot without a network trip.
#
# MODES
#   essentials  (default) — latest release, Pirate-relevant platforms only:
#                           proxy   : linux/amd64, linux/arm64
#                           agent   : windows/amd64, linux/amd64
#   latest                — latest release, every platform (~29 files, ~80 MB)
#   all                   — every historical release, every platform
#                           (~26 releases × ~29 assets ≈ 2-3 GB)
#
# Layout:
#   ~/hacktools/ligolo-ng/
#     v0.8.3/                             # one dir per release tag
#       ligolo-ng_0.8.3_checksums.txt
#       ligolo-ng_proxy_0.8.3_linux_amd64.tar.gz
#       proxy                             # extracted binary (linux/amd64)
#       agent.exe                         # extracted binary (windows/amd64)
#       ...
#     v0.8.2/
#     latest -> v0.8.3                    # convenience symlink
#     bin/
#       proxy      -> ../latest/proxy
#       agent.exe  -> ../latest/agent.exe
#
# USAGE
#   ligolo-fetch                   # default: essentials
#   ligolo-fetch --mode latest     # latest release, all platforms
#   ligolo-fetch --mode all        # every release ever shipped
#   ligolo-fetch --dir /opt/ligolo # override output root
#   ligolo-fetch --verify-only     # re-check checksums, download nothing new
# =============================================================================
set -euo pipefail

# ── Colours ──────────────────────────────────────────────────────────────────
BOLD=$'\033[1m'; DIM=$'\033[2m'
CYAN=$'\033[0;36m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[1;33m'
RED=$'\033[0;31m'; NC=$'\033[0m'

# ── Defaults ─────────────────────────────────────────────────────────────────
REPO="Nicocha30/ligolo-ng"
OUT_ROOT="${HOME}/hacktools/ligolo-ng"
MODE="essentials"
VERIFY_ONLY=0

ESSENTIAL_PATTERNS=(
  "ligolo-ng_proxy_.*_linux_amd64\.tar\.gz"
  "ligolo-ng_proxy_.*_linux_arm64\.tar\.gz"
  "ligolo-ng_agent_.*_windows_amd64\.zip"
  "ligolo-ng_agent_.*_linux_amd64\.tar\.gz"
)

# ── Helpers ──────────────────────────────────────────────────────────────────
banner() { printf "\n%s  %s%s\n%s%s%s\n" "${BOLD}${CYAN}" "$1" "${NC}" "${DIM}" "────────────────────────────────────────────────────────────────" "${NC}"; }
info()   { printf "%s  [+]%s %s\n" "${GREEN}"  "${NC}" "$*"; }
warn()   { printf "%s  [!]%s %s\n" "${YELLOW}" "${NC}" "$*"; }
err()    { printf "%s  [x]%s %s\n" "${RED}"    "${NC}" "$*" >&2; }
die()    { err "$*"; exit 1; }

have() { command -v "$1" >/dev/null 2>&1; }

for bin in curl python3 tar sha256sum; do
  have "$bin" || die "missing dependency: $bin"
done

# ── Args ─────────────────────────────────────────────────────────────────────
usage() { sed -n '2,35p' "$0" | sed 's/^# \{0,1\}//'; exit "${1:-0}"; }

while [ $# -gt 0 ]; do
  case "$1" in
    --mode)         MODE="$2"; shift 2 ;;
    --dir)          OUT_ROOT="$2"; shift 2 ;;
    --verify-only)  VERIFY_ONLY=1; shift ;;
    -h|--help)      usage 0 ;;
    *) die "unknown flag: $1" ;;
  esac
done

case "$MODE" in essentials|latest|all) ;; *) die "invalid --mode: $MODE (essentials|latest|all)";; esac

# ── GitHub API: list releases ────────────────────────────────────────────────
banner "IceBreaker // ligolo-ng fetcher"
info "repo     : $REPO"
info "out-root : $OUT_ROOT"
info "mode     : $MODE"
mkdir -p "$OUT_ROOT"

api_url="https://api.github.com/repos/${REPO}/releases?per_page=100"
headers=(-H "Accept: application/vnd.github+json")
# If GH_TOKEN is set, use it to bump the 60 req/hr rate limit to 5000.
[ -n "${GH_TOKEN:-}" ] && headers+=(-H "Authorization: Bearer ${GH_TOKEN}")

releases_json="${OUT_ROOT}/.releases.json"
if [ "$VERIFY_ONLY" = "0" ] || [ ! -s "$releases_json" ]; then
  info "fetching release index…"
  curl -fsSL "${headers[@]}" "$api_url" -o "$releases_json" \
    || die "failed to fetch release metadata (rate-limit? try GH_TOKEN=<pat>)"
fi

# ── Decide which (tag, asset) pairs to download ──────────────────────────────
mapfile -t TASK_LINES < <(python3 - "$releases_json" "$MODE" "${ESSENTIAL_PATTERNS[@]}" <<'PY'
import json, re, sys
path, mode, *patterns = sys.argv[1:]
with open(path) as f: data = json.load(f)
# Sort newest first (GitHub already does but be explicit).
data.sort(key=lambda r: r["published_at"] or "", reverse=True)
if mode in ("essentials","latest") and data:
    data = data[:1]
for rel in data:
    tag = rel["tag_name"]
    for a in rel["assets"]:
        name = a["name"]
        url  = a["browser_download_url"]
        size = a["size"]
        if mode == "essentials":
            # checksums always included; platform assets only if they match.
            if not name.endswith("checksums.txt") and not any(re.match(p, name) for p in patterns):
                continue
        print(f"{tag}\t{name}\t{size}\t{url}")
PY
)

total=${#TASK_LINES[@]}
[ "$total" -eq 0 ] && die "no assets selected for mode=$MODE"
info "selected ${total} asset(s)"

# ── Download + verify ────────────────────────────────────────────────────────
fetched=0 skipped=0 failed=0

for line in "${TASK_LINES[@]}"; do
  IFS=$'\t' read -r tag name size url <<<"$line"
  dir="${OUT_ROOT}/${tag}"
  dest="${dir}/${name}"
  mkdir -p "$dir"

  if [ "$VERIFY_ONLY" = "0" ] && [ ! -f "$dest" ]; then
    printf "  %s fetching %s / %s (%d B)…%s\n" "${DIM}" "$tag" "$name" "$size" "${NC}"
    if curl -fsSL --retry 3 -o "$dest" "$url"; then
      fetched=$((fetched+1))
    else
      failed=$((failed+1)); warn "download failed: $name"; continue
    fi
  else
    skipped=$((skipped+1))
  fi
done
info "fetched: $fetched  skipped: $skipped  failed: $failed"

# ── Verify checksums per release ─────────────────────────────────────────────
banner "Checksum verification"
shopt -s nullglob
for tag_dir in "${OUT_ROOT}"/v*; do
  [ -d "$tag_dir" ] || continue
  sums_arr=( "${tag_dir}"/ligolo-ng_*_checksums.txt )
  sums="${sums_arr[0]:-}"
  [ -z "$sums" ] && continue
  pass=0; fail=0
  while IFS= read -r sumline; do
    sum="${sumline%% *}"
    fname=$(echo "$sumline" | awk '{print $NF}')
    [ -f "${tag_dir}/${fname}" ] || continue
    actual=$(sha256sum "${tag_dir}/${fname}" | awk '{print $1}')
    if [ "$actual" = "$sum" ]; then pass=$((pass+1)); else fail=$((fail+1)); warn "HASH MISMATCH: ${tag_dir}/${fname}"; fi
  done < "$sums"
  printf "  %s %-12s  ok=%d  bad=%d\n" "${GREEN}✓${NC}" "$(basename "$tag_dir")" "$pass" "$fail"
done

# ── Extract per-version binaries ─────────────────────────────────────────────
banner "Extracting binaries"
for tag_dir in "${OUT_ROOT}"/v*; do
  [ -d "$tag_dir" ] || continue
  # Linux/amd64 proxy
  lx_arr=( "${tag_dir}"/ligolo-ng_proxy_*_linux_amd64.tar.gz ); lx="${lx_arr[0]:-}"
  if [ -n "$lx" ] && [ ! -f "${tag_dir}/proxy" ]; then
    tar -xzf "$lx" -C "$tag_dir" proxy 2>/dev/null && chmod +x "${tag_dir}/proxy" \
      && info "$(basename "$tag_dir") proxy (linux/amd64) extracted"
  fi
  # Windows/amd64 agent
  wa_arr=( "${tag_dir}"/ligolo-ng_agent_*_windows_amd64.zip ); wa="${wa_arr[0]:-}"
  if [ -n "$wa" ] && [ ! -f "${tag_dir}/agent.exe" ]; then
    ( cd "$tag_dir" && python3 -c "import zipfile,sys; zipfile.ZipFile(sys.argv[1]).extractall('.')" "$wa" ) 2>/dev/null \
      && info "$(basename "$tag_dir") agent.exe (windows/amd64) extracted"
  fi
  # Linux/amd64 agent
  la_arr=( "${tag_dir}"/ligolo-ng_agent_*_linux_amd64.tar.gz ); la="${la_arr[0]:-}"
  if [ -n "$la" ] && [ ! -f "${tag_dir}/agent" ]; then
    tar -xzf "$la" -C "$tag_dir" agent 2>/dev/null && chmod +x "${tag_dir}/agent" \
      && info "$(basename "$tag_dir") agent (linux/amd64) extracted"
  fi
done
shopt -u nullglob

# ── Convenience symlinks ─────────────────────────────────────────────────────
banner "Convenience symlinks"
shopt -s nullglob
tag_dirs=( "${OUT_ROOT}"/v[0-9]* )
shopt -u nullglob
latest_tag=""
if [ "${#tag_dirs[@]}" -gt 0 ]; then
  latest_tag=$(printf '%s\n' "${tag_dirs[@]}" | xargs -n1 basename | sort -V | tail -1)
fi
if [ -n "$latest_tag" ]; then
  ln -sfn "$latest_tag" "${OUT_ROOT}/latest"
  info "latest -> $latest_tag"
  mkdir -p "${OUT_ROOT}/bin"
  for b in proxy agent agent.exe; do
    [ -f "${OUT_ROOT}/latest/$b" ] && ln -sfn "../latest/$b" "${OUT_ROOT}/bin/$b" && info "bin/$b -> latest/$b"
  done
fi

# ── Summary ──────────────────────────────────────────────────────────────────
banner "Done"
info "Output root     : $OUT_ROOT"
info "Latest version  : ${latest_tag:-(none)}"
info "Quick start     :"
echo "    sudo ${OUT_ROOT}/bin/proxy -selfcert"
echo "    # on target (Windows):  upload ${OUT_ROOT}/bin/agent.exe"
echo "    # on target (Linux)  :  scp ${OUT_ROOT}/bin/agent <target>:/tmp/"
echo
info "For the Pirate-specific walkthrough see docs/ligolo-ng.md"
