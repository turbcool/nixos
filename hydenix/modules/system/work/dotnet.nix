{ config, pkgs, ... }:

let
  dotnet-sdk =
    (with pkgs.dotnetCorePackages;
    combinePackages [
      sdk_8_0
      sdk_9_0
      sdk_10_0
    ]);
  dotnetRoot = "${dotnet-sdk}/share/dotnet";
in
{
  environment.systemPackages = with pkgs; [
    dotnet-sdk
    pkgs.roslyn-ls
  ];

  environment.sessionVariables = {
    DOTNET_ROOT = dotnetRoot;
  };
}
