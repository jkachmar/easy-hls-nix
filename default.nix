{ fetchzip
, installShellFiles
, lib
, lr
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
  inherit (stdenv) mkDerivation isDarwin;
  hlsBins = [ "wrapper" ] ++ ghcVersions;
in
mkDerivation rec {
  pname = "haskell-language-server";
  version = "1.0.0";
  src =
    if stdenv.isDarwin
    then
      fetchzip
        {
          url = "https://github.com/haskell/haskell-language-server/releases/download/${version}/haskell-language-server-macOS-${version}.tar.gz";
          sha256 = "PXv8k7GebeHHsqOlgju2NIrubApg8JK8OpRNDevTqqU=";
          stripRoot = false;
        }
    else
      fetchzip
        {
          url = "https://github.com/haskell/haskell-language-server/releases/download/${version}/haskell-language-server-Linux-${version}.tar.gz";
          sha256 = "oncBl94KOFjsg22mgxucAxa4T5Hq1SjmsGQ3yXXidjI=";
          stripRoot = false;
        };

  nativeBuildInputs = [ installShellFiles ];

  # NOTE: Copied from https://github.com/justinwoo/easy-dhall-nix/blob/master/build.nix
  installPhase = ''
      mkdir -p $out/bin
    
      ${lib.concatMapStringsSep "\n"
        (hlsBin: ''
          binPath="$out/bin/haskell-language-server-${hlsBin}"
          # Install HLS
          install -D -m555 -T "haskell-language-server-${hlsBin}" "$binPath"
          rm "haskell-language-server-${hlsBin}"
      
          # Install bash completions.
          "$binPath" --bash-completion-script "$binPath" > "haskell-language-server-${hlsBin}.bash"
          installShellCompletion --bash "haskell-language-server-${hlsBin}.bash"
          rm "haskell-language-server-${hlsBin}.bash"
      
          # Install zsh completions.
          "$binPath" --zsh-completion-script "$binPath" > "haskell-language-server-${hlsBin}.zsh"
          installShellCompletion --zsh "haskell-language-server-${hlsBin}.zsh"
          rm "haskell-language-server-${hlsBin}.zsh"
      
          # Install fish completions.
          "$binPath" --fish-completion-script "$binPath" > "haskell-language-server-${hlsBin}.fish"
          installShellCompletion --fish "haskell-language-server-${hlsBin}.fish"
          rm "haskell-language-server-${hlsBin}.fish"
        '')
    hlsBins}
  '';
}
