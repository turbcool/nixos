{ 
  lib,
  pkgs,
  config,
  ...
}:

{
  imports = [
    ./steam.nix
  ];

  environment.systemPackages = with pkgs; [
    pkgs.lutris
    pkgs.prismlauncher
  ];
}
