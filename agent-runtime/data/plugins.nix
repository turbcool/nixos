{
  marketplaces = {
    claude-plugins-official = {
      source = {
        source = "github";
        repo = "anthropics/claude-plugins-official";
      };
      autoUpdate = true;
    };
    ponytail = {
      source = {
        source = "github";
        repo = "DietrichGebert/ponytail";
      };
      autoUpdate = true;
    };
    i-have-adhd = {
      source = {
        source = "github";
        repo = "ayghri/i-have-adhd";
      };
      autoUpdate = true;
    };
  };

  plugins = {
    "code-simplifier@claude-plugins-official" = true;
    "ponytail@ponytail" = true;
    "i-have-adhd@i-have-adhd" = true;
  };
}
