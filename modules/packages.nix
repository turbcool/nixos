# Package definitions and program configurations
{ config, pkgs, pkgsUnstable, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
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
     pkgsUnstable.aider-chat # Using unstable package defined in configuration.nix

     networkmanagerapplet
     networkmanager-l2tp

     vscode

     xdg-desktop-portal-gtk # Dependency for portals, often needed by desktop apps

     yazi
     dolphin

     lazygit
     lazydocker
     lutris
     prismlauncher
  ];

  programs.steam.enable = true;

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
