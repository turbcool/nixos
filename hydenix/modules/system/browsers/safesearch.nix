{ config, lib, ... }:

let
  cfg = config.local.features.browsers;
in

{
  config = lib.mkIf cfg.enable {
    networking.hosts = {
      "213.180.193.56" = [
        "ya.ru"
        "yandex.ru"
      ];
    };
  };
}
