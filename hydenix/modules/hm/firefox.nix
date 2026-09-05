{
  config,
  ...
}:

{
  # hydenix adds a plain `firefox` to home.packages; disable it so we can
  # manage Firefox ourselves and pull in the Russian language pack cleanly.
  hydenix.hm.firefox.enable = false;

  programs.firefox = {
    enable = true;
    languagePacks = [ "ru" ];
    profiles.default = {
      path = "knl9qu88.default";
      settings = {
        "intl.locale.requested" = [ "ru" ];
      };
    };
  };
}
