# User accounts and user-specific settings
{ config, pkgs, ... }:

{
  # Enable automatic login for the user.
  services.getty.autologinUser = "turb";

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
