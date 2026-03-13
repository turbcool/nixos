{ config, pkgs, ... }:

{
  security.pki.certificateFiles = [
    ./cert/ca-ff.ru.crt
    ./cert/ca-skyori.ru.crt
    ./cert/ca-neoplatform.ru.crt
  ];
}
