# Package definitions and program configurations
{ config, pkgs, ... }:

{
  programs.mpv.enable = true;
  environment.systemPackages = with pkgs; [
    pkgs.telegram-desktop
    pkgs.yt-dlp
    pkgs.kdePackages.ark
    pkgs.easyeffects
  ];
}
