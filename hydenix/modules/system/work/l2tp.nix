{ config, pkgs, ... }:

{
  # L2TP VPN
  services.xl2tpd.enable = true;
  services.strongswan.enable = true;
  networking.networkmanager.enableStrongSwan = true;
  environment.systemPackages = with pkgs; [ pkgs.networkmanager-l2tp ];
  # to make it work do once: touch /etc/strongswan.conf
}
