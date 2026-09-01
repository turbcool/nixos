{ ... }:

# nix-ld provides a compatible dynamic linker for binaries that were built for
# a generic Linux (glibc) layout — needed to run npm-installed MCP tools
# (bladebro, donsetch) which ship prebuilt glibc ELF binaries.

{
  programs.nix-ld.enable = true;
}