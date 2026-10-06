{
  description = "NixOS configurations for hydenix, nixarchy and wsl";

  inputs = {
    # nixpkgs tracks upstream directly. It used to follow hydenix/nixpkgs, which
    # was only a Dec-2025 pin, not a fork — nothing needed it once the nixarchy
    # host stopped importing the hydenix module.
    #
    # The agent inputs (llm-agents, claude-code, the skill repos, ...) are NOT
    # declared here any more: the runtime resolves them from its own lock, by
    # absolute path, so a host cannot accidentally end up with a different pin
    # than the module it imports.
    #
    # The agent runtime (claude-code + opencode + pi + providers/keys + skills +
    # MCP) is its own flake, turbcool/agent-runtime, installable standalone in
    # containers via `nix profile install github:turbcool/agent-runtime`. A local
    # checkout keeps the dev loop short — but a git URL tracks committed history,
    # so commit there first, then `nix flake update agent-runtime` (no push
    # needed). Its own inputs follow ours, so nothing is fetched twice.
    agent-runtime = {
      url = "git+file:/home/turb/repos/agent-runtime";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
        # The one agent input a host still touches: lib/skills-install.nix builds
        # its per-project installers with agent-skills' lib.
        agent-skills.follows = "agent-skills";
      };
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nixarchy's NixOS module imports its own home-manager module. Two HM
    # versions in one configuration is a duplicated option set, so ours has to
    # be the same one.
    home-manager.follows = "nixarchy/home-manager";

    hydenix.url = "github:richen604/hydenix";

    # Omarchy 4.x vendored for NixOS. The `release` branch is a release branch,
    # not main: patch fixes arrive, nothing moves under you.
    nixarchy.url = "github:olafkfreund/nixarchy/release";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:nixos/nixos-hardware/master";

    agent-skills.url = "github:Kyure-A/agent-skills-nix";

    orca-skills = {
      url = "github:stablyai/orca";
      flake = false;
    };

    playwright-cli = {
      url = "github:microsoft/playwright-cli";
      flake = false;
    };

    helium = {
      url = "github:oxcl/nix-flake-helium-browser";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    orca-nix.url = "github:kevinpita/orca-nix";

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
        inputs.agent-runtime.nixosModules.default
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

        # No `inputs.hydenix.nixosModules.default` here, and never will be:
        # nixarchy sets programs.hyprland.package at plain priority (Omarchy *is*
        # Hyprland) and hydenix sets it at plain priority too, so importing both
        # is "conflicting definition values". hydenix/modules/system is still
        # reused below — it has no dependency on the hydenix module.
        nixarchy = {
          modules = commonModules ++ [
            inputs.home-manager.nixosModules.home-manager
            inputs.nixarchy.nixosModules.nixarchy
            inputs.nixos-hardware.nixosModules.common-cpu-intel
            inputs.nixos-hardware.nixosModules.common-pc-ssd
            ./nixarchy/configuration.nix
          ];
        };
      };

      mcp = inputs.agent-runtime.packages.${system}.mcp;
      skillsInstall = import ./lib/skills-install.nix { inherit pkgs inputs; };
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
            # Ships with the agent runtime: it renders that flake's MCP registry.
            mcp
          ];
        };

        opencode-playwright = playwright.devShell;
      };

      packages.${system} = prefixAttrs "skills-install-" skillsInstall.installs;
    };
}
