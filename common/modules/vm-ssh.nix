{ config, lib, ... }:

let
  cfg = config.local.vm-ssh;
  username = config.local.profile.username;
in
{
  options.local.vm-ssh.enable = (lib.mkEnableOption "VM SSH password secrets") // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
    age.secrets = {
      vm-ai-neoplatform = {
        file = ../secrets/vm-ai-neoplatform.age;
        owner = username;
        mode = "0400";
      };
      vm-ai-skyori = {
        file = ../secrets/vm-ai-skyori.age;
        owner = username;
        mode = "0400";
      };
      vm-ai-proinfoservice = {
        file = ../secrets/vm-ai-proinfoservice.age;
        owner = username;
        mode = "0400";
      };
      vm-ai-timepath = {
        file = ../secrets/vm-ai-timepath.age;
        owner = username;
        mode = "0400";
      };
    };
  };
}
