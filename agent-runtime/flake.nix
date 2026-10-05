{
  description = "Declarative agent runtime: claude-code + opencode + pi with providers, keys and MCP wiring. Usable as a NixOS/Home Manager module pair or as a standalone `nix profile install` bundle for containers.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # pi, opencode, agent-deck.
    llm-agents.url = "github:numtide/llm-agents.nix";

    # The claude binary itself — npm-published, so it needs this to be
    # reproducible (and to reach a binary cache).
    claude-code.url = "github:sadjow/claude-code-nix";

    # opencode plugins referenced by absolute store path in opencode.json.
    ponytail = {
      url = "github:DietrichGebert/ponytail";
      flake = false;
    };
    i-have-adhd = {
      url = "github:ayghri/i-have-adhd";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      # Keep in sync with /etc/nixos/flake.nix; the hosts pin x86_64-linux.
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      lib = nixpkgs.lib;

      # Standalone Home Manager: the exact module the NixOS hosts get through
      # common/hm/default.nix, evaluated with no OS underneath. That is what
      # makes the container config identical to the desktop config.
      hmConfig = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit inputs; };
        modules = [
          ./modules/home.nix
          ./modules/container.nix
        ];
      };

      # Everything modules/home.nix + modules/wrappers.nix contribute, i.e. pi,
      # opencode, claude, claude-free, writing. Deliberately NOT
      # hmConfig.config.home.packages: standalone Home Manager folds its own
      # baseline (man-db, shared-mime-info, the reference manpage) into that
      # list, which has no business in a container bundle.
      agentRuntime = pkgs.buildEnv {
        name = "agent-runtime";
        paths = hmConfig.config.agent.runtimePackages;
        pathsToLink = [
          "/bin"
        ];
        # home.packages has no collisions today (the real claude binary is
        # reached through the wrapper's absolute store path, not via PATH), but
        # don't fail the build if a future agent ships one anyway.
        ignoreCollisions = true;
      };

      # The rendered ~/.pi and ~/.config/opencode trees as store paths, so a
      # container image can COPY them straight into $HOME.
      agentRuntimeConfig = pkgs.linkFarm "agent-runtime-config" (
        lib.mapAttrsToList (name: src: {
          inherit name;
          path = toString src;
        }) hmConfig.config.agent.runtimeFiles
      );

      # One-shot installer: `nix profile install ...#agent-runtime-install` then
      # `agent-runtime-install` to lay the config down in the current $HOME.
      agentRuntimeInstall = pkgs.writeShellScriptBin "agent-runtime-install" ''
        set -euo pipefail
        target="''${1:-$HOME}"
        mkdir -p "$target"
        cp -rL ${agentRuntimeConfig}/. "$target/"
        echo "✓ agent config installed into $target"
        echo "  providers: $(ls -1 ${agentRuntimeConfig}/.pi/agent >/dev/null 2>&1 && echo ok)"
        echo "  export the AGENT_*_TOKEN env vars (see data/providers.nix) before running the agents"
      '';
    in
    {
      nixosModules.default = ./modules/nixos.nix;
      homeModules.default = ./modules/home.nix;
      homeModules.container = ./modules/container.nix;

      homeConfigurations = {
        agent-runtime = hmConfig;
        default = hmConfig;
      };

      packages.${system} = {
        inherit agentRuntime agentRuntimeConfig agentRuntimeInstall;
        agent-runtime = agentRuntime;
        agent-runtime-config = agentRuntimeConfig;
        agent-runtime-install = agentRuntimeInstall;
        default = agentRuntime;
      };

      # Checks: every provider resolves to a token, and the bundle actually
      # contains the agents we promise.
      checks.${system} = {
        providers-well-formed =
          let
            bad = lib.filterAttrs (_: p: !(p ? tokenSource && (p.tokenSource ? env || p.tokenSource ? file))) (
              import ./data/providers.nix
            );
          in
          assert bad == { };
          pkgs.runCommand "providers-well-formed" { } ''
            echo "providers ok"
            touch $out
          '';

        bundle-contains-agents =
          pkgs.runCommand "bundle-contains-agents"
            {
              nativeBuildInputs = [ pkgs.coreutils ];
            }
            ''
              for bin in claude claude-free writing opencode pi; do
                if [ ! -x "${agentRuntime}/bin/$bin" ]; then
                  echo "missing from bundle: $bin" >&2
                  exit 1
                fi
              done
              touch $out
            '';
      };

      devShells.${system}.default = pkgs.mkShellNoCC {
        packages = [
          pkgs.jq
          pkgs.nixfmt-rfc-style
          pkgs.statix
        ];
      };

      formatter = pkgs.nixfmt-rfc-style;
    };
}
