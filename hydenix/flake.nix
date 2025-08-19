{
  description = "template for hydenix";

  inputs = {
    # User's nixpkgs - for user packages
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Hydenix and its nixpkgs - kept separate to avoid conflicts
    hydenix = {
      # Available inputs:
      # Main: github:richen604/hydenix
      # Dev: github:richen604/hydenix/dev
      # Commit: github:richen604/hydenix/<commit-hash>
      # Version: github:richen604/hydenix/v1.0.0
      url = "github:richen604/hydenix";
    };

    # Nix-index-database - for comma and command-not-found
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    anime.url = "github:ezKEa/aagl-gtk-on-nix";
    anime.inputs.nixpkgs.follows = "nixpkgs";
    nix-ai-tools.url = "github:numtide/nix-ai-tools";
  };

  outputs =
    { ... }@inputs:
    let
      HOSTNAME = "nixos";
      system = "x86_64-linux"; # Match the main flake.nix system

      hydenixConfig = inputs.hydenix.inputs.hydenix-nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ./configuration.nix
        ];
      };

    in
    {
#      nixosConfigurations.nixos = hydenixConfig;
      nixosConfigurations.${HOSTNAME} = hydenixConfig;
    };
}
