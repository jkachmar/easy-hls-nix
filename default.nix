{ callPackage, stdenv }:

let
  derivations = callPackage ./derivations.nix {};
in

# Select between macOS and NixOS derivations based on the environment.
if (stdenv.isDarwin)
then derivations.macosDrv
else derivations.nixosDrv
