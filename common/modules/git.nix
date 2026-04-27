{ config, ... }:

let
  profile = config.local.profile;
in

{
  programs.git = {
    enable = true;
    config = {
      user = {
        name = profile.fullName;
        email = profile.email;
      };
      push = { autoSetupRemote = true; };
    };
  };
}
