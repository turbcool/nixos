{ lib, pkgs, ... }:

{
  home.file = {
    "repos/wolf/compose.yml" = lib.mkForce {
      source = ../config/wolf/compose.yml;
    };
  };
}
