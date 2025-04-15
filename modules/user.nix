# User accounts and user-specific settings
{ config, pkgs, ... }:

{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.turb = {
    isNormalUser = true;
    description = "turb";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

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

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
  };
}
