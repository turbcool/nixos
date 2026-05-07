NixOS flake-based configuration with Home Manager, two hosts: `hydenix` (desktop) and `wsl`.

## Key commands

```bash
# Validate flake (fast, no build)
nix flake check --no-build

# Rebuild hosts (must be run from a git-tracked tree)
sudo nixos-rebuild switch --flake /etc/nixos#hydenix
sudo nixos-rebuild switch --flake /etc/nixos#wsl

# Format
nixfmt-rfc-style <file>   # RFC-style formatter (in devshell)

# Lint
statix check               # Nix linter (in devshell)

# Secrets (from common/secrets/)
common/secrets/setup-agenix.sh [--skip-existing]   # interactive secret provisioning
# Or manually: agenix -e <secret>.age  (run from common/secrets/ where secrets.nix lives)

# Devshell
direnv allow   # run once after entering /etc/nixos; provides nixfmt, nixd, statix, agenix, jq
```

## Architecture

- **`flake.nix`** — single entry point; `lib/mk-host.nix` builds hosts via `nixpkgs.lib.nixosSystem`, passes `inputs` as `specialArgs`
- **Two hosts** toggled by flake output attribute: `hydenix` (Hyde desktop), `wsl`
- **`common/`** — shared across both hosts:
  - `pkgs/` — system package lists (cli, dev, database, dotnet, networking, python)
  - `modules/` — system modules (cert, docker, git, llm, nix, profile, shell); `profile.nix` defines `local.profile` options (username, email, timezone, locale)
  - `hm/` — shared Home Manager modules (agent-skills, calendar, cli, direnv, neovim, opencode, ssh, tmux, zoxide)
  - `secrets/` — agenix secrets and `secrets.nix` (public key manifest)
- **`hydenix/`** — desktop-only:
  - `configuration.nix` — host identity, `local.features` toggles, Home Manager + hydenix HM wiring
  - `modules/system/` — `base/`, `browsers/`, `gaming/`, `work/`; gated by `local.features.*.enable`
  - `modules/hm/` — desktop HM modules (hyprland, remmina, vscode, wolf); imports `common/hm/` then adds desktop-only
  - `secrets/` — host-specific agenix secrets (paths referenced from `common/secrets/secrets.nix`)
- **`wsl/`** — `configuration.nix` only; imports `common/pkgs` + `common/modules`; HM imports `common/hm/` directly
- **`config/`** — opencode-related config: `skills.nix`, `mcp.nix`, `providers.nix` (LLM provider definitions with token files pointing to agenix secrets)
- **`lib/`** — `mk-host.nix`, `devShells/`, `scripts/cli.nix` (builds `skills` and `mcp` CLI wrappers)
- **`default.nix`** files in module directories import all child modules

## Conventions

- `default.nix` in every module directory aggregates child imports — follow this pattern when adding modules
- Feature toggles are NixOS options defined in `hydenix/modules/system/features.nix` and set in `hydenix/configuration.nix` under `local.features`
- Profile defaults live in `common/modules/profile.nix` (`local.profile` options); hosts override in their own `configuration.nix`
- Hydenix HM config files (hyprland, remmina, wolf) live alongside their `.nix` module as data directories
- `.age` secret paths in `common/secrets/secrets.nix` can reference files outside `common/secrets/` via relative paths (e.g., `../../hydenix/secrets/work-pc.age`)
- `inputs` is available in all NixOS and HM modules via `specialArgs`
- Flakes require a git-tracked tree — `git add` new files before rebuild

## Gotchas

- `home-manager.useGlobalPkgs = true` — HM uses system pkgs, don't add packages only in HM
- agenix `secrets.nix` must be in the directory where you run `agenix -e` (or paths won't resolve)
- `hydenix/hardware-configuration.nix` is auto-generated, not committed to the template
- The devshell uses `use flake` via `.envrc` — run `direnv allow` once; `.direnv/` is gitignored
