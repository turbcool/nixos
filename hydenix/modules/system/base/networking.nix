# Network configuration
{ config, pkgs, ... }:

{
  networking.firewall = {
    allowedTCPPorts = [
      5173 5174 # development
      47984 47989 48010 # wolf
    ];

    allowedUDPPorts = [
      47999 48100 48200 # wolf
    ];
  };

  networking.interfaces.enp6s0.wakeOnLan.enable = true;
}
