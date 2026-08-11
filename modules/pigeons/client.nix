{ pkgs, ... }:
{
  home.packages = [
    (pkgs.callPackage ../../packages/pigeons.nix { })
  ];
}
