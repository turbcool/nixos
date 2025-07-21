{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    pkgs.neovim
    pkgs.nodejs
    pkgs.lazygit
    pkgs.lazydocker
    pkgs.ripgrep
    pkgs.gdu
    pkgs.gcc
    pkgs.aider-chat
    pkgs.userPkgs.yazi
    pkgs.unrar
    pkgs.cudatoolkit
    pkgs.jan
    pkgs.postgresql_17
    pkgs.zotero
    pkgs.nmap
    pkgs.platformio
  ];

  programs.npm.enable = true;

  services.v2raya = {
    enable = true;
    cliPackage = pkgs.xray;
  };
  # TODO: HM copy nvim config from git to ~/.config/nvim
}
