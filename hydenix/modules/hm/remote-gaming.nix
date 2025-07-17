{ pkgs, ... }:

{
  networking.firewall = {
    allowedTCPPorts = [ 47984 47989 48010 ]; # wolf
    allowedUDPPorts = [ 47999 48100 48200 ]; # wolf
  };

  home.file = {
    "repos/wolf/compose.yml" = lib.mkForce {
      source = ../config/wolf/compose.yml;
    };
  };
}
