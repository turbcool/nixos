{ inputs, pkgs, ... }:

{
  environment.systemPackages = with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
    agent-deck
    opencode
    codex
  ];

  nix.settings = {
    "extra-substituters" = [
      "https://cache.numtide.com"
    ];
    "extra-trusted-public-keys" = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
    ];
  };

  environment.sessionVariables = {
    OPENAI_BASE_URL = "https://ai.flexberry.org/v1";
    OPENAI_MODEL = "flexberry/qwen3-coder-128k:30b";
    OPENAI_TOKEN = "sk-lLCX9gY1uDJLpUx8V5SaeQ";
  };
}
