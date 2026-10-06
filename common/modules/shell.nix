{ ... }:

# Z shell is the one thing here that a non-Home-Manager login still wants on
# PATH. The agent CLI (pi, opencode, claude, mcp, skills) ships in the runtime
# module's home.packages, not here, so adding it here would only collide.
{
  programs.zsh.enable = true;
}
