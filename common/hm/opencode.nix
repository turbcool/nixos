{
  lib,
  pkgs,
  ...
} :

{
  home.file = {
    ".config/opencode/opencode.json" = lib.mkForce {
      source = ./config/opencode.json;
    };
    ".config/opencode/oh-my-opencode.json" = lib.mkForce {
      source = ./config/oh-my-opencode.json;
    };
  };
}

