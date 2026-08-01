{ ... }:

{
  virtualisation.docker.enable = true;

  systemd.tmpfiles.rules = [
    "d /tmp/.playwright-mcp 1777 root root -"
  ];
}
