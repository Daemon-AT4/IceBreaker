```
 ┌─────────────────────────────────────────────────────────┐
 │  ICEBREAKER // NEURAL INTERFACE AESTHETICS              │
 │  "Lines of light ranged in the nonspace of the mind,    │
 │   clusters and constellations of data."  — Neuromancer  │
 └─────────────────────────────────────────────────────────┘
```

# Theming

IceBreaker uses [Stylix](https://github.com/nix-community/stylix) for system-wide theming. The default theme is **Rose Pine (dark)**.

## How Stylix Works

Stylix takes a base16 colour scheme and applies it everywhere:
- Terminal colours (Alacritty)
- GTK 3/4 apps (Firefox, file manager, XFCE panels)
- Bat (syntax highlighting)
- FZF (fuzzy finder)
- Shell prompt (via Powerlevel10k)
- GRUB boot screen
- LightDM login screen

One config, consistent colours everywhere.

## Current Theme: Rose Pine Dark

The theme is defined inline in `modules/system/stylix.nix` using base16 hex values:

| Slot | Colour | Hex | Used For |
|------|--------|-----|----------|
| base00 | Dark background | `#191724` | Terminal/editor background |
| base01 | Lighter background | `#1f1d2e` | Status bars, selections |
| base02 | Selection | `#26233a` | Visual selection |
| base03 | Comments | `#6e6a86` | Subtle text |
| base04 | Dark foreground | `#908caa` | Inactive text |
| base05 | Foreground | `#e0def4` | Main text |
| base06 | Light foreground | `#e0def4` | Bright text |
| base07 | Lightest | `#524f67` | Borders |
| base08 | Red (Love) | `#eb6f92` | Errors, deletions |
| base09 | Orange (Rose) | `#f6c177` | Warnings, strings |
| base0A | Yellow (Gold) | `#ebbcba` | Modified, search |
| base0B | Green (Foam) | `#9ccfd8` | Success, additions |
| base0C | Cyan (Pine) | `#31748f` | Info, types |
| base0D | Blue (Iris) | `#c4a7e7` | Functions, directories |
| base0E | Purple | `#c4a7e7` | Keywords |
| base0F | Brown | `#524f67` | Deprecated |

## Changing the Theme

### Using a Built-in Base16 Scheme

Stylix supports any base16 scheme. Replace the inline scheme in `modules/system/stylix.nix`:

```nix
stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";
```

Popular schemes:
- `tokyo-night-dark`
- `catppuccin-mocha`
- `dracula`
- `gruvbox-dark-hard`
- `nord`
- `one-dark`
- `solarized-dark`

### Using a Custom Scheme

Keep the inline definition but change the hex values:

```nix
stylix.base16Scheme = {
  base00 = "1a1b26";  # background
  base01 = "16161e";
  # ... etc
};
```

Use [base16-gallery](https://tinted-theming.github.io/base16-gallery/) to preview schemes.

### After Changing the Theme

```bash
nrs              # Rebuild
exec zsh         # Reload shell
# Log out and back in for full GTK/XFCE application
```

## Fonts

Fonts are configured in `modules/system/stylix.nix`:

```nix
stylix.fonts = {
  monospace = {
    name = "JetBrainsMono Nerd Font";
    package = pkgs.nerd-fonts.jetbrains-mono;
  };
  sansSerif = {
    name = "Noto Sans";
    package = pkgs.noto-fonts;
  };
  serif = {
    name = "Noto Serif";
    package = pkgs.noto-fonts;
  };
  emoji = {
    name = "Noto Color Emoji";
    package = pkgs.noto-fonts-color-emoji;
  };
  sizes = {
    terminal = 12;
    applications = 11;
    desktop = 11;
    popups = 11;
  };
};
```

### Changing Monospace Font

```nix
monospace = {
  name = "FiraCode Nerd Font";
  package = pkgs.nerd-fonts.fira-code;
};
```

Available Nerd Fonts: `nerd-fonts.jetbrains-mono`, `nerd-fonts.fira-code`, `nerd-fonts.hack`, `nerd-fonts.iosevka`, etc.

## Powerlevel10k Prompt

The prompt is configured in `home/p10k.zsh`. It uses Rose Pine colours mapped to p10k segments.

### Prompt Segments (Left)

- **Directory** — Iris purple background
- **VCS (git)** — Foam green (clean) / Gold (modified) / Love red (conflict)

### Prompt Segments (Right)

- **Status** — Love red on error
- **Command duration** — Gold background
- **Nix shell** — Pine teal background
- **Time** — Subtle grey

### Reconfiguring the Prompt

```bash
p10k configure     # Interactive wizard
```

This regenerates `~/.p10k.zsh`. To make it persistent, copy back:

```bash
cp ~/.p10k.zsh ~/IceBreaker/home/p10k.zsh
nrs
```

## Opacity / Transparency

Stylix supports terminal and application opacity:

```nix
stylix.opacity = {
  terminal    = 0.95;   # 95% opaque
  applications = 1.0;   # fully opaque
  desktop     = 1.0;
  popups      = 1.0;
};
```

## XFCE Notes

- XFCE is GTK-native, so Stylix applies cleanly with no workarounds
- No need to disable any Stylix targets — everything works out of the box
- After rebuilding, log out and back in for XFCE panels and GTK apps to pick up the new colours
- XFCE was chosen over KDE Plasma 6 because Stylix's Qt/KDE targets conflict with Plasma's own theming stack (causes black screen after login)

## FZF and Bat

Colours for FZF and Bat are **managed by Stylix automatically**. Do not set custom colour blocks in `home/default.nix` — they will conflict.

If you need to override FZF behaviour (not colours), use:

```nix
programs.fzf.defaultOptions = [
  "--height 40%"
  "--layout=reverse"
  "--border"
];
```
