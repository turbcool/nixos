{ config, ... }:

{
  services.getty.autologinUser = config.local.profile.username;
}
