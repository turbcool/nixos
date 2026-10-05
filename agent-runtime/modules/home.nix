# Agent configuration for pi + opencode, and the option surface shared with
# modules/nixos.nix (agenix secrets, managed Claude Code settings).
#
# This module is evaluator-agnostic: it only needs `lib`, `pkgs`, `config` and
# the flake inputs, so the exact same file runs under NixOS+Home Manager (where
# common/hm/agent-bridge.nix feeds it agenix-resolved providers) and under the
# standalone homeManagerConfiguration in this flake's `homeConfigurations`
# (where the data/providers.nix defaults — env-var tokens — are used verbatim).
{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.agent;
  inherit (cfg) providers;

  inherit (pkgs.stdenv.hostPlatform) system;
  llmAgents = inputs.llm-agents.packages.${system};

  # --- token resolution ---------------------------------------------------
  # One provider field (tokenSource) -> the three dialects each agent speaks.
  # `command` and `shell` are evaluated at request/launch time, so the token is
  # read fresh from the env or the agenix store path and never baked into a
  # config file in the store.
  tokenSyntax = lib.mapAttrs (
    _: p:
    let
      ts = p.tokenSource or { };
    in
    if ts ? file then
      {
        shell = "$(cat ${lib.escapeShellArg ts.file})";
        command = "!cat ${ts.file}";
        opencode = "{file:${ts.file}}";
      }
    else
      {
        # "$VAR" — expanded by the shell at launch time, so the key itself never
        # appears in the wrapper script. (`\$` escapes the Nix interpolation.)
        shell = "\"\$${ts.env}\"";
        command = "!printenv ${ts.env}";
        opencode = "{env:${ts.env}}";
      }
  ) providers;

  cleanJson = lib.filterAttrsRecursive (_: v: v != null);

  # --- pi ------------------------------------------------------------------
  # pi names its model fields differently from opencode:
  # opencode's limit.context/limit.output are pi's contextWindow/maxTokens.
  toPiModel = id: m: {
    inherit id;
    name = m.name or id;
    contextWindow = (m.limit or { }).context or 128000;
    maxTokens = (m.limit or { }).output or 32000;
  };

  # Every provider in data/providers.nix is an OpenAI-compatible proxy. Verified
  # live: {url}/v1/models answers 200 with a bearer token for all three, and
  # llm-free only answers on /v1 — so normalise rather than trusting p.url.
  toPiProvider = name: p: {
    baseUrl = "${lib.removeSuffix "/v1" p.url}/v1";
    api = "openai-completions";
    # "!command" is read at request time and never cached, so the decrypted
    # agenix token (or the env var) exists only in pi's memory — nothing to
    # leak via a JSON file. auth.json would take precedence, so don't run
    # /login for these.
    apiKey = tokenSyntax.${name}.command;
    models = lib.mapAttrsToList toPiModel (p.models or { });
  };

  # llm.defaultModel is opencode's "provider/model" form; pi wants them apart.
  defaultModel = lib.splitString "/" cfg.defaultModel;

  piModels = pkgs.writeText "pi-models.json" (
    builtins.toJSON {
      providers = lib.mapAttrs toPiProvider providers;
    }
  );

  piSettings = pkgs.writeText "pi-settings.json" (
    builtins.toJSON {
      defaultProvider = lib.head defaultModel;
      defaultModel = lib.last defaultModel;

      # Hides every other model from /model and pins Ctrl+P cycling to our own
      # providers. Needed because a shell exporting ANTHROPIC_API_KEY +
      # ANTHROPIC_BASE_URL for claude-code makes pi report the built-in
      # `anthropic` provider as ready — otherwise all bundled Claude models show
      # up in pi, pointed at the claude-code proxy.
      enabledModels = lib.mapAttrsToList (name: _: "${name}/*") providers;

      # pi npm-installs declared packages that are missing or out of date on
      # startup (package-manager.js installMissing), so listing them here is
      # enough — no activation hook needed. A network-less container therefore
      # needs its npm packages pre-seeded or it fails on first boot.
      #
      # @narumitw/pi-starship — native Starship-style footer plus its
      # configuring-pi-starship skill; config in data/pi-starship.toml.
      # donsetch — web_fetch/search/crawl/screenshot as native tools. The
      # github.com/dondai44423/donsetch README suggests a git: source, but the
      # pi entry point is the npm package (`pi.extensions` = ./pi-extension.ts).
      # Its prebuilt Rust binary is glibc, which programs.nix-ld
      # (common/modules/nix-ld.nix) already covers on NixOS.
      # @ff-labs/pi-fff — Rust/SIMD FFF file+content search, replacing the
      # built-in find/grep; mode config in data/pi-fff.json below. Its two native
      # layers (@ff-labs/fff-node via ffi-rs) ship per-platform prebuilds, and the
      # linux-x64-gnu ones match this host, so nothing is compiled here.
      # @piex-dev/init — /init prompt template that writes or improves the repo's
      # AGENTS.md. Prompt-only (`pi.prompts`), no extension and no tools, so it
      # costs nothing per request; pi already auto-loads AGENTS.md from the cwd
      # and its parents, so this only keeps that file honest.
      packages = [
        "npm:@narumitw/pi-starship"
        "npm:donsetch"
        "npm:@ff-labs/pi-fff"
        "npm:@piex-dev/init"
      ];

      # Skills and extensions are plain files in the agent dir — declare them
      # next to this module when there are any. Directories are copied, single
      # files are symlinked (edit, then /reload inside pi).
      # home.file.".pi/agent/skills/my-skill" = { source = ../data/pi/skills/my-skill; recursive = true; };
      # home.file.".pi/agent/extensions/foo.ts".source = ../data/pi/extensions/foo.ts;
    }
  );

  # https://pi.dev/packages/@ff-labs/pi-fff
  # "override" swaps pi's built-in find/grep for fffind/ffgrep and adds
  # multi_grep. pi reads this file before registering tools, and /fff-mode only
  # changes the running session (mode changes also want a /reload) — so this
  # file, not the session, is the place the mode is set.
  piFff = pkgs.writeText "pi-fff.json" (
    builtins.toJSON {
      mode = "override";
    }
  );

  # --- opencode ------------------------------------------------------------
  opencodeJson = pkgs.writeText "opencode.json" (
    builtins.toJSON (
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
          "${inputs.i-have-adhd}/.opencode/plugins/i-have-adhd.mjs"
        ];
        agent.explore.model = cfg.smallModel;
        # Absolute paths: MCP servers inherit the agent's environment, which
        # may predate home.sessionPath (e.g. GUI-launched) — never rely on PATH.
        mcp.donsetch = {
          type = "local";
          command = [
            "${config.home.homeDirectory}/.npm/bin/donsetch"
            "mcp"
          ];
          enabled = true;
        };
        mcp.bladebro = {
          type = "local";
          command = [
            "${config.home.homeDirectory}/.npm/bin/bladebro"
            "mcp"
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
            apiKey = tokenSyntax.${name}.opencode;
          };
        }) providers;
      }
      // lib.optionalAttrs (cfg.defaultModel != null) {
        model = cfg.defaultModel;
        small_model = cfg.smallModel;
      }
    )
  );

  # --- binaries ------------------------------------------------------------
  # Hides donsetch's web_crawl from pi. pi has no settings key for this —
  # `defaultTools` cannot do it either, because AgentSession passes
  # `includeAllExtensionTools: true` unconditionally, which re-activates every
  # extension tool regardless of that list. Only --exclude-tools reaches
  # _excludedToolNames.
  piNoCrawl = pkgs.runCommand "pi-no-crawl" { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
    mkdir -p "$out/bin"
    makeWrapper ${llmAgents.pi}/bin/pi "$out/bin/pi" --add-flags "--exclude-tools web_crawl"
  '';

  # Rendered config as store files, so the standalone container output can ship
  # them verbatim instead of re-implementing any of the rendering above.
  #
  # Same trick for the binaries: `agent.runtimePackages` is what our modules
  # contribute to home.packages, which keeps Home Manager's own baseline
  # (man-db, shared-mime-info, the HM reference manpage) out of the container
  # bundle while the two stay identical in content.
  runtimePackages =
    lib.optionals cfg.agents.enable [
      llmAgents.opencode
      piNoCrawl
    ]
    ++ lib.optionals cfg.agents.includeTui [ llmAgents.agent-deck ];

  runtimeFiles = {
    ".pi/agent/models.json" = piModels;
    ".pi/agent/settings.json" = piSettings;
    ".pi/agent/pi-fff.json" = piFff;
    ".pi/agent/pi-starship.toml" = ../data/pi-starship.toml;
    ".config/opencode/opencode.json" = opencodeJson;
  };
in
{
  options.agent = {
    providers = lib.mkOption {
      type = lib.types.attrs;
      default = import ../data/providers.nix;
      description = "Provider registry. NixOS replaces the tokenSource of every provider that has an `agenixFile` with an agenix store path (see modules/nixos.nix).";
    };

    plugins = lib.mkOption {
      type = lib.types.attrs;
      default = import ../data/plugins.nix;
      description = "Claude Code plugin marketplaces + enabled plugins (data/plugins.nix).";
    };

    mcp = lib.mkOption {
      type = lib.types.attrs;
      default = import ../data/mcp.nix { inherit pkgs; };
      description = "MCP server registry (data/mcp.nix).";
    };

    defaultModel = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "free/main";
      description = "opencode's `provider/model` form. pi splits it apart.";
    };

    smallModel = lib.mkOption {
      type = lib.types.str;
      default = "custom/qwen3-coder-next";
      description = "Small/subagent tier. Both pi and opencode read this, so one line moves both agents.";
    };

    skills.enable = lib.mkEnableOption "the bundled agent skills" // {
      default = true;
    };

    agents = {
      enable = lib.mkEnableOption "the agent binaries (pi, opencode) in home.packages" // {
        default = true;
      };
      includeTui = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Also install agent-deck. Turn off for slim/headless bundles.";
      };
    };

    pi.enable = lib.mkEnableOption "pi configuration" // {
      default = true;
    };
    opencode.enable = lib.mkEnableOption "opencode configuration" // {
      default = true;
    };

    claudeCode = {
      enable = lib.mkEnableOption "Claude Code integration" // {
        default = true;
      };
      provider = lib.mkOption {
        type = lib.types.str;
        default = "neoplatform";
      };
      mainModel = lib.mkOption {
        type = lib.types.str;
        default = "deepseek-v4-flash";
      };
      smallModel = lib.mkOption {
        type = lib.types.str;
        default = "qwen3-coder-128k:30b";
      };
      exposeRealBinary = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Also put the unwrapped claude on PATH. Off by default: it would collide with the `claude` wrapper, and the wrapper already execs it by absolute store path.";
      };
      wrappers = lib.mkOption {
        type = lib.types.listOf (
          lib.types.submodule {
            options = {
              name = lib.mkOption { type = lib.types.str; };
              provider = lib.mkOption { type = lib.types.str; };
              mainModel = lib.mkOption { type = lib.types.str; };
              smallModel = lib.mkOption { type = lib.types.str; };
              comment = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
              };
            };
          }
        );
        default = [
          {
            name = "claude-free";
            provider = "free";
            mainModel = "main";
            smallModel = "small";
            comment = "Same claude, repointed at the free endpoint (llm-free.naidanov.ru) with the free-account token. Deliberately NOT claudeCode.mainModel/smallModel — those are the neoplatform defaults.";
          }
        ];
      };
    };

    tokenSyntax = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            shell = lib.mkOption { type = lib.types.str; };
            command = lib.mkOption { type = lib.types.str; };
            opencode = lib.mkOption { type = lib.types.str; };
          };
        }
      );
      default = { };
      internal = true;
      description = "Per-provider token, rendered in the dialect each agent expects. Read by modules/wrappers.nix.";
    };

    runtimeFiles = lib.mkOption {
      type = lib.types.attrsOf lib.types.raw;
      default = { };
      internal = true;
      description = "Rendered config files as store paths, consumed by this flake's `agent-runtime-config` package.";
    };

    runtimePackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      internal = true;
      description = "Packages contributed by this module and modules/wrappers.nix. Mirrored into home.packages, and the sole content of this flake's `agent-runtime` package.";
    };
  };

  config = {
    agent.tokenSyntax = tokenSyntax;
    agent.runtimeFiles = runtimeFiles;
    agent.runtimePackages = runtimePackages;

    home.packages = config.agent.runtimePackages;

    # ~/.pi/agent/ is split deliberately. models.json is fully declarative here
    # — pi only ever reads it — while settings.json is force-managed just like
    # ~/.config/opencode/opencode.json, so changes made from pi's /settings are
    # reverted on the next activation. auth.json, sessions/, git/ and npm/ stay
    # user-owned so pi's own /login, pi install and session writes work.
    home.file = lib.mkMerge [
      (lib.optionalAttrs cfg.pi.enable {
        ".pi/agent/models.json" = {
          source = piModels;
        };
        ".pi/agent/settings.json" = {
          source = piSettings;
          force = true;
        };
        ".pi/agent/pi-starship.toml".source = ../data/pi-starship.toml;
        ".pi/agent/pi-fff.json" = {
          source = piFff;
          force = true;
        };
      })
      (lib.optionalAttrs cfg.opencode.enable {
        ".config/opencode/opencode.json" = {
          source = opencodeJson;
          force = true;
        };
      })
    ];

    # pi coding-agent — https://pi.dev
    assertions = [
      {
        assertion = lib.length defaultModel == 2;
        message = "agent.defaultModel must be \"provider/model\", got '${cfg.defaultModel}'";
      }
    ]
    ++ lib.mapAttrsToList (name: p: {
      assertion = p ? tokenSource && (p.tokenSource ? env || p.tokenSource ? file);
      message = "agent.providers.${name}.tokenSource must have `env` or `file`";
    }) providers;
  };

  imports = [
    ./skills.nix
    ./wrappers.nix
  ];
}
