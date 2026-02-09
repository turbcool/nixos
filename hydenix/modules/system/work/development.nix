{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    pkgs.nodejs
    pkgs.lazygit
    pkgs.lazydocker
    pkgs.ripgrep
    pkgs.gdu
    pkgs.gcc
    pkgs.yazi
    pkgs.unrar
    #pkgs.cudatoolkit
    pkgs.postgresql_17
    pkgs.zotero
    pkgs.nmap
    pkgs.dnsutils
    #pkgs.platformio
  ];

  #services.udev.packages = with pkgs; [ platformio-core.udev ];

  programs.npm.enable = true;

  services.v2raya = {
    enable = true;
    cliPackage = pkgs.xray;
  };
}
