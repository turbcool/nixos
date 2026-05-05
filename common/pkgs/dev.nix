{ config, lib, pkgs, ... }:

let
  cfg = config.local.pkgs.dev;
in
{
  options.local.pkgs.dev.enable = (lib.mkEnableOption "development packages") // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      nodejs
      mcp-nixos
      gcc
      gitlab-ci-local
      uv
    ];

    programs.npm.enable = true;
  };
}
