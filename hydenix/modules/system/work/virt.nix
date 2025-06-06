# Virtualisation: VM, docker, waydroid
{ config, pkgs, ... }:

{
  #virtualisation.waydroid.enable = true;  
  virtualisation.docker.enable = true;
  hardware.nvidia-container-toolkit.enable = true;
}

