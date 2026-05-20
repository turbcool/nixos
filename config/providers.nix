{
  neoplatform = {
    url = "https://llm.neoplatform.ru/v1";
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
  };
  flexberry = {
    url = "https://ai.flexberry.org/v1";
    tokenFile = ../common/secrets/flexberry-token.age;
    models."GLM-5.1" = {
      name = "glm-5.1";
      family = "glm";
      release_date = "2026-02-03";
      limit = {
        context = 200000;
        output = 128000;
      };
    };
  };

  custom = {
    url = "https://llm.naidanov.ru/v1";
    tokenFile = ../common/secrets/custom-token.age;
    models.coder = {
      name = "Coder";
      family = "coder";
    };
  };
}
