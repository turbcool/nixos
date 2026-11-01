{
  config,
  lib,
  pkgs,
  ...
}:

# Language switching for the fcitx5-hosted Russian: Ctrl+Space, Alt+Shift and
# Ctrl+Shift, all as *modifier-only* triggers. The XKB layout stays English-only
# (see ~/.config/hypr/input.lua) because Hyprland matches keybinds by keysym, so
# a Cyrillic group would kill every SUPER+<letter> bind.
#
# Two things about the file format, learned the hard way:
#   * fcitx5's INI stores a key *list* as a numeric sub-section
#     ([Hotkey/TriggerKeys] 0=... 1=...). A comma-separated one-liner is read as
#     a plain string, the List|Key parser finds no items, and the list is empty
#     -- which silently disables Ctrl+Space too.
#   * fcitx5 rewrites this file itself (auto-save and on exit), so it cannot be
#     a read-only home.file symlink into the store. Seed a copy instead, and
#     leave an existing file alone: the user's own edits win, same rule as
#     nixarchySeed (`cp --update=none`).
let
  seed = ./fcitx5/config;
in
{
  home.activation.fcitx5Hotkeys = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    target="${config.xdg.configHome}/fcitx5/config"
    if [ ! -e "$target" ]; then
      run mkdir -p "$(dirname "$target")"
      run ${pkgs.coreutils}/bin/cp --no-preserve=mode,ownership ${seed} "$target"
    fi
  '';
}