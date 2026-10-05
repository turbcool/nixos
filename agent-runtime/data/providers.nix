# Provider registry shared by claude-code, opencode and pi.
#
# `tokenSource` has exactly one of:
#   { env  = "VAR"; }   # default — works anywhere, including containers
#   { file = "/path"; } # written by modules/nixos.nix to the agenix store path
#
# `agenixFile` is NixOS-only (relative to this file, so it reaches ../../common).
# It is ignored by every non-NixOS consumer, which is what makes this file
# portable: on a plain container you only need the env vars, never agenix.
#
# The NixOS module rewrites every provider that has an `agenixFile` into
# { file = <agenix store path>; } and declares the matching age secret, so the
# host never carries keys in its environment while containers do the opposite.
{
  neoplatform = {
    url = "https://llm.neoplatform.ru";
    agenixFile = ../../common/secrets/neoplatform-token.age;
    tokenSource.env = "AGENT_NEOPLATFORM_TOKEN";
    models."qwen3-coder-128k:30b".limit = {
      context = 128000;
      output = 32000;
    };
    models."gemma-4-31b-it".limit = {
      context = 200000;
      output = 32000;
    };
    models."deepseek-v4-flash".limit = {
      context = 200000;
      output = 32000;
    };
  };
  custom = {
    url = "https://llm.naidanov.ru";
    agenixFile = ../../common/secrets/custom-token.age;
    tokenSource.env = "AGENT_CUSTOM_TOKEN";
    models."deepseek-v4-flash-direct".limit = {
      context = 200000;
      output = 32000;
    };
    models."deepseek-v4-flash".limit = {
      context = 200000;
      output = 32000;
    };
    models."qwen3-coder-next".limit = {
      context = 128000;
      output = 32000;
    };
  };
  free = {
    url = "https://llm-free.naidanov.ru/v1";
    anthropicUrl = "https://llm-free.naidanov.ru";
    agenixFile = ../../common/secrets/free-token.age;
    tokenSource.env = "AGENT_FREE_TOKEN";
    models."muse-spark-1.3-contributor".name = "Muse Spark 1.3 Contributor";
    models."main".limit = {
      context = 256000;
      output = 32000;
    };
  };
}
