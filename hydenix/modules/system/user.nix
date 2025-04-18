# User accounts and user-specific settings
{ config, pkgs, ... }:

{
  # Enable automatic login for the user.
  services.getty.autologinUser = "turb";

  programs.git = {
     enable = true;
     config = {
       user = {
         email = "turbcool@gmail.com";
         name = "Ilya Naidanov";
       };
       push = { autoSetupRemote = true; };
     };
  };
}
