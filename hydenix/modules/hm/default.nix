{ pkgs, ... }:

{
  imports = [
    ../../../common/hm/default.nix
    ./firefox.nix
    ./helium.nix
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
    # hydenix adds a plain `firefox` to home.packages; disable it so the
    # firefox.nix module can manage Firefox and pull in the ru language pack.
    # It lives here rather than in firefox.nix because that module is shared
    # with the nixarchy host, which has no hydenix options.
    firefox.enable = false;
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
