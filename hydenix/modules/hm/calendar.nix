{ config, pkgs, ... }:

let
  radicaleUrl = "https://cal.naidanov.ru";
  username = "turbcool";
  passwordCommand = ["cat" "/home/turb/.radicale-pass"];
  # ["pass" "show" "radicale/password"];
in
{
  home.packages = with pkgs; [
    vdirsyncer
    khal
    khard
    neomutt
  ];

  accounts.calendar.accounts.personal = {
    primary = true;
    remote = {
      type = "caldav";
      url = radicaleUrl;
      username = username;
      passwordCommand = passwordCommand;
    };
    local = {
      type = "filesystem";
      path = "${config.home.homeDirectory}/.calendar";
      fileExt = ".ics";
    };
    vdirsyncer = {
      enable = true;
    };
    khal = {
      enable = true;
      color = "light green";
    };
  };

  accounts.contact.accounts.contacts = {
    remote = {
      type = "carddav";
      url = radicaleUrl;
      username = username;
      passwordCommand = passwordCommand;
    };
    local = {
      type = "filesystem";
      path = "${config.home.homeDirectory}/.contacts";
      fileExt = ".vcf";
    };
    vdirsyncer = {
      enable = true;
    };
    khard = {
      enable = true;
    };
  };

  programs.neomutt = {
    enable = true;
    extraConfig = ''
      set query_command = "khard email --parsable %s"
    '';
  };
}
