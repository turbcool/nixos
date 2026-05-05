{ pkgs, ... }:

{
  imports = [
    ../../../common/hm/default.nix
    ./hyprland.nix
    ./remmina.nix
    ./vscode.nix
    ./wolf.nix
  ];

  home.packages = with pkgs; [
    telegram-desktop
  ];

  programs.mpv.enable = true;
  programs.qutebrowser.enable = true;

  hydenix.hm = {
    enable = true;
    spotify.enable = true;
    social.enable = false;
    shell.pokego.enable = false;

    theme = {
      active = "Ever Blushing";
      themes = [
        #"Another World"
        #"Cat Latte"
        #"Green Lush"
        #"Greenify"
        #"Monokai"
        "Abyssal-Wave"
        #"BlueSky"
        "Ever Blushing"
        #"Mac OS"
        "Monterey Frost"
        "Tundra"
        #"Cat Latte"
        "Catppuccin Mocha"
        #"Catppuccin Latte"
      ]; # default enabled themes, full list in https://github.com/richen604/hydenix/tree/main/hydenix/sources/themes
    };
    editors.vscode.enable = false;
    editors.vscode.wallbash = false;
    editors.neovim = false;
  };
}
