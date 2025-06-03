{ config, pkgs, ... }:

let
  dotnet-8-9 =
    (with pkgs.dotnetCorePackages;
    combinePackages [
      sdk_8_0
      sdk_9_0
    ]);
  dotnet-9 = pkgs.dotnetCorePackages.sdk_9_0;
in
{
  environment.systemPackages = with pkgs; [
    dotnet-8-9
    pkgs.neovim
    pkgs.nodejs
    pkgs.roslyn-ls
    pkgs.lazygit
    pkgs.lazydocker
    pkgs.ripgrep
    pkgs.gdu
    pkgs.gcc
    pkgs.userPkgs.aider-chat
    pkgs.userPkgs.yazi
  ];

  programs.npm.enable = true;

  #environment.sessionVariables = {
    #DOTNET_ROOT = "${dotnet-8.outPath}/share/dotnet";
  #};
  # TODO: HM copy nvim config from git to ~/.config/nvim
}