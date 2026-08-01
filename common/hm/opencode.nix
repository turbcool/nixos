{
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  llm = osConfig.local.llm;
  cleanJson = lib.filterAttrsRecursive (_: v: v != null);

  # Combined CA bundle: standard CAs + custom CAs
  combinedCABundle = pkgs.runCommand "combined-ca-bundle.crt" {
    buildInputs = [ pkgs.cacert ];
  } ''
    cat ${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt \
        ${./../modules/cert/ca-ff.ru.crt} \
        ${./../modules/cert/ca-skyori.ru.crt} \
        ${./../modules/cert/ca-neoplatform.ru.crt} \
        ${./../modules/cert/SRVHADCS-CA.crt} > $out
  '';

  caBundleArg = "-v";
  caBundleVal = "${combinedCABundle}:/etc/ssl/certs/ca-certificates.crt:ro";
  nodeExtraCA = "-e";
  nodeExtraCAVal = "NODE_EXTRA_CA_CERTS=/etc/ssl/certs/ca-certificates.crt";
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
        agent.explore.model = "neoplatform/qwen3-coder-128k:30b";
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
            caBundleArg
            caBundleVal
            nodeExtraCA
            nodeExtraCAVal
            "playwright-mcp"
          ];
          enabled = true;
        };
      }
      // {
        provider = lib.mapAttrs (name: p: {
          inherit name;
          npm = p.npm or "@ai-sdk/openai-compatible";
          models = cleanJson (
            lib.mapAttrs (_: m: builtins.removeAttrs m [ "opencode" ]) (
              lib.filterAttrs (_: m: m.opencode or true) (p.models or { })
            )
          );
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
