# Helium extensions installed as external extensions (local CRX files).
#
# uBlock Origin is NOT listed here - Helium bundles it as a built-in component.
# Bitwarden and Passbolt are the user's remaining Firefox extensions, installed
# as signed CRX files through the standard Chromium "External Extensions"
# mechanism (no store server needed).
#
# The CRX files are *vendored*: `./helium-extensions/<id>.crx`. A literal path
# is copied into the store by content hash, so a build never touches the
# network and there is no sha256 to bump. The Chrome Web Store cannot be used as
# a build input - clients2.google.com answers 204/empty for every
# /service/update2/crx request, so `fetchurl` produced a 0-byte file and a
# hash-mismatch build failure.
#
# To add or update an extension:
#   1. hydenix/modules/hm/helium-extensions/fetch.sh <id>   (needs CWS access)
#   2. bump `version` below to what fetch.sh printed
#
# An extension with no vendored file is skipped, with a warning on stderr, so a
# missing CRX cannot break the whole system build.
{
  config,
  lib,
  ...
}:

let
  vendored =
    id: version:
    let
      file = ./helium-extensions + "/${id}.crx";
    in
    {
      inherit id version;
      crx = if builtins.pathExists file then file else null;
    };

  wanted = [
    {
      id = "nngceckbapebfimnlniiiahkandclblb"; # Bitwarden
      version = "2026.7.0";
    }
    {
      id = "didegimhafipceonhjepacocaffmoppf"; # Passbolt
      version = "5.14.3";
    }
  ];

  resolved = map (e: vendored e.id e.version) wanted;
  installed = lib.filter (e: e.crx != null) resolved;
  missing = map (e: e.id) (lib.filter (e: e.crx == null) resolved);
in
{
  home.file = lib.listToAttrs (
    map (e: {
      name = "${config.xdg.configHome}/net.imput.helium/External Extensions/${e.id}.json";
      value.text = builtins.toJSON {
        external_crx = e.crx;
        external_version = e.version;
      };
    }) installed
  );

  # Loud, once, and impossible to miss in a rebuild log.
  warnings = lib.optionals (missing != [ ]) [
    "Helium extension CRX not vendored for: ${lib.concatStringsSep ", " missing}. These extensions are NOT installed. Run hydenix/modules/hm/helium-extensions/fetch.sh <id> to add them."
  ];
}
