{ config, pkgs, inputs, ... }:

{
  programs.alvr.enable = true;
  programs.alvr.openFirewall = true;
}
