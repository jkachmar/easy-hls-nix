{ pkgs ? import <nixpkgs> { } }:
let
  easy-hls = pkgs.callPackage ../default.nix { };
in

pkgs.mkShell {
  buildInputs = with pkgs; [
    easy-hls
    cabal-install
    haskell.compiler.ghc884
  ];
}
