{ inputs, pkgs, ... }:

{
  home.packages = [
    pkgs.yt-dlp
    inputs.claude-code.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  programs.zsh = {
    enable = true;
    history = {
      path = "$HOME/.histfile";
      size = 1000;
      save = 1000;
    };
    shellAliases = {
      build = "sudo nixos-rebuild switch --flake /etc/nixos#$(hostname)";
      opencode-playwright = "nix develop /etc/nixos#opencode-playwright";
    };
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  home.sessionPath = [
    "$HOME/.dotnet/tools"
  ];
}
