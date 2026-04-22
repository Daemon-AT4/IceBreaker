# Performance Benchmarking — Methodology

This document describes the benchmark harness shipped with IceBreaker
(`icebreaker-bench`) and how to use it to produce comparable measurements
between IceBreaker (NixOS) and Kali Linux. It is written so that it can be
cited directly in the dissertation methodology chapter.

## Aim

Determine whether a declarative NixOS-based pentesting environment imposes
materially different runtime cost (CPU, memory, disk, network, on-disk
footprint, boot time) compared with a traditional package-managed
distribution (Kali Linux). The deliverable is a set of paired runs — one on
each OS, executed under matched hardware and workload conditions — whose
JSON summary outputs can be diffed and tabulated.

## Instrument

A single POSIX-bash script — [`scripts/icebreaker-bench.sh`](../scripts/icebreaker-bench.sh)
— runs identically on both operating systems. On NixOS it is wrapped as a
self-contained derivation (`pkgs/icebreaker-bench.nix`) and installed system-wide
via `modules/system/base.nix`; on Kali the same `.sh` file is copied across and
invoked directly with `bash`. The script's capability detection adapts to the
tools each OS provides, but the measurement code paths are byte-identical.

### Required runtime dependencies

| Tool             | Used for                            | NixOS source   | Kali install                     |
| ---------------- | ----------------------------------- | -------------- | -------------------------------- |
| `bash` ≥ 4       | script runtime                      | base           | preinstalled                     |
| `jq`             | JSON emit + summary folds           | wrapper        | `apt install jq`                 |
| `coreutils`      | `date`, `cat`, `head`, `tail`, `du` | wrapper        | preinstalled                     |
| `procps`         | `ps`, `free`                        | wrapper        | preinstalled                     |
| `awk` (GNU)      | per-tick aggregation                | wrapper        | preinstalled                     |
| `iproute2`       | network address lookup              | wrapper        | preinstalled                     |
| `util-linux`     | `lscpu`                             | wrapper        | preinstalled                     |

### Optional runtime dependencies (used if present)

| Tool             | Used for                            | NixOS source   | Kali install                       |
| ---------------- | ----------------------------------- | -------------- | ---------------------------------- |
| `mpstat` (sysstat)| precise per-core CPU%              | wrapper        | `apt install sysstat`              |
| `iostat` (sysstat)| per-device disk I/O                | wrapper        | `apt install sysstat`              |
| `lm_sensors`     | hardware temperatures               | wrapper        | `apt install lm-sensors`           |
| `powerstat`      | laptop power draw                   | wrapper        | `apt install powerstat`            |
| `systemd-analyze`| boot-time decomposition             | wrapper        | preinstalled                       |

When an optional tool is missing, the script falls back to `/proc/stat`,
`/proc/diskstats` and `/proc/net/dev` deltas. The two-machine comparability
is preserved because both runs declare which sources fed which metrics in
`meta.json:capabilities`.

## Modes

### `idle` — baseline measurement

```sh
icebreaker-bench idle --duration 300 --interval 5 --label "nixos-idle-1"
```

Records the system at rest. Intended use:

1. Boot the machine.
2. Wait two minutes for desktop login + background services to settle.
3. Run the command above.
4. Do not interact with the system for the duration window.

### `workload` — command-wrapped measurement

```sh
icebreaker-bench workload --duration 300 --interval 5 --label "nixos-nmap-1" \
                          -- nmap -sV -p- 10.10.10.10
```

The script forks the target command, samples the system at the same cadence,
and records the wrapped command's wall-clock time, exit code, peak CPU%, and
peak memory used. The sampling loop terminates the moment the workload
exits, so over-long `--duration` values are safe.

### `compare` — diff two runs

```sh
icebreaker-bench compare ~/icebreaker-bench/nixos-idle-1-... \
                          ~/icebreaker-bench/kali-idle-1-...
```

Reads the canonical `summary.json` from both runs, walks every numeric leaf,
and emits a third JSON document with `{ a, b, delta_pct }` per metric.
Suitable for pasting into the results chapter or further processing in
pandas.

## Sampled metrics (per tick)

Every `--interval` seconds, one JSON object is appended to `samples.jsonl`:

- `cpu_pct` — whole-machine utilisation (mpstat or /proc/stat delta).
- `memory.used_b` / `available_b` / `cached_b` / `swap_used_b` — bytes.
- `load.1m`, `5m`, `15m`, `procs_total` — from `/proc/loadavg`.
- `disk[]` — per-device `r_kbs`, `w_kbs`, `util_pct` (iostat only).
- `network[]` — per non-loopback interface `rx_bps`, `tx_bps` over the tick.
- `top.cpu[]` and `top.memory[]` — top-5 process snapshots.

