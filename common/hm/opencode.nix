{
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  llm = osConfig.local.llm;
  cleanJson = lib.filterAttrsRecursive (_: v: v != null);
in
{
  config.home.file.".config/opencode/opencode.json" = lib.mkForce {
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
        mcp.web-search-prime = {
          type = "remote";
          url = "https://api.z.ai/api/mcp/web_search_prime/mcp";
          enabled = true;
          headers.Authorization = "Bearer __ZAI_TOKEN__";
        };
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

  config.home.activation.patch-opencode-zai-token = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    tokenFile="${osConfig.age.secrets.zai-token.path}"
    configFile="$HOME/.config/opencode/opencode.json"

    if [ -f "$tokenFile" ] && [ -f "$configFile" ]; then
      token=$(cat "$tokenFile")
      ${pkgs.jq}/bin/jq --arg token "$token" \
        '.mcp["web-search-prime"].headers.Authorization = "Bearer \($token)"' \
        "$configFile" > "$configFile.tmp" \
        && mv "$configFile.tmp" "$configFile"
    fi
  '';
}
