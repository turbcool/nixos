{ lib, ... }:

{
  home.file = {
    "repos/wolf/compose.yml" = lib.mkForce {
      source = ./wolf/compose.yml;
    };
  };
}
