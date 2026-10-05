NixOS flake-based configuration with Home Manager, three hosts: `hydenix` (Hydenix desktop),
`nixarchy` (Omarchy/nixarchy desktop) and `wsl`. The intent is to switch from hydenix to
nixarchy entirely, so keep hydenix working until then.

## Key commands

```bash
# Validate flake (fast, no build)
nix flake check --no-build

# Rebuild hosts (must be run from a git-tracked tree)
sudo nixos-rebuild switch --flake /etc/nixos#hydenix
sudo nixos-rebuild switch --flake /etc/nixos#nixarchy
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
claude mcp add -s user bladebro -- ~/.npm/bin/bladebro mcp
claude mcp add -s user donsetch -- ~/.npm/bin/donsetch mcp
```

## Architecture

- **`flake.nix`** — single entry point; `lib/mk-host.nix` builds hosts via `nixpkgs.lib.nixosSystem`, passes `inputs` as `specialArgs`
- **`agent-runtime/`** — **nested flake** holding all LLM/agent logic (claude-code + opencode + pi + providers/keys + MCP + bundled skills). Consumed by the hosts as `path:./agent-runtime` (its inputs `follow` the host's), and installable standalone in containers as `github:turbcool/nixos/agent-runtime`. See "Agent runtime" below.
- **Three hosts** toggled by flake output attribute: `hydenix` (Hyde desktop), `nixarchy` (Omarchy desktop), `wsl`
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
- **`nixarchy/`** — second desktop, Omarchy 4.x vendored by the `nixarchy` input:
  - `configuration.nix` — host identity, `local.features` toggles, `programs.nixarchy.*`, HM wiring
  - `modules/hm/` — thin layer importing `common/hm/` plus the reusable `hydenix/modules/hm/*` modules
  - No `modules/system/` of its own: it imports `hydenix/modules/system/` directly, which has no
    dependency on the hydenix module
  - Reuses `hydenix/hardware-configuration.nix` (same physical machine)
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

## Agent runtime (`agent-runtime/`)

Everything about the coding agents lives in this nested flake, not in `common/`.

- **`data/`** — pure data, no OS: `providers.nix` (endpoints, models, token sources), `mcp.nix`, `plugins.nix`, `skills.nix`, `pi-starship.toml`.
- **`modules/home.nix`** — OS-agnostic Home Manager module: pi config, opencode.json, binaries, and all `agent.*` options. Works both under NixOS+HM and under the standalone `homeConfigurations.agent-runtime` (plain HM, no OS).
- **`modules/nixos.nix`** — agenix secrets, `/etc/claude-code/managed-settings.json`, `ANTHROPIC_BASE_URL`. Rewrites each provider's `tokenSource` into the decrypted secret's store path (`agent.resolvedProviders`).
- **`modules/wrappers.nix`** — `claude`, `claude-free`, `writing` (per-provider wrappers).
- **`modules/skills.nix`** — the bundled skills (`data/skills.nix`). **The only** place that imports `agent-skills`' HM module: it is a Nix function, not a path, so a second import makes every `programs.agent-skills.*` option collide. Host modules may extend `programs.agent-skills.sources` but must never re-import it.
- **`modules/container.nix`** — home dir + headless tweaks for the standalone config only.
- **`common/hm/agent-bridge.nix`** (3 lines) — the only NixOS↔HM glue: `agent.providers = osConfig.agent.resolvedProviders`.
- **`common/hm/agent-skills.nix`** — adds the host-only skills (`config/skills.nix`) to `programs.agent-skills.sources`. Both modules merge into one source set → one catalog → one bundle → one sync.

### Tokens

`data/providers.nix` declares `tokenSource = { env = "AGENT_FREE_TOKEN"; }`. One field, two resolvers:

| | NixOS host | Container |
|---|---|---|
| source | `{ file = /run/agenix/<name>-token; }` (rewritten by `nixos.nix`) | `{ env = "AGENT_*_TOKEN"; }` (as declared) |
| opencode | `{file:…}` | `{env:…}` |
| pi | `!cat …` | `!printenv …` |
| shell wrappers | `$(cat …)` | `"$AGENT_*_TOKEN"` |

Keys never enter the store or a config file in the store. Export `AGENT_NEOPLATFORM_TOKEN`, `AGENT_CUSTOM_TOKEN`, `AGENT_FREE_TOKEN` in containers.

### Skills

Two registries that merge into one catalog:

| | file | skills |
|---|---|---|
| **runtime** (hosts + containers) | `agent-runtime/data/skills.nix` | `archify`, `archify-review`, `i-have-adhd`, `qmd`, `ponytail` + 5 `ponytail-*` = **10** |
| **host only** | `config/skills.nix` | `orca` + 7 `orca-*` = **8** |

Targets: `.agents/skills` (cross-vendor), `.claude/skills`, `.config/opencode/skills`. `pi` is still not a target — it has no dir wired up. Per-project installs via the `skills <group>` CLI stay host-side and cover `config/skills.nix` only.

**`input` names resolve against the *consuming* flake's inputs.** Anything in `agent-runtime/data/skills.nix` must therefore also be declared in `/etc/nixos/flake.nix` and wired with `inputs.agent-runtime.inputs.<name>.follows`.

### Container usage

```bash
nix profile install github:turbcool/nixos/agent-runtime#agent-runtime             # pi, opencode, claude, claude-free, writing
nix profile install github:turbcool/nixos/agent-runtime#agent-runtime-install       # one-shot: lay ~/.pi, ~/.config/opencode + skills into $HOME
nix build github:turbcool/nixos/agent-runtime#agent-runtime-config                 # rendered config + skill trees, for COPY in a Dockerfile
nix develop github:turbcool/nixos/agent-runtime                                   # ad-hoc shell
```

Known container gaps: `bladebro`/`donsetch` stay a runtime `npm i -g` (need manual `nix-ld` setup outside NixOS), and pi npm-installs its declared packages on first startup, so an air-gapped container needs them pre-seeded.

## Conventions

- `default.nix` in every module directory aggregates child imports — follow this pattern when adding modules
- Feature toggles for desktop-only modules live in `hydenix/modules/system/features.nix`; common toggles go in a module under `common/modules/`
- Profile defaults live in `common/modules/profile.nix` (`local.profile` options); hosts override in their own `configuration.nix`
- Hydenix HM config files (hyprland, remmina, wolf) live alongside their `.nix` module as data directories
- LLM/agent changes go in `agent-runtime/`, never in `common/` — including its own `flake.lock`
- `.age` secret paths in `common/secrets/secrets.nix` can reference files outside `common/secrets/` via relative paths (e.g., `../../hydenix/secrets/work-pc.age`); `agent-runtime/data/providers.nix` references them as `../../common/secrets/<name>-token.age` and is the only file in that flake reaching outside it
- `inputs` is available in all NixOS and HM modules via `specialArgs`
- Flakes require a git-tracked tree — `git add` new files before rebuild

## Gotchas

- `home-manager.useGlobalPkgs = true` — HM uses system pkgs, don't add packages only in HM
- agenix `secrets.nix` must be in the directory where you run `agenix -e` (or paths won't resolve)
- `hydenix/hardware-configuration.nix` is auto-generated, not committed to the template
- The devshell uses `use flake` via `.envrc` — run `direnv allow` once; `.direnv/` is gitignored
- **The nixarchy host must never import `inputs.hydenix.nixosModules.default`.** nixarchy sets
  `programs.hyprland.package` at *plain* priority (Omarchy *is* Hyprland, see its
  `modules/nixos.nix`) and hydenix sets it at plain priority too — two plain definitions is
  `conflicting definition values`. `hydenix/modules/system/` is still safe to import: it has no
  dependency on the hydenix module. Same for `hydenix/modules/hm/{helium,vscode,remmina,wolf}.nix`;
  `firefox.nix` is shared too, which is why the `hydenix.hm.firefox.enable = false` line lives in
  the hydenix-only `hydenix/modules/hm/default.nix`.
- `home-manager.follows = "nixarchy/home-manager"` in `flake.nix` is mandatory: nixarchy's NixOS
  module imports its own home-manager module, and two HM versions in one config is a duplicated
  option set. It applies to hydenix and wsl too.
- `nix flake check --no-build` cannot evaluate `hydenix` after an input bump until
  `pkgs.hyde` (the `hyde-modified` derivation) is realised — hydenix's HM interpolates its store
  path into `home.file.source`. Fix: `nix build --impure --no-link --expr
  '(builtins.getFlake "git+file:///etc/nixos").nixosConfigurations.hydenix.pkgs.hyde'`.
- nixarchy sets `boot.kernelPackages = pkgs.linuxPackages_latest` at `mkDefault` (7.2.x), where
  hydenix pins `pkgs.linuxPackages` (6.18.x). The NVIDIA driver is built per kernel
  (`nvidia-kernel-modules-595.104.02-<kernel>`), so switching changes the kernel module that has to
  compile and load. Everything else GPU-related is identical on both hosts: nixarchy never touches
  `hardware.graphics` or `hardware.nvidia`, and `hardware.graphics.package` is nixpkgs' `mesa`
  default on both, with the NVIDIA userspace arriving via `graphics.extraPackages`. This is the
  one genuinely unproven path — prove it with `nixos-rebuild build --flake /etc/nixos#nixarchy`.
- bladebro/donsetch are not packages — they're npm-installed into `$HOME/.npm` and need `programs.nix-ld` enabled (the NixOS stub loader rejects their prebuilt glibc binaries otherwise). Run `npm i -g bladebro donsetch` after a fresh install.

P.S. When user asks to install a NixOS package, use MCP Tool `nixos` to search and validate configuration options.
