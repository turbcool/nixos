{
  lib,
  ...
} :

{
  home.file = {
    ".ssh/config" = lib.mkForce {
      source = ./config/ssh-config.txt;
    };
  };
}
