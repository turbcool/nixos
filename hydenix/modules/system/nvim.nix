{ config, pkgs, ... }:

let
  dotnet-full =
    (with pkgs.dotnetCorePackages;
    combinePackages [
      sdk_8_0
      aspnetcore_8_0
      sdk_9_0
      aspnetcore_9_0
    ]);
in
{
  environment.systemPackages = with pkgs; [
    dotnet-full
    pkgs.neovim
    pkgs.nodejs
    pkgs.roslyn-ls
    pkgs.lazygit
    pkgs.lazydocker
    pkgs.ripgrep
    pkgs.gdu
    pkgs.gcc
  ];
  environment.sessionVariables = {
    DOTNET_ROOT = "${dotnet-full.outPath}/share/dotnet";
  };
  # TODO: HM copy nvim config from git to ~/.config/nvim
}
