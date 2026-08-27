{
  inputs,
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  llm = osConfig.local.llm;
  cleanJson = lib.filterAttrsRecursive (_: v: v != null);

  # Combined CA bundle: standard CAs + custom CAs
  combinedCABundle =
    pkgs.runCommand "combined-ca-bundle.crt"
      {
        buildInputs = [ pkgs.cacert ];
      }
      ''
        cat ${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt \
            ${./../modules/cert/ca-ff.ru.crt} \
            ${./../modules/cert/ca-skyori.ru.crt} \
            ${./../modules/cert/ca-neoplatform.ru.crt} \
            ${./../modules/cert/SRVHADCS-CA.crt} \
            ${./../modules/cert/ca-ai-expert-openhands.crt} > $out
      '';

  caBundleArg = "-v";
  caBundleVal = "${combinedCABundle}:/etc/ssl/certs/ca-certificates.crt:ro";
  nodeExtraCA = "-e";
  nodeExtraCAVal = "NODE_EXTRA_CA_CERTS=/etc/ssl/certs/ca-certificates.crt";

  playwrightTmpArg = "-v";
  playwrightTmpVal = "/tmp/.playwright-mcp:/tmp/.playwright-mcp";
in
{
  config.home.file.".config/opencode/opencode.json" = lib.mkForce {
    force = true;
    text = builtins.toJSON (
      {
        "$schema" = "https://opencode.ai/config.json";
        permission = {
          webfetch = "allow";
          websearch = "allow";
          lsp = "allow";
        };
        compaction = {
          auto = true;
          prune = true;
          reserved = 16000;
        };
        disabled_providers = [ ];
        plugin = [
          "${inputs.ponytail}/.opencode/plugins/ponytail.mjs"
        ];
        agent.explore.model = llm.smallModel;
        mcp.hound = {
          type = "remote";
          url = "http://localhost:8765/mcp";
          enabled = true;
        };
        mcp.playwright = {
          type = "local";
          command = [
            "docker"
            "run"
            "-i"
            "--rm"
            "--init"
            "--network"
            "host"
            caBundleArg
            caBundleVal
            nodeExtraCA
            nodeExtraCAVal
            playwrightTmpArg
            playwrightTmpVal
            "playwright-mcp"
          ];
          enabled = true;
        };
      }
      // {
        provider = lib.mapAttrs (name: p: {
          inherit name;
          npm = "@ai-sdk/openai-compatible";
          models = cleanJson (p.models or { });
          options = {
            baseURL = p.url;
            apiKey = if p ? tokenFile then "{file:${osConfig.age.secrets."${name}-token".path}}" else "";
          };
        }) llm.providers;
      }
      // lib.optionalAttrs (llm.defaultModel != null) {
        model = llm.defaultModel;
        small_model = llm.smallModel;
      }
    );
  };
}
