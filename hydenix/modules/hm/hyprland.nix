{ 
  lib,
  pkgs,
  config,
  ...
}:

{
  ".config/hypr/userprefs.conf" = lib.mkForce {
    source = ../config/hyprland/userprefs.conf;
  };
  ".config/hypr/hypridle.conf" = lib.mkForce {
    source = ../config/hyprland/hypridle.conf;
  };
  ".config/hypr/hyde.conf" = lib.mkForce {
    source = ../config/hyprland/hyde.conf;
  };
  ".config/kitty/kitty.conf" = lib.mkForce {
    source = ../config/hyprland/kitty.conf;
    force = true;
  };
}
