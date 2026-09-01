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

# MCP tools (bladebro + donsetch) — installed per-user via npm into `$HOME/.npm/`
# (NixOS-wiki home approach; prefix set by programs.npm in common/pkgs/dev.nix).
# `programs.nix-ld` (common/modules/nix-ld.nix) is required: both ship prebuilt
# glibc binaries that the NixOS stub loader would otherwise reject.
npm i -g bladebro donsetch        # install/update; binaries land in $HOME/.npm/bin
donsetch doctor                   # health check (also prints MCP registration)

# Claude Code MCP — claudeCode servers in config/mcp.nix are delivered at runtime by the
# `claude` wrapper via --mcp-config, but that does NOT make them appear in `claude mcp list`.
# Register them in the user scope once per host for visibility + health checks:
claude mcp add -s user -- bladebro mcp
claude mcp add -s user -- donsetch mcp
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

## Feature toggles

- `local.features.browsers.enable`, `local.features.gaming.enable`, `local.features.work.enable` — desktop-only, defined in `hydenix/modules/system/features.nix`

## Services

- No containerized services remain. MCP web tools (donsetch = fetch/search/crawl, bladebro = stealth browser) are npm-installed per-user (`$HOME/.npm`) and run as native glibc binaries under `programs.nix-ld`; see `common/pkgs/dev.nix` (npm prefix) + `common/modules/nix-ld.nix`. CA trust for internal hosts (skyori, neoplatform, ff.ru, SRVHADCS) comes from `common/modules/cert.nix`, which bladebro inherits since it drives the host's Chromium.

## Helium extension bumps (Bitwarden/Passbolt)

When a rebuild fails on a CRX hash in `hydenix/modules/hm/helium.nix` (store version bumped):

1. Get new hash + version for the extension:
   ```bash
   curl -sL -o /tmp/e.crx "https://clients2.google.com/service/update2/crx?response=redirect&prodversion=127.0.0.0&acceptformat=crx3&x=id%3D<ID>%26installsource%3Dondemand%26uc"
   nix hash convert --hash-algo sha256 --to sri $(nix hash path /tmp/e.crx)
   unzip -p /tmp/e.crx manifest.json | jq -r .version
   ```
2. Update `version` + `sha256` for that extension in `hydenix/modules/hm/helium.nix`.
3. `git add` then `nixos-rebuild switch --flake /etc/nixos#hydenix`.

Extension IDs: Bitwarden `nngceckbapebfimnlniiiahkandclblb`, Passbolt `didegimhafipceonhjepacocaffmoppf`. uBlock is bundled as a Helium component — never bump it. Do NOT use `ExtensionInstallForcelist` (broken: Helium sends `prod=chromecrx`, CWS replies `noupdate`).

## Conventions

- `default.nix` in every module directory aggregates child imports — follow this pattern when adding modules
- Feature toggles for desktop-only modules live in `hydenix/modules/system/features.nix`; common toggles go in a module under `common/modules/`
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
- bladebro/donsetch are not packages — they're npm-installed into `$HOME/.npm` and need `programs.nix-ld` enabled (the NixOS stub loader rejects their prebuilt glibc binaries otherwise). Run `npm i -g bladebro donsetch` after a fresh install.

P.S. When user asks to install a NixOS package, use MCP Tool `nixos` to search and validate configuration options.
