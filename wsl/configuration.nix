{ config, lib, pkgs, ... }:

{
  imports = [
    ../common/pkgs/default.nix
    ../common/modules/git.nix
  ];

  wsl.enable = true;
  programs.zsh.enable = true;
  wsl.defaultUser = "turb";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
  ];

  users.users.turb = {
    isNormalUser = true;
    initialPassword = "1";
    extraGroups = [ "wheel" "docker" ];
    shell = pkgs.zsh;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.turb = { ... }: {
      imports = [
        ../common/hm/neovim.nix
        ../common/hm/calendar.nix
      ];
      home.stateVersion = "25.05";
      home.packages = with pkgs; [
        opencode
      ];
    };
  };

  system.stateVersion = "25.05";
}
