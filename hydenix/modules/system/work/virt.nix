# Virtualisation: VM, docker, waydroid
{ config, lib, ... }:

let
  cfg = config.local.features.work;
in

{
  config = lib.mkIf cfg.enable {
    virtualisation = {
      waydroid.enable = false;
    };

    hardware.nvidia-container-toolkit.enable = true;
  };
}
