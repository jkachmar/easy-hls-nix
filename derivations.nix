{ callPackage
, fetchzip
, lib
, stdenv
  # Optional override for the HLS binaries to support specific GHC versions.
, ghcVersions ? [
    "8.6.5"
    "8.8.3"
    "8.8.4"
    "8.10.5"
    "8.10.6"
    "8.10.7"
    "9.0.1"
  ]
}:
let
  inherit (stdenv) isDarwin isLinux;
  hlsBins = [ "wrapper" ] ++ ghcVersions;

  #############################################################################
  # Derivation attributes & metadata shared across platforms.
  #############################################################################

  pname = "haskell-language-server";
  version = "1.5.1";
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

in
rec {
  #############################################################################
  # Platform-Specific Derivations
  #############################################################################
  nixosSrc = fetchzip {
    url = "https://github.com/haskell/haskell-language-server/releases/download/${version}/haskell-language-server-Linux-${version}.tar.gz";
    sha256 = "sha256-iUm49WDkoXstHJLq9ON0gh2P4uHu4jiKzRJmxf+LPjw=";
    stripRoot = false;
  };

  nixosDrv = callPackage ./nixos {
    inherit hlsBins pname version meta;
    src = nixosSrc;
  };

  macosSrc = fetchzip {
    url = "https://github.com/haskell/haskell-language-server/releases/download/${version}/haskell-language-server-macOS-${version}.tar.gz";
    sha256 = "sha256-HKy66VmaKy5kt7MquyuJNIAPHtk1Ls1UnzQMCeaHtak=";
    stripRoot = false;
  };

  macosDrv = callPackage ./macos {
    inherit hlsBins pname version meta;
    src = macosSrc;
  };
}
