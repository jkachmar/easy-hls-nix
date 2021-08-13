{ pkgs ? import <nixpkgs> { } }:
let
  easy-hls =
      if pkgs.isDarwin
      then (pkgs.callPackage ./default.nix { }).macosDrv
      else (pkgs.callPackage ./default.nix { }).nixosDrv;

in

pkgs.mkShell {
  buildInputs = [
    easy-hls
  ];
}
