{
  neoplatform = {
    url = "https://llm.neoplatform.ru";
    tokenFile = ../common/secrets/neoplatform-token.age;
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
    tokenFile = ../common/secrets/custom-token.age;
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
}
