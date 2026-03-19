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
  };

  home.packages = with pkgs; [
    opencode
  ];
}

