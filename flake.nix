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

    agent-skills.url = "github:Kyure-A/agent-skills-nix";

    obsidian-wiki = {
      url = "github:Ar9av/obsidian-wiki";
      flake = false;
    };

    kepano-obsidian-skills = {
      url = "github:kepano/obsidian-skills";
      flake = false;
    };

    qmd.url = "github:tobi/qmd";

    claude-code.url = "github:sadjow/claude-code-nix";

    playwright-cli = {
      url = "github:microsoft/playwright-cli";
      flake = false;
    };

    paseo.url = "github:getpaseo/paseo";

    # VS Code "Dark Modern" yazi flavor (956MB/vscode-dark-modern.yazi).
    # Raw checkout (not a flake) — sourced as a path for the yazi flavors dir.
    vscode-yazi = {
      url = "github:956MB/vscode-dark-modern.yazi";
      flake = false;
    };
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
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
            inputs.paseo.nixosModules.paseo
            ./wsl/configuration.nix
          ];
        };
      };

      skills = import ./lib/devShells/skills.nix { inherit pkgs inputs; };
      mcp = import ./lib/devShells/mcp.nix { inherit pkgs; };
      cli = import ./lib/scripts/cli.nix { inherit pkgs; };
      playwright = import ./lib/devShells/playwright.nix { inherit pkgs inputs; };

      prefixAttrs =
        prefix: attrs:
        builtins.listToAttrs (
          builtins.attrValues (
            builtins.mapAttrs (name: value: {
              name = "${prefix}${name}";
              inherit value;
            }) attrs
          )
        );
    in
    {
      nixosConfigurations = nixpkgs.lib.mapAttrs (_: cfg: mkHost cfg) hosts;

      devShells.${system} = {
        default = pkgs.mkShellNoCC {
          packages = [
            inputs.agenix.packages.${system}.default
            pkgs.nixfmt-rfc-style
            pkgs.nixd
            pkgs.statix
            pkgs.jq
            cli.skills
            cli.mcp
          ];
        };

        skills = skills.devShell;
        mcp = mcp.devShell;
        opencode-playwright = playwright.devShell;
      }
      // (prefixAttrs "skills-" skills.shells)
      // (prefixAttrs "mcp-" mcp.shells);

      packages.${system} = prefixAttrs "mcp-config-" mcp.configs;
    };
}
