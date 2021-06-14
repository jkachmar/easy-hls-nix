{ callPackage
, fetchzip
, lib
, stdenv
  # Optional override for the HLS binaries to support specific GHC versions.
, ghcVersions ? [
    "8.6.4"
    "8.6.5"
    "8.8.2"
    "8.8.3"
    "8.8.4"
    "8.10.2"
    "8.10.3"
    "8.10.4"
  ]
}:
let
  inherit (stdenv) isDarwin isLinux;
  hlsBins = [ "wrapper" ] ++ ghcVersions;

  #############################################################################
  # Derivation attributes & metadata shared across platforms.
  #############################################################################

  pname = "haskell-language-server";
  version = "1.2.0";
  meta = {
    description = ''
      A language server that provides information about Haskell programs to
      IDEs, editors, and other tools.
    '';
    homepage = "https://github.com/haskell/haskell-language-server";
    license = lib.licenses.asl20; # Apache-2.0 license.
    maintainers = [ ];

    platforms = [ "x86_64-darwin" "x86_64-linux" ];
  };

  #############################################################################
  # Platform-Specific Derivations
  #############################################################################

  macosDrv = callPackage ./macos {
    inherit hlsBins pname version meta;
    src = fetchzip {
      url = "https://github.com/haskell/haskell-language-server/releases/download/${version}/haskell-language-server-macOS-${version}.tar.gz";
      sha256 = "NmIH9FDZeefVKbGSYLcKg8bKsRzKCA0esU8qI/27SQ0=";
      stripRoot = false;
    };
  };

  nixosDrv = callPackage ./nixos {
    inherit hlsBins pname version meta;
    src = fetchzip {
      url = "https://github.com/haskell/haskell-language-server/releases/download/${version}/haskell-language-server-Linux-${version}.tar.gz";
      sha256 = "k9IPYrH39Iz4DlgMJgFHBDNiyZicu8lM2rrktzxTWEo=";
      stripRoot = false;
    };
  };
in

if isDarwin
then macosDrv
else nixosDrv
