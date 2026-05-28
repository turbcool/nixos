{
  lib,
  ...
} :

{
  services.ssh-agent.enable = true;

  home.file = {
    ".ssh/config" = lib.mkForce {
      source = ./config/ssh-config.txt;
    };
  };
}
