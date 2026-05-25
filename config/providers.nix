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
    models."GLM-5.1" = {
      name = "GLM-5.1";
      family = "glm";
      attachment = false;
      reasoning = true;
      tool_call = true;
      interleaved.field = "reasoning_content";
      structured_output = true;
      temperature = true;
      release_date = "2026-03-27";
      last_updated = "2026-03-27";
      modalities = {
        input = [ "text" ];
        output = [ "text" ];
      };
      limit = {
        context = 200000;
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
    models.coder = {
      name = "Coder";
      family = "coder";
    };
  };
}
