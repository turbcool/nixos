
{ 
  lib,
  pkgs,
  config,
  ...
}:

{
  services.activitywatch = {
    enable = true;
  };
}
