{ config, pkgs, lib, ... }:

{
  stylix = {
    enable = true;

    # ── Colour scheme — Rosé Pine (dark) ──────────────────────────
    # Inline base16 scheme; edit hex values to tweak individual colours.
    base16Scheme = {
      scheme  = "Rose Pine";
      author  = "Emilia Dunfelt (edunfelt)";
      # ── Backgrounds ─────────────────────────────────────────────
      base00  = "191724";   # main        (background)
      base01  = "1f1d2e";   # surface     (lighter bg)
      base02  = "26233a";   # overlay     (selection bg)
      base03  = "6e6a86";   # muted       (comments, ignored)
      # ── Foregrounds ─────────────────────────────────────────────
      base04  = "908caa";   # subtle      (dark foreground)
      base05  = "e0def4";   # text        (default foreground)
      base06  = "e0def4";   # text        (light foreground)
      base07  = "faf4ed";   # highlight   (lightest)
      # ── Accents ─────────────────────────────────────────────────
      base08  = "eb6f92";   # love        (red/errors/variables)
      base09  = "f6c177";   # gold        (orange/constants)
      base0A  = "ebbcba";   # rose        (yellow/classes)
      base0B  = "9ccfd8";   # foam        (green/strings)
      base0C  = "31748f";   # pine        (cyan/regex)
      base0D  = "c4a7e7";   # iris        (blue/functions)
      base0E  = "eb6f92";   # love        (purple/keywords)
      base0F  = "524f67";   # highlight   (deprecated/special)
    };

    # ── Polarity — always dark ────────────────────────────────────
    polarity = "dark";

    # ── Wallpaper ─────────────────────────────────────────────────
    image = ../../wallpapers/nix-wallpaper-dracula.png;

    # ── Fonts ─────────────────────────────────────────────────────
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name    = "JetBrainsMono Nerd Font Mono";
      };
      sansSerif = {
        package = pkgs.noto-fonts;
        name    = "Noto Sans";
      };
      serif = {
        package = pkgs.noto-fonts;
        name    = "Noto Serif";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name    = "Noto Color Emoji";
      };
      sizes = {
        terminal     = 15;
        applications = 12;
        desktop      = 12;
        popups       = 12;
      };
    };

    # ── Opacity ───────────────────────────────────────────────────
    opacity = {
      terminal     = 0.95;
      applications = 1.0;
    };

    # ── Targets ───────────────────────────────────────────────────
    # Stylix enables all supported targets by default.
    # XFCE uses GTK natively — no Qt workarounds needed.
    # NOTE: dunst and rofi targets are disabled in home/xfce.nix (HM scope).
  };

  # ── Remove font config from base.nix — stylix handles it ──────
  # (fonts.fontconfig.defaultFonts is set by stylix)
}
