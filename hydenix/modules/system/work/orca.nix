# Orca desktop client (frontend only).
#
# Installs the Orca ADE frontend from the upstream AppImage. No local
# `orca serve` daemon or systemd service is enabled — nothing runs in the
# background. Point the client at a remote runtime from inside the app
# (SSH worktrees), with `orca serve` running on the remote host.
#
# To bump: check https://github.com/stablyai/orca/releases, update
# `version` + `hash` (prefetch with `nix-prefetch-url <AppImage url>` and
# convert with `nix hash convert --to sri <hash>`).
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.local.features.work;
  version = "1.4.197";
  src = pkgs.fetchurl {
    url = "https://github.com/stablyai/orca/releases/download/v${version}/orca-linux.AppImage";
    hash = "sha256-S8hGLRUf8BD6pUxka7FtzFR0v2ZO7V7FAoGC15kmQWs=";
  };
  appimageContents = pkgs.appimageTools.extractType2 {
    pname = "orca";
    inherit version src;
  };
  orca-frontend = pkgs.appimageTools.wrapType2 {
    pname = "orca";
    inherit version src;
    extraInstallCommands = ''
      install -Dm444 ${appimageContents}/orca-ide.desktop $out/share/applications/orca-ide.desktop
      substituteInPlace $out/share/applications/orca-ide.desktop \
        --replace-fail 'Exec=AppRun' "Exec=$out/bin/orca"
      mkdir -p $out/share/icons
      cp -r ${appimageContents}/usr/share/icons/hicolor $out/share/icons/
    '';
  };
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ orca-frontend ];
  };
}
