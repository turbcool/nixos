# Network configuration
{ config, pkgs, ... }:

{
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # L2TP
  networking.networkmanager.enableStrongSwan = true;
  services.xl2tpd.enable = true;
  services.strongswan.enable = true;
  # to make it work do once: touch /etc/strongswan.conf

  # VLESS
  services.v2raya = {
    enable = true;
    cliPackage = pkgs.xray;
  };
}
