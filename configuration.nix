# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }: # Added lib for potential future use

let
  # Import unstable packages channel
  pkgsUnstable = import <nixos-unstable> {
    # inherit the configuration from your main stable channel
    # ensures things like `allowUnfree` are respected if needed by the unstable package
    config = config.nixpkgs.config;
  };
in
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
      # Pass pkgsUnstable to modules that need it
      (import ./modules/packages.nix { inherit pkgsUnstable; })
      ./modules/desktop.nix
    ];

  # Pass pkgsUnstable down to modules that might need it implicitly
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
