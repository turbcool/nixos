# Desktop Environment settings (Hyprland, Waybar, Audio, Fonts, etc.)
{ config, pkgs, ... }:

{
  hardware = {
    graphics.enable = true;
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
    };
  };
  services.xserver.videoDrivers = ["nvidia"];

# Configure keymap in X11 (relevant for graphical sessions)
  services.xserver.xkb = {
    layout = "us,ru";
    options = "grp:alt_shift_toggle";
  };

#  fonts = {
#    enableDefaultPackages = true;
#    packages = with pkgs; [
#      noto-fonts
#      noto-fonts-emoji
#      font-awesome
#    ];
#  };

#  xdg.portal.xdgOpenUsePortal = true;

#  programs.hyprland.xwayland.enable = true;
}
