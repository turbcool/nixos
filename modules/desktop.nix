# Desktop Environment settings (Hyprland, Waybar, Audio, Fonts, etc.)
{ config, pkgs, ... }:

{
  # Configure keymap in X11 (relevant for graphical sessions)
  services.xserver.xkb = {
    layout = "ru";
    variant = "";
  };

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-emoji
      font-awesome
    ];
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ]; # Ensure this matches package list if needed elsewhere

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  programs.waybar.enable = true;
}
