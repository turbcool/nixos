# Virtualisation: VM, docker, waydroid
{ config, pkgs, ... }:

{
  virtualisation = {
    waydroid.enable = false;  
    docker.enable = true;
  };
  #hardware.nvidia-container-toolkit.enable = true;
}

