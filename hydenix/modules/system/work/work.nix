{ config, lib, pkgs, ... }:

let
  cfg = config.local.features.work;
in

{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      pkgs.remmina
      pkgs.onlyoffice-desktopeditors
      pkgs.sqlitebrowser
      pkgs.anydesk
    ];
  };
}
