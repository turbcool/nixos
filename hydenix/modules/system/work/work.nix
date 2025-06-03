{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Work-specific applications
    pkgs.zoom-us
    pkgs.remmina
    pkgs.onlyoffice-bin
    pkgs.sqlitebrowser
  ];
}