{ config, pkgs, ... }:

let
  dotnet-sdk =
    (with pkgs.dotnetCorePackages;
    combinePackages [
      sdk_8_0
      sdk_9_0
    ]);
  dotnetRoot = "${dotnet-sdk}/share/dotnet";
in
{
  environment.systemPackages = with pkgs; [
    dotnet-sdk
    pkgs.neovim
    pkgs.nodejs
    pkgs.roslyn-ls
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
  ];

  programs.npm.enable = true;

  environment.sessionVariables = {
    DOTNET_ROOT = dotnetRoot;
  };

  networking.firewall = {
    allowedTCPPorts = [ 5173 5174 ];
  };

  # TODO: HM copy nvim config from git to ~/.config/nvim
}
