{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.local.pkgs.cli;
in
{
  options.local.pkgs.cli.enable = (lib.mkEnableOption "CLI utility packages") // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages =
      with pkgs;
      [
        ripgrep
        fd
        gdu
        yazi
        wget
        unzip
        vim
        lazygit
        lazydocker
        repomix
        sshpass
        gnumake
        openssl
      ]
      ++ [
        inputs.qmd.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
  };
}
