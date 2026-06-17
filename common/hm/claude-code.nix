{
  osConfig,
  lib,
  pkgs,
  ...
}:

let
  llm = osConfig.local.llm;
  cc = llm.claudeCode;
  ccProvider = llm.providers.${cc.provider};
  ccTokenPath = osConfig.age.secrets."${cc.provider}-token".path;
  ccBaseUrl = ccProvider.anthropicUrl or ccProvider.url;
  authExport =
    if (ccProvider.authToken or false) then
      ''export ANTHROPIC_AUTH_TOKEN="$(cat ${ccTokenPath})"''
    else
      ''export ANTHROPIC_API_KEY="$(cat ${ccTokenPath})"'';
in
{
  config = lib.mkIf cc.enable {
    home.file.".claude/settings.json" = {
      force = true;
      text = builtins.toJSON {
        env = {
          ANTHROPIC_BASE_URL = ccBaseUrl;
          ANTHROPIC_DEFAULT_OPUS_MODEL = cc.models.opus;
          ANTHROPIC_DEFAULT_SONNET_MODEL = cc.models.sonnet;
          ANTHROPIC_DEFAULT_HAIKU_MODEL = cc.models.haiku;
          CLAUDE_CODE_SUBAGENT_MODEL = cc.models.subagent;
          CLAUDE_CODE_AUTO_COMPACT_WINDOW = "1000000";
        };
      };
    };

    programs.zsh.initContent = ''
      ${authExport}
      export ANTHROPIC_BASE_URL="${ccBaseUrl}"
      export ANTHROPIC_DEFAULT_OPUS_MODEL="${cc.models.opus}"
      export ANTHROPIC_DEFAULT_SONNET_MODEL="${cc.models.sonnet}"
      export ANTHROPIC_DEFAULT_HAIKU_MODEL="${cc.models.haiku}"
      export CLAUDE_CODE_SUBAGENT_MODEL="${cc.models.subagent}"
      export CLAUDE_CODE_AUTO_COMPACT_WINDOW="1000000"
    '';
  };
}
