{ config, pkgs, ... }:

let
  radicaleUrl = "https://cal.naidanov.ru";
  username = "turbcool";
  passwordCommand = ["cat" "/home/turb/.radicale-pass"];
  # ["pass" "show" "radicale/password"];
in
{
  programs.khal = {
    enable = true;
  };

  programs.khard = {
    enable = true;
  };

  programs.vdirsyncer = {
    enable = true;
    statusPath = "${config.home.homeDirectory}/.cache/vdirsyncer/status/";
  };

  services.vdirsyncer = {
    enable = true;
    frequency = "*:0/10";
  };

  accounts.calendar.accounts.personal = {
    primary = true;
    remote = {
      type = "caldav";
      url = radicaleUrl;
      userName = username;
      passwordCommand = passwordCommand;
    };
    local = {
      type = "filesystem";
      path = "${config.home.homeDirectory}/.calendar";
      fileExt = ".ics";
    };
    vdirsyncer = {
      enable = true;
      collections = ["from a" "from b"]; # sync both sides (local + remote)
      metadata = ["color"];
    };
    khal = {
      enable = true;
      type = "discover";
    };
    primaryCollection = "notify"; # без этого khal не находит календарь
  };

  accounts.contact.accounts.contacts = {
    remote = {
      type = "carddav";
      url = radicaleUrl;
      userName = username;
      passwordCommand = passwordCommand;
    };
    local = {
      type = "filesystem";
      path = "${config.home.homeDirectory}/.contacts";
      fileExt = ".vcf";
    };
    vdirsyncer = {
      enable = true;
      collections = [
        "from a"
        "from b"
      ];
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
