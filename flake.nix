{
  description = "NixOS configurations for hydenix and wsl";

  inputs = {
    nixpkgs.follows = "hydenix/nixpkgs";
    llm-agents.url = "github:numtide/llm-agents.nix";

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      follows = "hydenix/home-manager";
    };

    hydenix.url = "github:richen604/hydenix";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:nixos/nixos-hardware/master";
  };

  outputs = { nixpkgs, ... }@inputs:
    let
      mkHost = import ./lib/mk-host.nix { inherit inputs nixpkgs; };

      commonModules = [
        inputs.agenix.nixosModules.default
      ];

      hosts = {
        hydenix = {
          modules = commonModules ++ [
            inputs.home-manager.nixosModules.home-manager
            inputs.hydenix.nixosModules.default
            ./hydenix/configuration.nix
          ];
        };

        wsl = {
          modules = commonModules ++ [
            inputs.nixos-wsl.nixosModules.default
            inputs.home-manager.nixosModules.home-manager
            ./wsl/configuration.nix
          ];
        };
      };
    in
    {
      nixosConfigurations = nixpkgs.lib.mapAttrs (_: cfg: mkHost cfg) hosts;
    };
}
