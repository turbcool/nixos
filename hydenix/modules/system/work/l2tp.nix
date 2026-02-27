{ config, pkgs, ... }:

{
  # L2TP VPN
  services.xl2tpd.enable = true;
  services.strongswan.enable = true;
  networking.networkmanager.plugins = with pkgs; [ networkmanager-l2tp ];
  environment.etc."strongswan.conf".text = "";
  environment.systemPackages = with pkgs; [ pkgs.networkmanager-l2tp ];
}
