```
 ┌─────────────────────────────────────────────────────────┐
 │  ICEBREAKER // CYBERDECK MODIFICATION                   │
 │  "He jacked in and customised his deck for the run."    │
 └─────────────────────────────────────────────────────────┘
```

# Customisation

How to modify IceBreaker to suit your workflow.

## Adding Packages

### To an Existing Category

Edit the relevant module in `modules/pentesting/`. For example, to add a new web tool:

```nix
# modules/pentesting/web.nix
environment.systemPackages = with pkgs; [
  # ... existing tools ...
  my-new-tool     # <- add here
];
```

Then rebuild: `nrs`

### To Base System (Always Available)

Edit `modules/system/base.nix`:

```nix
environment.systemPackages = with pkgs; [
  # ... existing packages ...
  my-tool
];
```

### To Home-Manager (User-Level)

Edit `home/default.nix`:

```nix
home.packages = with pkgs; [
  # ... existing packages ...
  my-tool
];
```

### Finding Package Names

```bash
# Search nixpkgs
ns my-tool                  # nix search nixpkgs my-tool

# Check if a package exists
nix eval nixpkgs#my-tool.name

# Find which package provides a command
, my-command                # comma will find and run it
```

**Watch out for name pitfalls.** Check `DEVLOG.md` (Session 1, entry 4) for known renames. Common gotchas:
- `python3Packages.impacket` not `impacket`
- `noto-fonts-color-emoji` not `noto-fonts-emoji`
- `dust` not `du-dust`
- `wifite2` not `wifite`

## Creating a New Category

### 1. Create the Module

Create `modules/pentesting/my-category.nix`:

```nix
{ config, lib, pkgs, ... }:

with lib;

let cfg = config.pentesting; in

{
  config = mkIf (cfg.enable && cfg.categories.myCategory) {
    environment.systemPackages = with pkgs; [
      tool1
      tool2
      tool3
    ];
  };
}
```

### 2. Register the Option

In `modules/pentesting/default.nix`, add the import and option:

```nix
imports = [
  # ... existing imports ...
  ./my-category.nix
];

options.pentesting.categories = {
  # ... existing options ...
  myCategory = mkEnableOption "description of your category";
};
```

### 3. Add to Presets (Optional)

In `modules/pentesting/presets.nix`, add to relevant presets:

```nix
(mkIf (cfg.preset == "full") {
  pentesting.categories = {
    # ... existing ...
    myCategory = mkDefault true;
  };
})
```

### 4. Add Toggle to configuration.nix

```nix
pentesting.categories = {
  # ... existing ...
  myCategory = false;   # or true
};
```

### 5. Rebuild

```bash
nfc    # Check for errors first
nrs    # Rebuild
```

## Adding Aliases

Edit `home/aliases.nix`:

```nix
programs.zsh.shellAliases = {
  # ... existing aliases ...
  "myalias" = "command here";
};
```

**Rules:**
- Use `$HOME` not `~` in paths
- Escape special characters: `\\n` for newline, `\\` for backslash
- Test the command manually first

## Adding Shell Functions

Edit `home/zsh.nix`, append to the plain string block in `initContent`:

```nix
''
  # ... existing content ...

  # My custom function
  myfunction() {
    local arg="''${1:-default}"    # Note: ''${} for Nix escaping
    echo "Doing something with $arg"
  }
''
```

**Nix escaping rules:**
- `${var}` in shell → write as `''${var}` in Nix `''...''` strings
- `$VAR` (no braces) → safe as-is
- `$(command)` → safe as-is

## Adding Pipx Tools

Edit `scripts/install-pipx-tools.sh`:

```bash
# Add under the appropriate section
pipx_install "package-name" "display-name"
```

## Removing Packages

Delete or comment out the package line from the relevant `.nix` file and rebuild:

```nix
# modules/pentesting/web.nix
environment.systemPackages = with pkgs; [
  # whatweb      # commented out — don't need it
  ffuf
  sqlmap
];
```

```bash
nrs
```

NixOS is declarative — if a package isn't in the config, it's not on the system. No orphans, no leftover files.

### Removing an entire category

Set the toggle to `false` in `configuration.nix`:

```nix
pentesting.categories.wireless = false;
```

All packages from that category are removed on the next rebuild. The module file stays in `modules/pentesting/` but has no effect when disabled.

## Changing the User

The default user is `archangel`. To change it, edit these four files:

1. **`modules/system/base.nix`** — Change `users.users.archangel` to your username
2. **`modules/system/nix-helpers.nix`** — Change `"archangel"` in `trusted-users`
3. **`home/default.nix`** — Change `home.username`, `home.homeDirectory`, and git settings
4. **`flake.nix`** — Change the home-manager user reference

Search for `archangel` across all files to find every reference:
```bash
grep -rn "archangel" --include="*.nix" .
```

## Changing the Hostname

Edit `configuration.nix`:

```nix
networking.hostName = "my-hostname";
```

Also update `flake.nix` if the flake output name changes:

```nix
nixosConfigurations.my-hostname = nixpkgs.lib.nixosSystem { ... };
```

## Changing the Bootloader

Edit `modules/system/base.nix`:

```nix
# For GRUB (default, MBR):
boot.loader.grub.enable = true;
boot.loader.grub.device = "/dev/sda";

# For systemd-boot (UEFI):
boot.loader.systemd-boot.enable = true;
boot.loader.efi.canTouchEfiVariables = true;
```

## Adding Desktop Applications

For GUI apps, add them to `modules/system/base.nix` or create a new module:

```nix
environment.systemPackages = with pkgs; [
  firefox
  chromium
  obsidian       # Note-taking
  flameshot      # Screenshots
];
```

## Disabling Unfree Packages

If you don't want unfree software (removes Burp Suite, etc.):

```nix
# In modules/system/base.nix
nixpkgs.config.allowUnfree = false;
```

You'll need to remove any unfree packages from category modules or the build will fail.
