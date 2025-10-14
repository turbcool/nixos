# Network configuration
{ config, pkgs, ... }:

{
  networking.hostName = "nixos"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # L2TP
  networking.networkmanager.enableStrongSwan = true;
  services.xl2tpd.enable = true;
  services.strongswan = {
    enable = true;
  };

  # V2RayA Service
  services.v2raya.enable = true;
}
