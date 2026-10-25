{
  config,
  lib,
  pkgs,
  ...
}:

# Windows-style desktop switching. Omarchy's ~/.config/hypr is seeded, not
# managed -- a read-only store symlink would break `omarchy refresh hyprland`
# and hand editing -- so the override is appended to the seeded bindings.lua
# rather than shipped as a home.file.
let
  marker = "Windows-style desktop switching";
  block = ''
    -- ${marker}. Defaults were grouped-window focus.
    hl.unbind("SUPER + CTRL + LEFT")
    hl.unbind("SUPER + CTRL + RIGHT")
    o.bind("SUPER + CTRL + LEFT", "Previous workspace", hl.dsp.focus({ workspace = "e-1" }))
    o.bind("SUPER + CTRL + RIGHT", "Next workspace", hl.dsp.focus({ workspace = "e+1" }))
  '';
in
{
  # After the seed, or a first activation would append to a file not there yet.
  home.activation.nixarchyWorkspaceBindings = lib.hm.dag.entryAfter [ "nixarchySeed" ] ''
    bindings="${config.xdg.configHome}/hypr/bindings.lua"
    if [ -f "$bindings" ] && ! grep -qF ${lib.escapeShellArg marker} "$bindings"; then
      run ${pkgs.coreutils}/bin/printf %s ${lib.escapeShellArg ("\n" + block)} >> "$bindings"
    fi
  '';
}
