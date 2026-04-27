{ lib, ... }:

{
  home.file = {
    ".config/hypr/userprefs.conf" = lib.mkForce {
      source = ./hyprland/userprefs.conf;
    };
    ".config/hypr/hypridle.conf" = lib.mkForce {
      source = ./hyprland/hypridle.conf;
    };
    ".config/hypr/hyde.conf" = lib.mkForce {
      source = ./hyprland/hyde.conf;
    };
    ".config/kitty/kitty.conf" = lib.mkForce {
      source = ./hyprland/kitty.conf;
      force = true;
    };
    ".local/share/toggle-sidepad.sh" = {
      source = ./hyprland/toggle-sidepad.sh;
      executable = true;
      force = true;
    };
  };
}
