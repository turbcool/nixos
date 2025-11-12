{ config, pkgs, ... }:

{
  services.mihomo = {
    enable = true;
    webui = pkgs.metacubexd;
    package = pkgs.mihomo;
    tunMode = true;
  };
  environment.systemPackages = [ pkgs.mihomo ];
}
