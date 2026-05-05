This is a NixOS flake-based configuration with Home Manager enabled.

- `/flake.nix` - entry point for `hydenix` and `wsl` hosts
- `/common/pkgs` - shared system package modules used across hosts
- `/common/modules` - shared system modules (git, cert, llm, nix, shell, docker)
- `/common/hm` - shared Home Manager modules
- `/hydenix/configuration.nix` - desktop host configuration
- `/hydenix/modules/system` - desktop system modules
- `/hydenix/modules/system/work/vpn` - NetworkManager L2TP profile files
- `/hydenix/modules/hm` - desktop Home Manager modules
- `/hydenix/modules/hm/hyprland` - Hyprland Home Manager config files
- `/hydenix/modules/hm/remmina` - Remmina Home Manager config files
- `/hydenix/modules/hm/wolf` - Wolf Home Manager config files
- `/hydenix/docs` - Hydenix documentation
- `/wsl/configuration.nix` - WSL host configuration

`default.nix` files in module directories import child modules.

**Development tools** (available in `/etc/nixos` devshell):
- `nixfmt-rfc-style` - format Nix code
- `nixd` - Nix LSP for editor support
- `statix` - Nix linter
- `agenix` - manage secrets

Run `direnv allow` once to auto-load the devshell on `cd /etc/nixos`.
