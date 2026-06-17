{
  marketplaces = {
    claude-plugins-official = {
      source = {
        source = "github";
        repo = "anthropics/claude-plugins-official";
      };
      autoUpdate = true;
    };
  };

  plugins = {
    "code-simplifier@claude-plugins-official" = true;
  };
}
