{
  lib,
  ...
} :

{
  home.file = {
    ".ssh/config" = lib.mkForce {
      source = ./ssh-config.txt;
    };
  };
}
