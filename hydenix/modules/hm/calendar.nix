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
    enable = true;
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
    enable = true;
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

  systemd.user.timers.vdirsyncer-sync = {
    description = "Periodic vdirsyncer sync";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*:0/5"; # Sync every 5 minutes
      Persistent = true;
    };
    serviceConfig = {
      ExecStart = "${pkgs.vdirsyncer}/bin/vdirsyncer sync";
    };
  };
}
