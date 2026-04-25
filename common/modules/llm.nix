{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  openaiTokenFile = ../../hydenix/secrets/openai-token.age;
  hasOpenAIToken = builtins.pathExists openaiTokenFile;
in

{
  environment.systemPackages = with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
    agent-deck
    opencode
  ];

  nix.settings = {
    "connect-timeout" = 10;
    "stalled-download-timeout" = 30;
    "download-attempts" = 5;
  };

  environment.sessionVariables = {
    OPENAI_BASE_URL = "https://ai.flexberry.org/v1";
    OPENAI_MODEL = "flexberry/qwen3-coder-128k:30b";
  } // lib.optionalAttrs hasOpenAIToken {
    OPENAI_TOKEN_FILE = config.age.secrets.openai-token.path;
  };

  age.secrets = lib.mkIf hasOpenAIToken {
    openai-token = {
      file = openaiTokenFile;
      owner = "root";
      group = "root";
      mode = "0400";
    };
  };

  environment.etc = lib.mkIf hasOpenAIToken {
    "profile.d/openai-token.sh".text = ''
      if [ -r "${config.age.secrets.openai-token.path}" ]; then
        export OPENAI_TOKEN="$(cat ${config.age.secrets.openai-token.path})"
      fi
    '';
  };

  warnings = lib.optional (!hasOpenAIToken) ''
    Missing ${toString openaiTokenFile}; OPENAI_TOKEN will not be exported.
  '';
}
