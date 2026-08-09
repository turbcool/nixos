# Helium extensions installed as external extensions (local CRX files).
#
# uBlock Origin is NOT listed here - Helium bundles it as a built-in component.
# Bitwarden and Passbolt are the user's remaining Firefox extensions, pulled
# from the Chrome Web Store as signed CRX files and force-installed via the
# standard Chromium "External Extensions" mechanism (no store server needed).
#
# When a CRX version bumps on the Chrome Web Store, update BOTH the version
# below and the hash (re-prefetch via):
#   nix-prefetch-url "https://clients2.google.com/service/update2/crx?response=redirect&prodversion=127.0.0.0&acceptformat=crx3&x=id%3D<ID>%26installsource%3Dondemand%26uc"
{
  config,
  pkgs,
  lib,
  ...
}:

let
  ext =
    id: sha256:
    pkgs.fetchurl {
      url = "https://clients2.google.com/service/update2/crx?response=redirect&prodversion=127.0.0.0&acceptformat=crx3&x=id%3D${id}%26installsource%3Dondemand%26uc";
      sha256 = sha256;
    };

  extensions = [
    {
      id = "nngceckbapebfimnlniiiahkandclblb"; # Bitwarden
      version = "2026.7.0";
      crx = ext "nngceckbapebfimnlniiiahkandclblb" "sha256-PwXLkgGS9YjvBRUHgwiEtqiXkXmWngv3xA4Boqj9f74=";
    }
    {
      id = "didegimhafipceonhjepacocaffmoppf"; # Passbolt
      version = "5.14.3";
      crx = ext "didegimhafipceonhjepacocaffmoppf" "sha256-aR51q5ee+ZVJtuHFk1UnJoqoybDwrmPr1AXJblKjWiA=";
    }
  ];
in
{
  home.file = lib.listToAttrs (
    map (e: {
      name = "${config.xdg.configHome}/net.imput.helium/External Extensions/${e.id}.json";
      value.text = builtins.toJSON {
        external_crx = e.crx;
        external_version = e.version;
      };
    }) extensions
  );
}
