{
  config,
  inputs,
  pkgs,
  ...
}:

let
  profile = config.local.profile;
  inherit (profile) username;
in

{
  imports = [
    # Common modules
    ../common/pkgs/default.nix
    ../common/modules/default.nix

    # Your desktop system modules, reused as-is. hydenix/modules/system has no
    # dependency on the hydenix module — only features.nix (local.features) and
    # the modules below it — so it works under any desktop.
    ../hydenix/modules/system

    # Same physical machine as hydenix, so the same generated hardware config.
    # Copy this file into nixarchy/ when hydenix goes away.
    ../hydenix/hardware-configuration.nix
  ];

  local.profile = {
    username = "turb";
    fullName = "Ilya Naidanov";
    email = "turbcool@gmail.com";
    timezone = "Asia/Yekaterinburg";
    locale = "ru_RU.UTF-8";
  };

  local.features = {
    browsers.enable = true;
    gaming.enable = false;
    gaming.vr.enable = false;
    work.enable = true;
    work.syncthing.enable = false;
  };

  i18n.defaultLocale = profile.locale;

  users.users.${username} = {
    isNormalUser = true;
    initialPassword = "1";
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "docker"
    ];
    shell = pkgs.zsh;
  };

  age.identityPaths = [ "/home/${username}/.ssh/id_ed25519" ];

  time.timeZone = profile.timezone;

  networking.hostName = "nixarchy";

  programs.nixarchy = {
    enable = true;

    # Names the desktop user: adds them to the `input` group (game controllers,
    # dictation) and enables the omatheme runtime theme daemon. There is no way
    # for the module to infer it.
    user = username;

    # Your zsh config wins: starship, your aliases, proxy-toggle.
    shellIntegration = false;
    bashIntegration = false;

    # common/hm/opencode.nix HM-mkForces ~/.config/opencode/opencode.json on
    # every activation, so nixarchy's merge into that path would be reverted
    # anyway. The nixos MCP server is already registered per host.
    mcp = false;

    # agent-skills-nix already ships skills to ~/.config/opencode/skills.
    # nixSkills = false is nixarchy's default anyway, and the option only exists
    # from v4.0.4 — this input is pinned to the `release` branch.

    # Your own app selection (browsers/, work/) instead of Omarchy's nine.
    preinstalls = false;

    # Leave `defaultAgent` null: Omarchy's menu writes it at runtime, and
    # setting it would install a second `claude` next to the MCP-aware wrapper
    # in common/hm/cli.nix.
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users.${username} =
      { ... }:
      {
        imports = [
          inputs.agenix.homeManagerModules.default
          inputs.nixarchy.homeManagerModules.nixarchy
          ./modules/hm
        ];

        home.stateVersion = "25.05";

        # From hydenix/modules/hm/default.nix, minus the hydenix.hm.* block.
        home.packages = with pkgs; [
          telegram-desktop
        ];

        programs = {
          # Required for app selection, theme state and the seeded config.
          nixarchy.enable = true;
          mpv.enable = true;
          qutebrowser.enable = true;
        };
      };
  };

  system.stateVersion = "25.05";
}
