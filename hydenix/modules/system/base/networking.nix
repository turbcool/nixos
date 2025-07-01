# Network configuration
{ config, pkgs, ... }:

{
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  networking.firewall = {
    allowedTCPPorts = [
      5173 5174 # development
      47984 47989 48010 # wolf
    ];

    allowedUDPPorts = [
      47999 48100 48200 # wolf
    ];
  };
  # L2TP
  services.xl2tpd.enable = true;
  services.strongswan.enable = true;
  networking.networkmanager.enableStrongSwan = true;
  environment.systemPackages = with pkgs; [ pkgs.networkmanager-l2tp ];
  # to make it work do once: touch /etc/strongswan.conf

  # VLESS
  services.v2raya = {
    enable = true;
    cliPackage = pkgs.xray;
  };
}
