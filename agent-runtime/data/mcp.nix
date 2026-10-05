{ pkgs }:

{
  nixos = {
    type = "local";
    command = [ "mcp-nixos" ];
    enabled = true;
  };
  daisyui = {
    type = "local";
    command = [
      "docker"
      "run"
      "-i"
      "--rm"
      "daisyui-mcp"
    ];
    enabled = true;
  };
  svelte = {
    type = "remote";
    url = "https://mcp.svelte.dev/mcp";
    enabled = true;
  };
  lucide-icons = {
    type = "local";
    command = [
      "npx"
      "lucide-icons-mcp"
      "--stdio"
    ];
    enabled = true;
  };

  wiki = {
    type = "local";
    command = [ "qmd" "mcp" ];
    enabled = true;
  };

  donsetch = {
    type = "local";
    command = [ "donsetch" "mcp" ];
    enabled = true;
  };

  bladebro = {
    type = "local";
    command = [ "bladebro" "mcp" ];
    enabled = true;
  };

  groups = {
    nixos = [ "nixos" ];
    frontend = [ "svelte" "daisyui" "lucide-icons"];
    wiki = [ "wiki" ];
  };

  claudeCode = {
    donsetch = {
      type = "stdio";
      command = "donsetch";
      args = [ "mcp" ];
    };
    bladebro = {
      type = "stdio";
      command = "bladebro";
      args = [ "mcp" ];
    };
  };
}
