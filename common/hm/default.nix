{ inputs, ... }:

{
  imports = [
    ./agent-bridge.nix
    ./agent-skills.nix
    ./calendar.nix
    ./cli.nix
    ./direnv.nix
    ./glab.nix
    ./neovim.nix
    ./ssh.nix
    ./tmux.nix
    ./yazi.nix
    ./zoxide.nix
    # pi + opencode config, the claude/claude-free/writing commands, the
    # bundled skills and the `mcp` command. The NixOS half (agenix tokens,
    # Claude Code managed settings) is imported from commonModules.
    inputs.agent-runtime.homeModules.default
  ];
}
