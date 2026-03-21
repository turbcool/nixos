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

  home.packages = with pkgs; [
    opencode
  ];
  home.sessionVariables = {
    OPENAI_BASE_URL = "https://ai.flexberry.org/v1";
    OPENAI_MODEL = "flexberry/qwen3-coder-128k:30b";
    OPENAI_TOKEN = "sk-lLCX9gY1uDJLpUx8V5SaeQ";
  };
}

