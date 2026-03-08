{
  description = "NixOS configurations for hydenix and wsl";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hydenix.url = "github:richen604/hydenix";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:nixos/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, nixos-wsl, home-manager, hydenix, agenix, nixos-hardware, ... }@inputs: {
    nixosConfigurations.hydenix = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./hydenix/configuration.nix
        agenix.nixosModules.age
      ];
    };

    nixosConfigurations.wsl = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        nixos-wsl.nixosModules.default
        home-manager.nixosModules.home-manager
        {
          system.stateVersion = "25.05";
          wsl.enable = true;
        }
        ./wsl/configuration.nix
      ];
    };
  };
}
