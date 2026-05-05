lib:

let
  modelType = lib.types.submodule {
    options = {
      name = lib.mkOption { type = lib.types.str; };
      family = lib.mkOption { type = lib.types.str; };
      tool_call = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
      reasoning = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
      modalities = lib.mkOption {
        type = lib.types.attrsOf (lib.types.listOf lib.types.str);
        default = {
          input = [ "text" ];
          output = [ "text" ];
        };
      };
      temperature = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
      release_date = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
      limit = lib.mkOption {
        type = lib.types.nullOr (lib.types.attrsOf lib.types.int);
        default = null;
      };
    };
  };

  providerType = lib.types.submodule {
    options = {
      url = lib.mkOption { type = lib.types.str; };
      npm = lib.mkOption {
        type = lib.types.str;
        default = "@ai-sdk/openai-compatible";
      };
      tokenFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
      };
      models = lib.mkOption {
        type = lib.types.attrsOf modelType;
        default = { };
      };
    };
  };

  filterPresent = lib.filterAttrs (_: p: p.tokenFile != null && builtins.pathExists p.tokenFile);

  filterMissing = lib.filterAttrs (_: p: p.tokenFile != null && !builtins.pathExists p.tokenFile);
in

{
  inherit
    modelType
    providerType
    filterPresent
    filterMissing
    ;

  mkAgeSecrets =
    providers: username:
    lib.mapAttrs' (name: provider: {
      name = "${name}-token";
      value = {
        file = provider.tokenFile;
        owner = username;
        mode = "0400";
      };
    }) providers;

  mkOpencodeProviders =
    providers: providersWithTokens: ageSecrets:
    lib.mapAttrs (name: provider: {
      inherit name;
      npm = provider.npm;
      models = provider.models;
      options = {
        baseURL = provider.url;
        apiKey = if providersWithTokens ? ${name} then "{file:${ageSecrets."${name}-token".path}}" else "";
      };
    }) providers;

  mkWarnings =
    providers:
    lib.mapAttrsToList (
      name: provider: "Missing ${toString provider.tokenFile}; ${name} token will not be available."
    ) providers;
}
