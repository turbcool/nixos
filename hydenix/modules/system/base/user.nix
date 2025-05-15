{ config, pkgs, ... }:

{
  # Enable automatic login for the user.
  services.getty.autologinUser = "turb";

  environment.systemPackages = [
    pkgs.git
  ];

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
