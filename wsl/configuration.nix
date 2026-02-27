{ config, lib, pkgs, ... }:

{
  imports = [
    <nixos-wsl/modules>
    ./common/pkgs/default.nix
    ./common/modules/git.nix
  ];

  wsl.enable = true;
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
      home.packages = with pkgs; [
        neovim
        opencode
      ];
    };
  };

  system.stateVersion = "25.05";
}
