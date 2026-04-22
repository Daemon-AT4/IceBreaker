# ┌─────────────────────────────────────────────────────────────┐
# │  icebreaker-bench — Nix wrapper                             │
# │                                                             │
# │  Wraps scripts/icebreaker-bench.sh so the binary on $PATH   │
# │  has every runtime dependency baked in. Result: zero        │
# │  surprises on the NixOS side. The same .sh works on Kali    │
# │  with apt-installed sysstat + jq (its capability detection  │
# │  handles missing tools gracefully).                         │
# └─────────────────────────────────────────────────────────────┘
{ lib
, stdenv
, makeWrapper
, bash
, coreutils
, gawk
, gnugrep
, gnused
, jq
, procps
, util-linux
, sysstat       # mpstat, iostat
, iproute2
, hostname
, systemd       # systemd-analyze, systemctl
, nettools      # `hostname` fallback on minimal systems
, lm_sensors    # optional: temps
, powerstat     # optional: laptop power
}:

stdenv.mkDerivation {
  pname   = "icebreaker-bench";
  version = "0.1.0";

  src = ../scripts;

  nativeBuildInputs = [ makeWrapper ];

  # Single script — no compile step. Just install it and wrap.
  dontConfigure = true;
  dontBuild     = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 icebreaker-bench.sh "$out/bin/icebreaker-bench"
    runHook postInstall
  '';

  postFixup = ''
    wrapProgram "$out/bin/icebreaker-bench" \
      --prefix PATH : ${lib.makeBinPath [
        bash coreutils gawk gnugrep gnused jq
        procps util-linux sysstat iproute2
        hostname systemd lm_sensors powerstat nettools
      ]}
  '';

  meta = with lib; {
    description = "Portable system-resource benchmark for NixOS vs Kali comparison";
    longDescription = ''
      Measures CPU, memory, disk, network, load, and per-process consumption
      over a configurable window. Captures system metadata (kernel, package
      count, on-disk install size, boot time) so the same script produces
      directly-comparable JSON reports on both NixOS and Kali Linux.

      Subcommands: idle | workload | compare.
    '';
    homepage    = "https://github.com/yourusername/IceBreaker";
    license     = licenses.mit;
    platforms   = platforms.linux;
    mainProgram = "icebreaker-bench";
  };
}
