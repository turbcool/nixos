{ config, lib, ... }:

let
  username = config.local.profile.username;
in
{
  age.secrets = {
    gitlab-neoplatform-token = {
      file = ../secrets/gitlab-neoplatform-token.age;
      owner = username;
      mode = "0400";
    };
    gitlab-skyori-token = {
      file = ../secrets/gitlab-skyori-token.age;
      owner = username;
      mode = "0400";
    };
  };
}
