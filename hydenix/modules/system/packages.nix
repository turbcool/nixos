# Package definitions and program configurations
{ config, pkgs, ... }:

let
  tsSql = pkgs.tree-sitter.withPlugins (p: [ p.tree-sitter-sql ]);
in {
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
    pkgs.brave
    pkgs.telegram-desktop
    pkgs.userPkgs.aider-chat # Using unstable package defined in configuration.nix
    pkgs.userPkgs.yazi
    pkgs.yt-dlp

    # Games:
    pkgs.lutris
    pkgs.prismlauncher

    # Work:
    pkgs.zoom-us
    pkgs.remmina
    pkgs.networkmanager-l2tp
    (pkgs.harlequin.override {
      withBigQueryAdapter = false;
    })
    tsSql

    # Coding:
    pkgs.git
    pkgs.vscode
    pkgs.nodejs
    pkgs.dotnet-sdk_8
    pkgs.unzip
    pkgs.omnisharp-roslyn

    # Nvim:
    pkgs.lazygit
    pkgs.lazydocker
    pkgs.ripgrep
    pkgs.gdu
    pkgs.gcc
  ];

  programs.npm.enable = true;

  programs.partition-manager.enable = true;

  programs.steam.enable = true;
  programs.alvr.enable = true;
  programs.alvr.openFirewall = true;

  programs.chromium = {
    enable = true;
    extensions = [
    	"nngceckbapebfimnlniiiahkandclblb" # bitwarden
    	"dbepggeogbaibhgnhhndojpepiihcmeb" # vimium
	"fnaicdffflnofjppbagibeoednhnbjhg" # floccus
    ];
    extraOpts = {
      # Brave-specific
      "BraveRewardsDisabled" = 1;
      "BraveWalletDisabled" = 1;
      "BraveVPNDisabled" = 1;

      # Chrome-specific:
      "PasswordManagerEnabled" = false;
      "SpellcheckEnabled" = true;
      "SpellcheckLanguage" = [
        "ru-RU"
        "en-US"
      ];
    };
  };
}
