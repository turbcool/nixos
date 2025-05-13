# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

# Note: The { config, pkgs, lib, pkgsUnstable, ... } arguments are now implicitly passed by nixosSystem in flake.nix
{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix

      # Import modularized configuration files
      ./modules/core.nix
      ./modules/hardware.nix
      ./modules/networking.nix
      ./modules/user.nix
      ./modules/packages.nix # Include packages module normally
      ./modules/desktop.nix
    ];

  # Pass custom arguments like pkgsUnstable to modules
  # pkgsUnstable is now passed via specialArgs from the flake, making it available to modules.
  # The line below is removed as pkgsUnstable is not defined in this scope and specialArgs handles the injection.

  # Pass pkgsUnstable down to modules that might need it implicitly (handled by specialArgs now)
  # This makes pkgsUnstable available within the modules via the top-level args
  # Note: Explicitly passing via import like above (packages.nix) is often clearer.
  # Choose one method or be consistent. Let's keep the explicit pass for packages.nix
  # and remove this if not needed elsewhere. For now, it doesn't hurt.
  # nixpkgs.pkgs = pkgs // { inherit pkgsUnstable; }; # This might be too broad, let's stick to explicit passing


  # --- Remaining configuration sections (if any) ---
  # All major sections have been moved to modules.
  # You can add system-wide overrides or temporary settings here if needed.


  # --- System comments ---
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
}
