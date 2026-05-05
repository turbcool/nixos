{ config, lib, pkgs, ... }:

let
  cfg = config.local.pkgs.database;
in
{
  options.local.pkgs.database.enable = (lib.mkEnableOption "database packages") // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      postgresql_17
    ];
  };
}
