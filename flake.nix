{
  description = "Easy Haskell Language Server tooling for Nix.";

  # Pin unstable 'nixpkgs' by default.
  inputs.nixpkgs.url = "github:nixos/nixpkgs";

  outputs = { self, nixpkgs }: {
    defaultPackage.x86_64-linux =
      let pkgs = import nixpkgs { system = "x86_64-linux"; };
      in (pkgs.callPackage ./derivations.nix { }).nixosDrv;
    defaultApp.x86_64-linux = {
      type = "app";
      program = "${self.defaultPackage.x86_64-linux}/bin/haskell-language-server-wrapper";
    };
    devShell.x86_64-linux = import ./shell.nix {
      pkgs = import nixpkgs { system = "x86_64-linux"; };
    };

    defaultPackage.x86_64-darwin =
      let pkgs = import nixpkgs { system = "x86_64-darwin"; };
      in (pkgs.callPackage ./derivations.nix { }).macosDrv;
    defaultApp.x86_64-darwin = {
      type = "app";
      program = "${self.defaultPackage.x86_64-darwin}/bin/haskell-language-server-wrapper";
    };
    devShell.x86_64-darwin = import ./shell.nix {
      pkgs = import nixpkgs { system = "x86_64-darwin"; };
    };
  };
}
