{ pkgs, ... }:

{
  # Omarchy ships foot and binds its terminal key to it. Kitty is kept because
  # it is configured here; both can coexist. Rebind in ~/.config/hypr/bindings.lua
  # if you want the menu to open kitty.
  home.packages = [ pkgs.kitty ];

  home.file = {
    ".config/kitty/kitty.conf" = {
      source = ./kitty/kitty.conf;
      force = true;
    };
    ".local/share/toggle-sidepad.sh" = {
      source = ../../../hydenix/modules/hm/hyprland/toggle-sidepad.sh;
      executable = true;
    };
  };
}
