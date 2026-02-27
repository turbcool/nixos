# Hydenix NixOS Configuration Improvements

## Critical Issues

- [ ] Remove duplicate session variables from `modules/system/default.nix`
  - Location: `modules/system/default.nix` (lines 21-25)
  - Already defined in `modules/system/base/default.nix` (lines 13-17)

## High Priority

- [ ] Secure calendar credentials with agenix
  - Location: `modules/hm/calendar.nix`
  - Currently uses hardcoded path `/home/turb/.radicale-pass`
  - Move to agenix secret
- [ ] Create devShell with development tools
  - Location: `flake.nix`
  - Add: lazygit, lazydocker, nodejs, gcc, ripgrep, gdu, etc.
  - Remove from `modules/system/work/development.nix`

## Medium Priority

- [ ] Clean up commented code in `modules/hm/default.nix`
  - Lines 60-141 contain dead commented-out defaults
  - Remove or document if intentionally preserved
- [ ] Add host-specific flake outputs for multi-machine support
  - Create `hosts/` directory for per-host configurations
  - Unify `hostname = "hydenix"` to be host-specific

## Low Priority

- [ ] Audit all HM modules for unused imports:
  - `vscode.nix` - imported but VSCode disabled in hydenix.hm
  - `neovim.nix` - imported but editors.neovim = false
  - `qutebrowser.nix` - imported, check if qutebrowser module is used
  - `tmux.nix` - imported, verify usage
  - `wolf.nix` - imported, verify usage
- [ ] Document custom modules structure in README
- [ ] Consider moving ark, easyeffects, qbittorrent-enhanced to HM

## Completed

- [x] Consolidate duplicate session variables (WLR_NO_HARDWARE_CURSORS, NIXOS_OZONE_WL, WEATHER_LOCATION)
- [x] Remove git configuration duplication
- [x] Enable agenix for secrets management
- [x] Move user-space tools to Home Manager (neovim, yt-dlp, opencode, telegram-desktop)
- [x] Consolidate firewall rules to single networking.nix file
