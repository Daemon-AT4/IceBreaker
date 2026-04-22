# ┌─────────────────────────────────────────────────────────────┐
# │  ICEBREAKER — NixOS Pentesting Environment                 │
# │  This is the flake entry point. It wires together all      │
# │  inputs (nixpkgs, home-manager, stylix) and produces       │
# │  NixOS system configurations as outputs.                   │
# │                                                            │
# │  Supports: x86_64-linux (Intel/AMD) and aarch64-linux      │
# │  (ARM64 — Raspberry Pi, Asahi Linux on Apple Silicon, etc) │
# └─────────────────────────────────────────────────────────────┘
{
  description = "IceBreaker - NixOS Pentesting Environment (Modular Flake)";

  # ── Inputs — external dependencies pinned by flake.lock ────
  # To update all:   nix flake update
  # To update one:   nix flake update stylix
  inputs = {
    # Package set — nixos-unstable gives us the latest packages
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home Manager — manages user-level dotfiles, shell, git, etc.
    # "follows" pins it to the same nixpkgs so everything is compatible
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix-index — provides the "command-not-found" handler
    # (type a missing command → it suggests which package to install)
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Stylix — system-wide theming (terminals, editors, shell colours, fonts)
    # Applies a base16 colour scheme to everything automatically
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # ── Outputs — what this flake produces ─────────────────────
  outputs = { self, nixpkgs, home-manager, nix-index-database, stylix, ... }@inputs:
  let
    # Helper: build a NixOS configuration for any architecture.
    # Usage:  mkSystem "x86_64-linux"   or   mkSystem "aarch64-linux"
    mkSystem = system: nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        ./hardware-configuration.nix
        ./configuration.nix

        # Home Manager as a NixOS module (embedded — NOT standalone)
        # This means `nrs` rebuilds both system AND home config together.
        # Do NOT also run `nh home switch` — it won't work in this mode.
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs    = true;   # Use system-level nixpkgs (no separate pin)
            useUserPackages  = true;   # Install user packages to /etc/profiles
            extraSpecialArgs = { inherit inputs; };
            users.archangel  = import ./home/default.nix;
            # NOTE: Do NOT add stylix to sharedModules — it auto-injects (see below)
          };
        }

        # Stylix NixOS module — applies theme system-wide AND auto-injects
        # into home-manager. Never add it to home-manager.sharedModules too.
        stylix.nixosModules.stylix

        # nix-index command-not-found handler
        nix-index-database.nixosModules.nix-index
      ];
    };

    # Architectures we publish standalone packages for.
    supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
    forAllSystems    = nixpkgs.lib.genAttrs supportedSystems;
  in {
    nixosConfigurations = {
      # ── x86_64 (Intel/AMD) — most common ────────────────────
      # Rebuild: sudo nixos-rebuild switch --flake .#icebreaker
      icebreaker = mkSystem "x86_64-linux";

      # ── aarch64 (ARM64) — Raspberry Pi, Apple Silicon, etc ──
      # For Asahi Linux (M-series Macs), ARM servers, Pi 4/5.
      # Rebuild: sudo nixos-rebuild switch --flake .#icebreaker-aarch64
      # NOTE: Some packages (burpsuite, metasploit) may not have
      # ARM64 binaries — disable those categories or use emulation.
      icebreaker-aarch64 = mkSystem "aarch64-linux";
    };

    # ── Standalone packages ────────────────────────────────────
    # Build with:  nix build .#icebreaker-bench
    # Produces ./result/bin/icebreaker-bench — a self-contained
    # benchmark binary that can be scp'd to a Kali VM as well
    # (the underlying script is POSIX-portable; on Kali install
    #  `sysstat jq` via apt and run the raw scripts/icebreaker-bench.sh
    #  rather than the wrapped store path).
    packages = forAllSystems (system:
      let pkgs = import nixpkgs { inherit system; };
      in {
        icebreaker-bench = pkgs.callPackage ./pkgs/icebreaker-bench.nix { };
        default          = pkgs.callPackage ./pkgs/icebreaker-bench.nix { };
      });

    # `nix fmt` reserved slot — alejandra is in nix-helpers.nix already.
    # formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);
  };
}
