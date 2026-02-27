{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    pkgs.zoom-us
    pkgs.remmina
    pkgs.onlyoffice-desktopeditors
    pkgs.sqlitebrowser
    pkgs.anydesk
  ];

  security.pki.certificateFiles = [
    ./cert/ca-ff.ru.crt
    ./cert/ca-skyori.ru.crt
    ./cert/ca-neoplatform.ru.crt
  ];
}
