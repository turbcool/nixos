{ config, pkgs, ... }:

{
  # Enable CUPS printing service
  services.printing = {
    enable = true;
    drivers = [ pkgs.epson-escpr ];  # Epson ESC/P-R driver for L3251
  };

  # Enable Avahi for automatic printer discovery over the network
  services.avahi = {
    enable = true;
    nssmdns4 = true;  # For hostname resolution
    openFirewall = true;  # Allow necessary ports
  };
}
