This is a NixOS flake-based configuration with Home Manager enabled.

- `/flake.nix` - entry point for `hydenix` and `wsl` hosts
- `/common/pkgs` - shared system package modules used across hosts
- `/common/modules` - shared system modules (git, cert, llm, tmux)
- `/common/hm` - shared Home Manager modules
- `/hydenix/configuration.nix` - desktop host configuration
- `/hydenix/modules/system` - desktop system modules
- `/hydenix/modules/hm` - desktop Home Manager modules
- `/hydenix/config` - custom Hydenix config files
- `/hydenix/docs` - Hydenix documentation
- `/wsl/configuration.nix` - WSL host configuration

`default.nix` files in module directories import child modules.
