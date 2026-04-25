{ inputs, nixpkgs }:
{
  modules,
  system ? "x86_64-linux",
  specialArgs ? { },
}:
nixpkgs.lib.nixosSystem {
  inherit modules system;
  specialArgs = { inherit inputs; } // specialArgs;
}