## Captured-once metadata (per run)

Written to `meta.json` at run start:

- OS identity: `name`, `version`, `id`, `kernel`, `arch`, `hostname`.
- CPU: `model`, `cores`, `threads`, `mhz_max`.
- Memory + swap totals (bytes); `swappiness`; `overcommit_memory`.
- Filesystem usage for `/` and `/nix` (bytes used / total).
- **Package count** — the comparison-critical figure:
  - NixOS: `nix-store -q --requisites /run/current-system | wc -l` (the closure
    of the running system, including build-time deps).
  - Kali / Debian: `dpkg-query -f '.\n' -W | wc -l`.
- **On-disk install size:**
  - NixOS: `du -sb /nix/store`.
  - Kali / Debian: `dpkg-query -W -f='${Installed-Size}\n' | sum × 1024`.
- `systemd.boot_time_s` and `systemd.critical_chain` (when systemd-analyze is
  present).
- `systemd.running_services` — count of currently-active service units.
- `capabilities` — bool flags recording which optional tools were available
  during the run, so methodology reviewers can audit how each metric was
  obtained.

## Summary output

`summary.json` contains, for every numeric series, a `{ n, min, max, mean,
median, p95 }` block. Workload runs additionally include
`workload.exit_code`, `workload.wall_time_seconds`, `workload.peak_cpu_pct`,
`workload.peak_mem_used_b`, plus head/tail snippets of the command's stdout
and stderr.

## Reproducing on Kali

1. Provision a Kali VM with **identical CPU, RAM, disk, and network
   configuration** to the NixOS VM. Document the hypervisor settings.
2. From Kali: `sudo apt update && sudo apt install -y jq sysstat lm-sensors powerstat`.
3. Copy the script over: `scp scripts/icebreaker-bench.sh kali:~/`.
4. Make it executable: `chmod +x ~/icebreaker-bench.sh`.
5. Run the matched commands:
   ```sh
   ./icebreaker-bench.sh idle     --duration 300 --interval 5 --label kali-idle-1
   ./icebreaker-bench.sh workload --duration 300 --interval 5 --label kali-nmap-1 \
       -- nmap -sV -p- <same target>
   ```
6. Copy the resulting directories back: `scp -r kali:~/icebreaker-bench/* ./`.
7. Diff them against the NixOS runs:
   `icebreaker-bench compare ~/icebreaker-bench/nixos-idle-1-...  ./kali-idle-1-...`.

Run each measurement at least three times per OS and report mean ± std
across the three runs in the dissertation, not single observations.

## Worked example

Producing the four-cell table for the *static footprint* section:

```sh
# 1. NixOS — capture metadata only (1-tick run is enough for meta.json).
bench-idle nixos-static --duration 5 --interval 5

# 2. Same on Kali.
./icebreaker-bench.sh idle --duration 5 --interval 5 --label kali-static

# 3. Tabulate from meta.json (no comparison script needed for this).
jq '{os: .os.name, pkgs: .packages.count, on_disk_gb: (.packages.on_disk_b/1024/1024/1024)}' \
   ~/icebreaker-bench/nixos-static-*/meta.json \
   ~/icebreaker-bench/kali-static-*/meta.json
```

## Threats to validity

- **VM noise.** Hypervisor scheduling, balloon drivers, and host I/O
  contention contaminate measurements. Mitigation: pin both VMs to the same
  physical cores, disable ballooning, run host idle, repeat ≥ 3 times.
- **Page cache warmup.** First-run measurements include cold-cache penalties.
  Mitigation: discard the first run of each pair and report runs 2-4.
- **Thermal throttling.** Long workload runs on laptops can be CPU-clocked
  down. Mitigation: run on a desktop/server, or ensure both VMs run in
  identical thermal envelopes; capture `mhz_max` in `meta.json`.
- **Package count semantics.** `dpkg -l` counts user-visible packages; the
  NixOS closure count includes build dependencies and library splits. The
  raw numbers are not directly comparable; report **on-disk install size**
  alongside count and discuss the difference explicitly.
- **Boot time** is sensitive to display-manager configuration, EFI vs MBR,
  and disk type. Match these between the two VMs and document the choice.

## Output layout

```
~/icebreaker-bench/<label>-<UTC>/
├── meta.json          # one-shot system metadata + run params
├── samples.jsonl      # one JSON object per sample tick (NDJSON)
├── summary.json       # min/max/mean/median/p95 per metric (canonical artefact)
└── raw/               # verbatim sampling-tool output for re-analysis
    ├── mpstat.log
    ├── iostat.log
    ├── sensors.jsonl  # only if lm_sensors present
    ├── workload.pid   # workload mode only
    ├── cmd.stdout     # workload mode only
    └── cmd.stderr     # workload mode only
```
