{ lib, ... }:

{
  options.local.profile = {
    username = lib.mkOption {
      type = lib.types.str;
      default = "turb";
      description = "Primary local username.";
    };

    fullName = lib.mkOption {
      type = lib.types.str;
      default = "Ilya Naidanov";
      description = "Full name used for identity settings.";
    };

    email = lib.mkOption {
      type = lib.types.str;
      default = "turbcool@gmail.com";
      description = "Email used for identity settings.";
    };

    timezone = lib.mkOption {
      type = lib.types.str;
      default = "Asia/Yekaterinburg";
      description = "Default system timezone for hosts.";
    };

    locale = lib.mkOption {
      type = lib.types.str;
      default = "ru_RU.UTF-8";
      description = "Default locale for hosts and profiles.";
    };
  };
}
