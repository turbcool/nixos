{ inputs, ... }:

{
  imports = [
    ./agent-bridge.nix
    ./agent-skills.nix
    ./calendar.nix
    ./claude-code.nix
    ./cli.nix
    ./direnv.nix
    ./glab.nix
    ./neovim.nix
    ./ssh.nix
    ./tmux.nix
    ./yazi.nix
    ./zoxide.nix
    # pi + opencode config and the claude/claude-free/writing wrappers.
    inputs.agent-runtime.homeModules.default
  ];
}
