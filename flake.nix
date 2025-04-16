{
  description = "NixOS configuration flake";

  inputs = {
    # Nixpkgs stable branch
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05"; # Or your preferred stable branch

    # Nixpkgs unstable branch
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Add other inputs like home-manager if needed
    # home-manager.url = "github:nix-community/home-manager";
    # home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, ... }@inputs:
    let
      # Define the system architecture
      system = "x86_64-linux"; # Change this if your system uses a different architecture (e.g., aarch64-linux)

      # Create pkgs overlayed with unstable packages access
      # This makes pkgsUnstable available within the configuration modules via specialArgs
      pkgsUnstable = import inputs.nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true; # Or inherit from main config if needed
      };

      # Helper function to build NixOS configurations
      nixosSystem = args: nixpkgs.lib.nixosSystem (args // {
          # Pass unstable packages via specialArgs
          specialArgs = (args.specialArgs or {}) // { inherit pkgsUnstable; };
          # Add modules provided by inputs here if needed
          # modules = (args.modules or []) ++ [
          #   inputs.home-manager.nixosModules.home-manager
          #   {
          #     home-manager.useGlobalPkgs = true;
          #     home-manager.useUserPackages = true;
          #     # Pass flake inputs to home-manager modules
          #     home-manager.extraSpecialArgs = { inherit inputs; };
          #     # Import your home-manager configuration here
          #     # home-manager.users.your_username = import ./home.nix;
          #   }
          # ];
        });

    in {
      # Define your NixOS system configuration(s)
      nixosConfigurations = {
        # Hostname 'nixos' derived from modules/networking.nix
        nixos = nixosSystem {
          inherit system;
          modules = [
            # Import the main configuration file
            ./configuration.nix
            # You can add other modules directly here if needed
          ];
          # Pass any top-level specialArgs needed by configuration.nix or its modules
          # specialArgs = { }; # pkgsUnstable is already added by the helper
        };

        # You can define more host configurations here if needed
        # another-hostname = nixosSystem { ... };
      };

      # You might want to add other outputs like formatter, packages, etc. later
      # formatter.${system} = nixpkgs.legacyPackages.${system}.nixpkgs-fmt;
    };
}
