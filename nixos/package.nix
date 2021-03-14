{ buildFHSUserEnv
, fetchzip
, installShellFiles
, lib
, lr
, stdenv
, writeShellScriptBin
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
  inherit (stdenv) mkDerivation isDarwin isLinux;
  hlsBins = [ "wrapper" ] ++ ghcVersions;

  #############################################################################
  # HLS Package Metadata.
  #############################################################################

  pname = "haskell-language-server";
  version = "1.0.0";
  name = "${pname}-${version}";

  #############################################################################
  # HLS Binary Installation.
  #############################################################################

  srcForNixOS = fetchzip {
    url = "https://github.com/haskell/haskell-language-server/releases/download/${version}/haskell-language-server-Linux-${version}.tar.gz";
    sha256 = "oncBl94KOFjsg22mgxucAxa4T5Hq1SjmsGQ3yXXidjI=";
    stripRoot = false;
  };

  # Derivation containing the extracted Haskell Language Server Binaries.
  extraction = mkDerivation {
    name = "${name}-installer";
    src = srcForNixOS;

    # HLS Linux executables are statically linked, and therefore canot be patched
    # on Linux.
    dontPatchELF = isLinux;
    # Don't attempt to examine RPATHs on Linux; this causes spurious `patchelf`
    # errors.
    #
    # cf. https://github.com/NixOS/nixpkgs/blob/c277a508fceb086eb4e71682957d731447d08b74/pkgs/build-support/setup-hooks/audit-tmpdir.sh#L23
    noAuditTmpdir = isLinux;

    # Install each of the HLS binaries at the appropriate out paths.
    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin
      ${lib.concatMapStringsSep "\n"
        (hlsBin: ''
          binPath="$out/bin/haskell-language-server-${hlsBin}"
          install -D -m555 -T "haskell-language-server-${hlsBin}" "$binPath"
          rm "haskell-language-server-${hlsBin}"
        '')
      hlsBins}

      runHook postInstall
    '';
  };
  extractionBinDir = "${extraction}/bin";

  #############################################################################
  # FHS Entrypoint, Wrapper Script, and User Environment
  #############################################################################

  # FHS wrapper environments can only call one executable, so we construct an
  # entrypoint script to forward calls to the final installed executables.
  entrypointScriptDrv = writeShellScriptBin "${name}-entrypoint" ''
    set -o errexit -o pipefail -o nounset
    prog_name=$1
    shift
    exec "${extractionBinDir}/$prog_name" "$@"
  '';
  entrypointScript = "${entrypointScriptDrv}/bin/${entrypointScriptDrv.name}";

  hlsWrapperContents = mkDerivation {
    name = "${name}-wrapper-contents";
    phases = "buildPhase";
    buildPhase = ''
      runHook preBuild

      mkdir -p $out/bin
      ln -s ${entrypointScript} $out/bin/entrypoint

      runHook postbuild
    '';
  };
  hlsWrapper = buildFHSUserEnv {
    name = "${name}-wrapper";
    targetPkgs = _: [ hlsWrapperContents ];
    multiPkgs = pkgs: [ pkgs.glibc ];
    runScript = "entrypoint";
  };

  #############################################################################
  # "Frontend" Script to Call HLS from the FHS User Environment.
  #############################################################################

  frontendScriptDrv = writeShellScriptBin "${name}-frontend" ''
    set -o errexit -o pipefail -o nounset
    prog_name=$(basename $0)
    exec ${hlsWrapper}/bin/${hlsWrapper.name} $prog_name "$@"
  ''; 
  frontendScript = "${frontendScriptDrv}/bin/${frontendScriptDrv.name}";

in
mkDerivation {
  inherit pname version;

  phases = "buildPhase";
  buildPhase = ''
    runHook preBuild

    mkdir -p $out/bin

    for name in $(ls ${extractionBinDir}); do
      ln -s ${frontendScript} $out/bin/$name
    done

    runHook postBuild
  '';

  meta = with stdenv.lib; {
    description = ''
      A language server that provides information about Haskell programs to
      IDEs, editors, and other tools.
    '';
    homepage = "https://github.com/haskell/haskell-language-server";
    license = licenses.asl20; # Apache-2.0 license.
    maintainers = [ ];

    # TODO: Fill out x86_64 Linux and x86_64 macOS information.
    # platforms = platforms.linux;
  };
}
