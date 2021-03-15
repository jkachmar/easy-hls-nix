{ buildFHSUserEnv
, installShellFiles
, lib
, stdenv
, writeShellScriptBin
  # Arguments from `easy-hls-nix` derivation entrypoint.
, hlsBins
, src
, pname
, version
, meta
}:
let
  inherit (stdenv) mkDerivation isLinux;
  name = "${pname}-${version}";

  #############################################################################
  # HLS Binary Installation.
  #############################################################################

  # Derivation containing the extracted Haskell Language Server Binaries.
  installation = mkDerivation {
    name = "${name}-installer";
    inherit src;

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
  installationBinDir = "${installation}/bin";

  #############################################################################
  # FHS Entrypoint, Wrapper Script, and User Environment
  #############################################################################

  # FHS wrapper environments can only call one executable, so we construct an
  # entrypoint script to forward calls to the final installed executables.
  entrypointScriptDrv = writeShellScriptBin "${name}-entrypoint" ''
    set -o errexit -o pipefail -o nounset
    prog_name=$1
    shift
    exec "${installationBinDir}/$prog_name" "$@"
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
  inherit pname version meta;

  phases = "buildPhase";
  buildPhase = ''
    runHook preBuild

    mkdir -p $out/bin

    for name in $(ls ${installationBinDir}); do
      ln -s ${frontendScript} $out/bin/$name
    done

    runHook postBuild
  '';
}
