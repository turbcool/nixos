# Hardware-specific settings
{ config, pkgs, ... }:

{
  hardware = {
    graphics.enable = true;
    nvidia.modesetting.enable = true;
  };
}
