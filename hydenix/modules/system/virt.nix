# Virtualisation: VM, docker, waydroid
{ config, pkgs, ... }:

{
  #virtualisation.waydroid.enable = true;  
  virtualisation.docker.enable = true;
  users.users.turb.extraGroups = [ "docker" ];
}

