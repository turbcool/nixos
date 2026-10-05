{
  description = "NixOS configurations for hydenix, nixarchy and wsl";

  inputs = {
    # nixpkgs tracks upstream directly. It used to follow hydenix/nixpkgs, which
    # was only a Dec-2025 pin, not a fork — nothing needed it once the nixarchy
    # host stopped importing the hydenix module.
    #
    # The agent-input block below (llm-agents, claude-code, ponytail, ...) is
    # kept only so agent-runtime can `follows` it — the host modules
    # themselves no longer reference any of them.
    llm-agents.url = "github:numtide/llm-agents.nix";

    # The agent runtime (claude-code + opencode + pi + providers/keys) lives in
    # a nested flake so the same definition can be installed standalone in the
    # agent-runtime containers via `github:richen604/hydenix/agent-runtime`.
    # Its own inputs are forced to follow ours so nothing is fetched twice.
    agent-runtime = {
      url = "path:./agent-runtime";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
        llm-agents.follows = "llm-agents";
        claude-code.follows = "claude-code";
        agent-skills.follows = "agent-skills";
        archify.follows = "archify";
        ponytail.follows = "ponytail";
        qmd.follows = "qmd";
        i-have-adhd.follows = "i-have-adhd";
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

    i-have-adhd = {
      url = "github:ayghri/i-have-adhd";
      flake = false;
    };

    archify = {
      url = "github:tt-a1i/archify";
      flake = false;
    };

    qmd.url = "github:tobi/qmd";

    claude-code.url = "github:sadjow/claude-code-nix";

    playwright-cli = {
      url = "github:microsoft/playwright-cli";
      flake = false;
    };

    ponytail = {
      url = "github:DietrichGebert/ponytail";
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

      mcp = import ./lib/devShells/mcp.nix { inherit pkgs; };
      skillsInstall = import ./lib/skills-install.nix { inherit pkgs inputs; };
      cli = import ./lib/scripts/cli.nix { inherit pkgs inputs; };
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

        opencode-playwright = playwright.devShell;
      };

      packages.${system} =
        (prefixAttrs "mcp-config-" mcp.configs) // (prefixAttrs "skills-install-" skillsInstall.installs);
    };
}
