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
    # ripgrep, fd, unzip, lazygit, lazydocker, ffmpeg, gh and glab are nixarchy
    # base on the desktop; wsl declares its own copies.
    environment.systemPackages = with pkgs; [
      gdu
      wget
      vim
      repomix
      sshpass
      gnumake
      openssl
    ];
  };
}
