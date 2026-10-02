# pi coding agent: config only. The binary is a system package (common/modules/llm.nix).
#
# ~/.pi/agent/ is split deliberately. models.json is fully declarative here — pi
# only ever reads it — while settings.json is force-managed just like
# ~/.config/opencode/opencode.json, so changes made from pi's /settings are
# reverted on the next home-manager activation. auth.json, sessions/, git/ and
# npm/ stay user-owned so pi's own /login, pi install and session writes work.
{
  inputs,
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  llm = osConfig.local.llm;

  # pi names its model fields differently from opencode:
  # opencode's limit.context/limit.output are pi's contextWindow/maxTokens.
  toPiModel = id: m: {
    inherit id;
    name = m.name or id;
    contextWindow = (m.limit or { }).context or 128000;
    maxTokens = (m.limit or { }).output or 32000;
  };

  # Every provider in config/providers.nix is an OpenAI-compatible proxy. Verified
  # live: {url}/v1/models answers 200 with a bearer token for all three, and
  # llm-free only answers on /v1 — so normalise rather than trusting p.url.
  toPiProvider = name: p: {
    baseUrl = "${lib.removeSuffix "/v1" p.url}/v1";
    api = "openai-completions";
    # "!command" is read at request time and never cached, so the decrypted
    # agenix token exists only in pi's memory — nothing to leak via a JSON
    # file. auth.json would take precedence, so don't run /login for these.
    apiKey = "!cat ${osConfig.age.secrets."${name}-token".path}";
    models = lib.mapAttrsToList toPiModel (p.models or { });
  };

  # llm.defaultModel is opencode's "provider/model" form; pi wants them apart.
  defaultModel = lib.splitString "/" llm.defaultModel;
in
{
  home.file.".pi/agent/models.json".text = builtins.toJSON {
    providers = lib.mapAttrs toPiProvider llm.providers;
  };

  home.file.".pi/agent/settings.json" = lib.mkForce {
    force = true;
    text = builtins.toJSON {
      defaultProvider = lib.head defaultModel;
      defaultModel = lib.last defaultModel;

      # Hides every other model from /model and pins Ctrl+P cycling to our own
      # providers. Needed because ~/.zshrc exports ANTHROPIC_API_KEY +
      # ANTHROPIC_BASE_URL for claude-code, which makes pi report the built-in
      # `anthropic` provider as ready — otherwise all bundled Claude models show
      # up in pi, pointed at the claude-code proxy.
      enabledModels = lib.mapAttrsToList (name: _: "${name}/*") llm.providers;

      # pi npm-installs declared packages that are missing or out of date on
      # startup (package-manager.js installMissing), so listing them here is
      # enough — no activation hook needed.
      #
      # @narumitw/pi-starship — native Starship-style footer plus its
      # configuring-pi-starship skill; config in pi/pi-starship.toml below.
      # donsetch — web_fetch/search/crawl/screenshot as native tools. The
      # github.com/dondai44423/donsetch README suggests a git: source, but the
      # pi entry point is the npm package (`pi.extensions` = ./pi-extension.ts).
      # Its prebuilt Rust binary is glibc, which programs.nix-ld
      # (common/modules/nix-ld.nix) already covers.
      # @ff-labs/pi-fff — Rust/SIMD FFF file+content search, replacing the
      # built-in find/grep; mode config in pi/pi-fff.json below. Its two native
      # layers (@ff-labs/fff-node via ffi-rs) ship per-platform prebuilds, and
      # the linux-x64-gnu ones match this host, so nothing is compiled here.
      packages = [
        "npm:@narumitw/pi-starship"
        "npm:donsetch"
        "npm:@ff-labs/pi-fff"
      ];

      # Skills and extensions are plain files in the agent dir — declare them
      # next to this module when there are any. Directories are copied, single
      # files are symlinked (edit, then /reload inside pi).
      # home.file.".pi/agent/skills/my-skill" = { source = ../pi/skills/my-skill; recursive = true; };
      # home.file.".pi/agent/extensions/foo.ts".source = ../pi/extensions/foo.ts;
    };
  };

  home.file.".pi/agent/pi-starship.toml".source = ./pi/pi-starship.toml;

  # https://pi.dev/packages/@ff-labs/pi-fff
  # "override" swaps pi's built-in find/grep for fffind/ffgrep and adds
  # multi_grep. pi reads this file before registering tools, and /fff-mode only
  # changes the running session (mode changes also want a /reload) — so this
  # file, not the session, is the place the mode is set.
  home.file.".pi/agent/pi-fff.json" = lib.mkForce {
    force = true;
    text = builtins.toJSON {
      mode = "override";
    };
  };

  # pi coding-agent — https://pi.dev
  assertions = [
    {
      assertion = lib.length defaultModel == 2;
      message = "local.llm.defaultModel must be \"provider/model\", got '${llm.defaultModel}'";
    }
  ];
}
