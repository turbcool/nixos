{ pkgs, ... }:

{
  home.packages = with pkgs; [
    yt-dlp
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
