# NixOS Config Quick Guide

This repo is organized for quick edits with minimal indirection.

## Where to change things

- Host identity and feature toggles (desktop): `hydenix/configuration.nix`
- Host identity (WSL): `wsl/configuration.nix`
- Shared defaults for identity fields: `common/modules/profile.nix`
- Shared system packages: `common/pkgs/`
- Shared system modules/services: `common/modules/`
- Shared Home Manager modules: `common/hm/`
- Desktop-only system modules: `hydenix/modules/system/`
- Desktop-only Home Manager modules: `hydenix/modules/hm/`

## Feature toggles (desktop)

Set these in `hydenix/configuration.nix` under `local.features`:

- `browsers.enable` -> `hydenix/modules/system/browsers/`
- `gaming.enable` -> `hydenix/modules/system/gaming/`
- `gaming.vr.enable` -> `hydenix/modules/system/gaming/vr.nix`
- `work.enable` -> `hydenix/modules/system/work/`
- `work.syncthing.enable` -> `hydenix/modules/system/work/syncthing.nix`

## Module-owned config files

- Hyprland HM config files: `hydenix/modules/hm/hyprland/`
- Remmina HM config files: `hydenix/modules/hm/remmina/`
- Wolf HM config files: `hydenix/modules/hm/wolf/`
- L2TP NetworkManager profile: `hydenix/modules/system/work/vpn/work.conf`

## Common commands

```bash
nix flake check --no-build
sudo nixos-rebuild switch --flake /etc/nixos#hydenix
sudo nixos-rebuild switch --flake /etc/nixos#wsl
```

## Agent skills (per-project)

Skills are **not** installed globally. To activate in a project:

```bash
skills              # list available groups and sources
skills wiki         # install wiki skills to .opencode/skills/
skills obsidian-wiki  # install just obsidian-wiki skills
```

Skills are installed to `./.opencode/skills/` (add to `.gitignore`).

To add more skill sources or groups, edit `config/skills.nix`.

## MCP servers (per-project)

MCP servers are **not** in the global opencode config. To activate in a project:

```bash
mcp                 # list available groups and servers
mcp svelte          # write svelte MCP config to opencode.json
mcp ui              # write daisyui + lucide-icons MCP config
mcp all             # write all MCP servers
```

Multiple `mcp` calls **merge** into `opencode.json` (deep merge via jq).

To add more MCP servers or groups, edit `config/mcp.nix`.
