Vendored Chrome Web Store CRX files, one per extension id, referenced as literal
paths by ../helium.nix. Nix copies each into the store by content hash, so builds
never fetch from the network.

The files themselves are NOT in git (binary blobs). Populate them with:
  ./fetch.sh <extension-id>

then bump the matching version in ../helium.nix. See ../helium.nix for why the
Chrome Web Store is not used as a build input.
