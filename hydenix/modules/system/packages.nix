# Package definitions and program configurations
{ config, pkgs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
     pkgs.remmina
     pkgs.brave
     pkgs.git
     pkgs.telegram-desktop
     pkgs.userPkgs.aider-chat # Using unstable package defined in configuration.nix
     pkgs.networkmanager-l2tp
     pkgs.vscode
     pkgs.userPkgs.yazi
     pkgs.lazygit
     pkgs.lazydocker
     pkgs.lutris
     pkgs.prismlauncher
  ];

  programs.steam.enable = true;
  programs.alvr.enable = true;
  programs.alvr.openFirewall = true;

  programs.chromium = {
    enable = true;
    extensions = [
    	"nngceckbapebfimnlniiiahkandclblb" # bitwarden
    ];
    extraOpts = {
      #"PasswordManagerEnabled" = false;
      "SyncDisabled" = true;
      "SpellcheckEnabled" = true;
      "SpellcheckLanguage" = [
        "ru-RU"
        "en-US"
      ];
    };
  };
}
