{ 
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.local.features.gaming;
in

{
  imports = [
    ./steam.nix
    ./vr.nix
  ];

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      pkgs.lutris
      pkgs.prismlauncher
    ];
  };
}
