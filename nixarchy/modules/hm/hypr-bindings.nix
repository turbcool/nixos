{
  config,
  lib,
  pkgs,
  ...
}:

# Windows-style overrides. Omarchy's ~/.config/hypr is seeded, not managed -- a
# read-only store symlink would break `omarchy refresh hyprland` and hand
# editing -- so each block is appended to the seeded bindings.lua rather than
# shipped as a home.file. Its marker keeps a block from being appended twice.
let
  blocks = [
    {
      marker = "Windows-style desktop switching";
      text = ''
        -- Windows-style desktop switching. Defaults were grouped-window focus.
        hl.unbind("SUPER + CTRL + LEFT")
        hl.unbind("SUPER + CTRL + RIGHT")
        o.bind("SUPER + CTRL + LEFT", "Previous workspace", hl.dsp.focus({ workspace = "e-1" }))
        o.bind("SUPER + CTRL + RIGHT", "Next workspace", hl.dsp.focus({ workspace = "e+1" }))
      '';
    }
    {
      marker = "Windows-style app shortcuts";
      text = ''
        -- Windows-style app shortcuts. SUPER+T was float toggle, SUPER+W close.
        hl.unbind("SUPER + T")
        o.bind("SUPER + T", "Terminal", { omarchy = "terminal" })
        o.bind("SUPER + A", "Omarchy menu", "omarchy-menu toggle")
        o.bind("SUPER + Q", "Close window", hl.dsp.window.close())
        o.bind("SUPER + E", "File manager", { omarchy = "nautilus" })
        -- SUPER+S already toggles the scratchpad (the floating "stash" overlay).
      '';
    }
  ];
in
{
  # After the seed, or a first activation would append to a file not there yet.
  home.activation.nixarchyHyprBindings = lib.hm.dag.entryAfter [ "nixarchySeed" ] (
    lib.concatMapStrings (b: ''
      bindings="${config.xdg.configHome}/hypr/bindings.lua"
      if [ -f "$bindings" ] && ! grep -qF ${lib.escapeShellArg b.marker} "$bindings"; then
        run ${pkgs.coreutils}/bin/printf %s ${lib.escapeShellArg ("\n" + b.text)} >> "$bindings"
      fi
    '') blocks
  );
}
