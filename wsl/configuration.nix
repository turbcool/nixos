{ config, lib, pkgs, ... }:

{
  imports = [
    ../common/pkgs/default.nix
    ../common/modules/git.nix
    ../common/modules/cert.nix
  ];

  wsl.enable = true;
  time.timeZone = "Asia/Yekaterinburg";
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
        ../common/hm/zoxide.nix
      ];
      home.stateVersion = "25.05";
      home.packages = with pkgs; [
        opencode
        zoxide
      ];
    };
  };

  system.stateVersion = "25.05";
}
