{
  neoplatform = {
    url = "https://llm.neoplatform.ru";
    tokenFile = ../common/secrets/neoplatform-token.age;
    models."qwen3-coder-128k:30b" = {
      name = "Qwen3-Coder-Next";
      family = "qwen";
      release_date = "2026-02-03";
      limit = {
        context = 128000;
        output = 32000;
      };
    };
    models."gemma-4-31b-it" = {
      name = "Gemma 4 31B";
      family = "gemma";
      release_date = "2026-02-03";
      limit = {
        context = 200000;
        output = 32000;
      };
    };
    models."deepseek-v4-flash" = {
      name = "Deepseek V4 Flash";
      family = "deepseek";
      release_date = "2026-02-03";
      limit = {
        context = 200000;
        output = 32000;
      };
    };
  };
  custom = {
    url = "https://llm.naidanov.ru";
    tokenFile = ../common/secrets/custom-token.age;
    models."deepseek-v4-flash-direct" = {
      name = "Deepseek V4 Flash (DeepSeek API)";
      family = "deepseek";
      release_date = "2026-02-03";
      limit = {
        context = 200000;
        output = 32000;
      };
    };
    models."deepseek-v4-flash" = {
      name = "Deepseek V4 Flash (Neoplatform)";
      family = "deepseek";
      release_date = "2026-02-03";
      limit = {
        context = 200000;
        output = 32000;
      };
    };
    models."qwen3-coder-next" = {
      name = "Qwen3-Coder-Next";
      family = "qwen";
      release_date = "2026-02-03";
      limit = {
        context = 128000;
        output = 32000;
      };
    };
  };
  free = {
    url = "https://llm-free.naidanov.ru";
    tokenFile = ../common/secrets/free-token.age;
    models."deepseek-zen-free" = {
      name = "Deepseek Zen Free";
      family = "deepseek";
    };
    models."qwen3-coder-next" = {
      name = "Qwen3-Coder-Next";
      family = "qwen";
      release_date = "2026-02-03";
      limit = {
        context = 128000;
        output = 32000;
      };
    };
  };
}
