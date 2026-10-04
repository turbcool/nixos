{
  ...
}:

{
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
