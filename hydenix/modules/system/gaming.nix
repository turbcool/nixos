{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    pkgs.lutris
    pkgs.prismlauncher
    pkgs.qbittorrent-enhanced
  ];

  programs.steam.enable = true;
  programs.alvr.enable = true;
  programs.alvr.openFirewall = true;

  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };
}
