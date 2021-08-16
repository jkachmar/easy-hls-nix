{ callPackage
, lib
, stdenv
  # If not provided, we will defer to the argument list in './derivations.nix'.
, ghcVersions ? null
}:

let
  inherit (lib.attrsets) optionalAttrs;
  derivations = callPackage ./derivations.nix (optionalAttrs (ghcVersions != null) {
    inherit ghcVersions;
  });
in

# Select between macOS and NixOS derivations based on the environment.
if (stdenv.isDarwin)
then derivations.macosDrv
else derivations.nixosDrv
