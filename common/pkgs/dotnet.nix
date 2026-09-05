{ config, lib, pkgs, ... }:

let
  cfg = config.local.pkgs.dotnet;
  dotnet-sdk =
    (with pkgs.dotnetCorePackages;
    combinePackages [
      sdk_8_0
      sdk_10_0
    ]);
  dotnetRoot = "${dotnet-sdk}/share/dotnet";
in
{
  options.local.pkgs.dotnet.enable = (lib.mkEnableOption ".NET packages") // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      dotnet-sdk
      roslyn-ls
    ];

    environment.sessionVariables = {
      DOTNET_ROOT = dotnetRoot;
    };
  };
}
