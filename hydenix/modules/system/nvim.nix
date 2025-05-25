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
  dotnet-8 = pkgs.dotnetCorePackages.sdk_8_0;
in
{
  environment.systemPackages = with pkgs; [
    dotnet-8
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
    DOTNET_ROOT = "${dotnet-8.outPath}/share/dotnet";
  };
  # TODO: HM copy nvim config from git to ~/.config/nvim
}
