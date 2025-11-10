{ config, pkgs, ... }:

{
  services.mihomo = {
    enable = true;
    webui = pkgs.metacubexd;
    package = pkgs.mihomo;
    tunMode = true;
    configFile = ".config/mihomo/config.yaml";
  };
  environment.systemPackages = [ pkgs.mihomo ];
}
