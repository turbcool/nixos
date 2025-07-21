{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    pkgs.zoom-us
    pkgs.remmina
    pkgs.onlyoffice-bin
    pkgs.sqlitebrowser
  ];
}
