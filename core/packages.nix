# Package definitions and program configurations
{ config, pkgs, pkgsUnstable, ... }:

{
  environment.systemPackages = with pkgs; [
     wget
     remmina

     # Hyprland dependencies/tools (kept here for clarity, could move to desktop.nix)
     dunst
     libnotify

     #wallpaper
     swww

     #terminal
     kitty

     rofi-wayland

     brave
     git
     telegram-desktop

     networkmanagerapplet
     networkmanager-l2tp

     vscode

     xdg-desktop-portal-gtk # Dependency for portals, often needed by desktop apps

     pkgsUnstable.yazi

     lazygit
     lazydocker
  ];

  programs.thunar.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.chromium = {
    enable = true;
    extensions = [
	    "nngceckbapebfimnlniiiahkandclblb" # bitwarden
    ];
    extraOpts = {
      "PasswordManagerEnabled" = false;
      "SyncDisabled" = true;
      "SpellcheckEnabled" = true;
      "SpellcheckLanguage" = [
        "ru-RU"
        "en-US"
      ];
    };
  };
}
