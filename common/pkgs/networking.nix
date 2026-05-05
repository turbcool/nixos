{ config, lib, pkgs, ... }:

let
  cfg = config.local.pkgs.networking;
in
{
  options.local.pkgs.networking.enable = (lib.mkEnableOption "networking packages") // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      nmap
      dnsutils
    ];
  };
}
