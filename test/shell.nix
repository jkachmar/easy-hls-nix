{ pkgs ? import <nixpkgs> { } }:
let
  easy-hls = pkgs.callPackage ../default.nix { };
  haskellDeps = pkgs.haskell.packages.ghc8104.ghcWithPackages
    (haskellPkgs: with haskellPkgs; [ aeson ]);
in

pkgs.mkShell
{
  buildInputs = with pkgs; [
    easy-hls
    cabal-install
    haskellDeps
  ];
}
