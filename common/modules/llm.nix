{ inputs, pkgs, ... }:

{
  environment.systemPackages = with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
    agent-deck
    opencode
  ];
  environment.sessionVariables = {
    OPENAI_BASE_URL = "https://ai.flexberry.org/v1";
    OPENAI_MODEL = "flexberry/qwen3-coder-128k:30b";
    OPENAI_TOKEN = "sk-lLCX9gY1uDJLpUx8V5SaeQ";
  };
}

