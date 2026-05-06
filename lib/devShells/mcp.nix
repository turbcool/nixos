# Отдаёт devShell, который через OPENCODE_CONFIG подключает MCP-серверы.
# opencode мерджит этот конфиг с глобальным и проектным автоматически.
# Использование в .envrc проекта: use flake /etc/nixos#mcp
{ pkgs }:

let
  mcps = import ../../config/mcp.nix;
  configFile = pkgs.writeText "opencode-mcp.json" (builtins.toJSON { mcp = mcps; });
in
{
  devShell = pkgs.mkShellNoCC {
    OPENCODE_CONFIG = toString configFile;
  };
}
