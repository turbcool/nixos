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
    models."GLM-5.1" = {
      name = "GLM-5.1";
      family = "glm";
      attachment = false;
      reasoning = true;
      tool_call = true;
      interleaved.field = "reasoning_content";
      structured_output = true;
      temperature = true;
      release_date = "2026-06-13";
      last_updated = "2026-06-13";
      modalities = {
        input = [ "text" ];
        output = [ "text" ];
      };
      limit = {
        context = 1000000;
        output = 131072;
      };
      cost = {
        input = 1.4;
        output = 4.4;
        cache_read = 0.26;
      };
    };
    models."GLM-5.1A" = {
      name = "GLM-5.1A";
      family = "glm";
      opencode = false;
      attachment = false;
      reasoning = true;
      tool_call = true;
      structured_output = true;
      temperature = true;
      release_date = "2026-06-13";
      last_updated = "2026-06-13";
      modalities = {
        input = [ "text" ];
        output = [ "text" ];
      };
      limit = {
        context = 1000000;
        output = 131072;
      };
      cost = {
        input = 1.4;
        output = 4.4;
        cache_read = 0.26;
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
    models."minimax-m3-zen" = {
      name = "Minimax M3 Zen";
      family = "minimax";
    };
  };
  free = {
    url = "https://llm-free.naidanov.ru";
    tokenFile = ../common/secrets/free-token.age;
    models."auto/coding" = {
      name = "Auto Coding";
      family = "auto";
    };
    models."auto/best-coding" = {
      name = "Auto Best Coding";
      family = "auto";
    };
    models."auto/best-coding-fast" = {
      name = "Auto Best Coding Fast";
      family = "auto";
    };
    models."deepseek-zen-free" = {
      name = "Deepseek Zen Free";
      family = "deepseek";
    };
    models."minimax-zen-free" = {
      name = "Minimax Zen Free";
      family = "minimax";
    };
    models."zen-free" = {
      name = "Zen Free";
      family = "zen";
    };
  };
  zai = {
    url = "https://api.z.ai/api/coding/paas/v4";
    anthropicUrl = "https://api.z.ai/api/anthropic";
    authToken = true;
    tokenFile = ../common/secrets/zai-token.age;
    models."glm-5.2" = {
      name = "GLM-5.2";
      family = "glm";
      attachment = false;
      reasoning = true;
      tool_call = true;
      interleaved.field = "reasoning_content";
      structured_output = true;
      temperature = true;
      release_date = "2026-06-13";
      last_updated = "2026-06-13";
      modalities = {
        input = [ "text" ];
        output = [ "text" ];
      };
      limit = {
        context = 1000000;
        output = 131072;
      };
      cost = {
        input = 0.0;
        output = 0.0;
      };
    };
  };
}
