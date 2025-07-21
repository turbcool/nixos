{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    config = {
      user = {
        name = "Ilya Naidanov";
        email = "turbcool@gmail.com";
      };
      push = { autoSetupRemote = true; };
    };
  };
}
