{ installShellFiles
, stdenv
  # Arguments from `easy-hls-nix` derivation entrypoint.
, hlsBins
, pname
, version
, src
, meta
}:

stdenv.mkDerivation {
  inherit pname version src meta;
  nativeBuildInputs = [ installShellFiles ];
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
