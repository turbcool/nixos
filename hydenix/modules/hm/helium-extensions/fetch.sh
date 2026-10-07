#!/usr/bin/env bash
# Fetch a Chrome Web Store extension into the vendored slot so
# helium.nix can install it without touching the network at build time.
#
#   ./fetch.sh nngceckbapebfimnlniiiahkandclblb      # -> bitwarden note below
#
# Prints the CRX version to paste into helium.nix's `version` field.
# Needs network access to clients2.google.com; on hosts where CWS answers
# 204/empty, download the CRX elsewhere (e.g. a browser "download extension",
# or from a machine with CWS access) and drop it in as <id>.crx.
set -euo pipefail

id=${1:?usage: fetch.sh <extension-id>}
dir=$(cd -- "$(dirname -- "$0")" && pwd)
out=$dir/$id.crx
url="https://clients2.google.com/service/update2/crx?response=redirect&prodversion=127.0.0.0&acceptformat=crx3&x=id%3D${id}%26installsource%3Dondemand%26uc"

curl -fsSL --retry 3 --retry-delay 2 -o "$out" "$url"

if ! head -c 4 "$out" | grep -q Cr24; then
  rm -f "$out"
  echo "error: CWS returned no CRX for $id (got $(stat -c%s "$out" 2>/dev/null || echo 0) bytes, or a 204)" >&2
  exit 1
fi

version=$(python3 -c "import json,sys,zipfile;print(json.loads(zipfile.ZipFile(sys.argv[1]).read('manifest.json'))['version'])" "$out")
echo "wrote $out ($(stat -c%s "$out") bytes)"
echo "set version = \"$version\" in $(dirname "$dir")/helium.nix for id $id"