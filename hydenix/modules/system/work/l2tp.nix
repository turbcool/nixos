{ config, lib, pkgs, ... }:

let
  cfg = config.local.features.work;
in

{
  config = lib.mkIf cfg.enable {
    # L2TP VPN
    services.xl2tpd.enable = true;
    services.strongswan.enable = true;
    networking.networkmanager.plugins = with pkgs; [ networkmanager-l2tp ];
    environment.etc."strongswan.conf".text = "";
    environment.etc."NetworkManager/system-connections/work-vpn.nmconnection" = {
      source = ./vpn/work.conf;
      mode = "0600";
      user = "root";
      group = "root";
    };
    environment.systemPackages = with pkgs; [ pkgs.networkmanager-l2tp ];

    systemd.services.NetworkManager.restartTriggers = [ ./vpn/work.conf ];

    services.v2raya = {
      enable = true;
      cliPackage = pkgs.xray;
    };
  };
}
