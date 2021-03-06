{ pkgs ? import <nixpkgs> { } }:
let
  easy-hls = pkgs.callPackage ./default.nix { };
in

pkgs.mkShell {
  buildInputs = [
    easy-hls
  ];
}
