{ config, lib, pkgs, ... }:

let
  profile = config.local.profile;
  username = profile.username;
in

{
  imports = [
    ../common/pkgs/default.nix
    ../common/modules/default.nix
  ];

  local.profile = {
    username = "turb";
    fullName = "Ilya Naidanov";
    email = "turbcool@gmail.com";
    timezone = "Asia/Yekaterinburg";
    locale = "ru_RU.UTF-8";
  };

  wsl = {
    enable = true;
    useWindowsDriver = true;
    defaultUser = username;
    docker-desktop.enable = true;
  };

  time.timeZone = profile.timezone;
  programs.zsh.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
  ];

  users.users.${username} = {
    isNormalUser = true;
    initialPassword = "1";
    extraGroups = [ "wheel" "docker" ];
    shell = pkgs.zsh;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${username} = { ... }: {
      imports = [
        ../common/hm/default.nix
      ];
      home.stateVersion = "25.05";
    };
  };

  system.stateVersion = "25.05";
}
