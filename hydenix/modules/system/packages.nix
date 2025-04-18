# Package definitions and program configurations
{ config, pkgs, pkgsUnstable, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
     remmina
     brave
     git
     telegram-desktop
     pkgsUnstable.aider-chat # Using unstable package defined in configuration.nix
     networkmanager-l2tp
     vscode
     pkgsUnstable.yazi
     lazygit
     lazydocker
     lutris
     prismlauncher
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
