

{ config, pkgs, inputs, ... }:

{
  networking.hosts = {
    "213.180.193.56" = [
      "ya.ru"
      "yandex.ru"
    ];
  };
}

