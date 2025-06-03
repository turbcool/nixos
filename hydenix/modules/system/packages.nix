# Package definitions and program configurations
{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    pkgs.telegram-desktop
    pkgs.yt-dlp
    pkgs.kdePackages.ark
    pkgs.easyeffects

    # Security:
    pkgs.bitwarden-cli
  ];
}
