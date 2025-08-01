{ 
  lib,
  pkgs,
  config,
  ...
}:

{
  imports = [
    ./calendar.nix
    ./hyprland.nix
    ./neovim.nix
    ./vscode.nix
    ./wolf.nix
  ];

  # home-manager options go here
  home.packages = [
    # pkgs.vscode - hydenix's vscode version
    # pkgs.userPkgs.vscode - your personal nixpkgs version
  ];

  programs.mpv.enable = true;

  home.file = {
    ".ssh/config" = lib.mkForce {
      source = ../config/ssh-config.txt;
    };
    ".local/share/remmina/work-pc.remmina" = lib.mkForce {
      source = ../config/remmina/work-pc.remmina;
      force = true;
    };
    ".local/share/remmina/autocam.remmina" = lib.mkForce {
      source = ../config/remmina/autocam.remmina;
      force = true;
    };
    "/build.sh" = lib.mkForce {
      source = ../config/build.sh;
      force = true;
    };
    ".config/nvim" = {
      source = pkgs.fetchFromGitHub {
        owner = "turbcool";
        repo = "nvim";
        rev = "64164a15cd6bcdaa83a17f0ea6169c6daa1686ea";
        hash = "sha256-kYb3zgsWY7xQ3u1UsbpwCd9XW34Q23iRAThUBjVtyaA=";
      };
    };
  };

  # hydenix home-manager options go here
  hydenix.hm = {
    #! Important options
    enable = true;
    spotify.enable = true;
    social.enable = false;
    shell.pokego.enable = false;

    git = {
      name = "Ilya Naidanov";
      email = "turbcool@gmail.com";
    };

    theme = {
      active = "Catppuccin Mocha";
      themes = [
        #"Another World"
        #"Cat Latte"
        #"Green Lush"
        #"Greenify"
        #"Monokai"
        "Abyssal-Wave"
        "BlueSky"
        "Ever Blushing"
        "Mac OS"
        "Monterey Frost"
        "Tundra"
        "Cat Latte"
        "Catppuccin Mocha"
        "Catppuccin Latte"
      ]; # default enabled themes, full list in https://github.com/richen604/hydenix/tree/main/hydenix/sources/themes
    };
    editors.vscode.enable = false;
    editors.vscode.wallbash = false;
    editors.neovim = false;
    /*
      ! Below are defaults

      comma.enable = true; # useful nix tool to run software without installing it first
      dolphin.enable = true; # file manager
      editors = {
        enable = true; # enable editors module
        neovim.enable = true; # enable neovim module
        vscode = {
          enable = true; # enable vscode module
          wallbash = true; # enable wallbash extension for vscode
        };
        vim.enable = true; # enable vim module
        default = "vim"; # default text editor
      };
      fastfetch.enable = true; # fastfetch configuration
      firefox = {
        enable = true; # enable firefox module
        useHydeConfig = false; # use hyde firefox configuration and extensions
        useUserChrome = true; # if useHydeConfig is true, apply hyde userChrome CSS customizations
        useUserJs = true; # if useHydeConfig is true, apply hyde user.js preferences
        useExtensions = true; # if useHydeConfig is true, install hyde firefox extensions
      };
      git = {
        enable = true; # enable git module
        name = null; # git user name eg "John Doe"
        email = null; # git user email eg "john.doe@example.com"
      };
      hyde.enable = true; # enable hyde module
      hyprland.enable = true; # enable hyprland module
      hyprland.extraConfig = ''
      '';
      lockscreen = {
        enable = true; # enable lockscreen module
        hyprlock = true; # enable hyprlock lockscreen
        swaylock = false; # enable swaylock lockscreen
      };
      notifications.enable = true; # enable notifications module
      qt.enable = true; # enable qt module
      rofi.enable = true; # enable rofi module
      screenshots = {
        enable = true; # enable screenshots module
        grim.enable = true; # enable grim screenshot tool
        slurp.enable = true; # enable slurp region selection tool
        satty.enable = true; # enable satty screenshot annotation tool
        swappy.enable = false; # enable swappy screenshot editor
      };
      shell = {
        enable = true; # enable shell module
        zsh.enable = true; # enable zsh shell
        zsh.configText = ""; # zsh config text
        bash.enable = false; # enable bash shell
        fish.enable = false; # enable fish shell
        pokego.enable = true; # enable Pokemon ASCII art scripts
      };
      social = {
        enable = true; # enable social module
        discord.enable = true; # enable discord module
        webcord.enable = true; # enable webcord module
        vesktop.enable = true; # enable vesktop module
      };
      spotify.enable = true; # enable spotify module
      swww.enable = true; # enable swww wallpaper daemon
      terminals = {
        enable = true; # enable terminals module
        kitty = {
          enable = true; # enable kitty terminal
          configText = ""; # kitty config text
        };
      };
      theme = {
        enable = true; # enable theme module
        active = "Catppuccin Mocha"; # active theme name
        themes = [
          "Catppuccin Mocha"
          "Catppuccin Latte"
        ]; # default enabled themes, full list in https://github.com/richen604/hydenix/tree/main/hydenix/sources/themes
      };
      waybar.enable = true; # enable waybar module
      wlogout.enable = true; # enable wlogout module
      xdg.enable = true; # enable xdg module
    */
  };
}
