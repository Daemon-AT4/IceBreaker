# ┌─────────────────────────────────────────────────────────────┐
# │  IceBreaker — Nix Tooling & Settings                       │
# │  Flake settings, binary caches, garbage collection,        │
# │  and developer tools for working with Nix itself.          │
# │                                                            │
# │  These packages help you inspect, format, lint, and        │
# │  navigate the Nix store. Not pentesting tools — those      │
# │  go in modules/pentesting/*.nix.                           │
# └─────────────────────────────────────────────────────────────┘
{ config, pkgs, ... }:

{
  # ============================================================
  # Nix settings — flakes, store, caches
  # ============================================================
  nix = {
    settings = {
      # Enable flakes and the new `nix` CLI (nix build, nix run, etc.)
      experimental-features = [ "nix-command" "flakes" ];

      # Hard-link identical files in the store to save disk space
      auto-optimise-store   = true;

      # Users allowed to connect to the Nix daemon with elevated trust
      # (needed for cachix, nix copy, etc.)
      trusted-users         = [ "root" "archangel" ];

      # Binary caches — download pre-built packages instead of compiling
      # Add more caches here if you use cachix for custom packages
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dde0enAfDak3orWOS2tZJjoLogMce9xBo="
      ];
    };

    # Automatic garbage collection — keeps disk usage in check
    # Change "30d" to keep more/fewer generations
    gc = {
      automatic = true;
      dates     = "weekly";
      options   = "--delete-older-than 30d";
    };
  };

  # ============================================================
  # Nix helper packages
  # ============================================================
  environment.systemPackages = with pkgs; [
    # ── Flake / store introspection ────────────────────────────
    nix-tree      # interactive dependency tree browser
    nix-diff      # diff two derivations
    nix-du        # disk usage in the nix store
    nvd           # diff system generations (like apt changelog)

    # ── Build output / UX ──────────────────────────────────────
    nix-output-monitor   # pretty build progress (nom)
    nh                   # nice wrapper: nh os switch, nh clean

    # ── Formatters & linters ───────────────────────────────────
    alejandra     # opinionated nix formatter
    nixpkgs-fmt   # alternative formatter
    deadnix       # find & remove dead nix code
    statix        # nix anti-pattern linter

    # ── LSP ────────────────────────────────────────────────────
    nil           # nix language server (use with neovim/vscode)

    # ── Run anything without installing ────────────────────────
    comma         # , nmap → nix run nixpkgs#nmap

    # ── Index (used by command-not-found handler) ──────────────
    nix-index
  ];

  # ============================================================
  # command-not-found integration
  # When you type a command that isn't installed, nix-index
  # suggests which package provides it.
  # ============================================================
  programs.nix-index = {
    enable               = true;
    enableZshIntegration = true;
  };
  # Disable the default handler so nix-index takes over
  programs.command-not-found.enable = false;
}
