{
  description = "Easy Haskell Language Server tooling for Nix.";

  # Pin unstable 'nixpkgs' by default.
  inputs.nixpkgs.url = "github:nixos/nixpkgs";

  outputs = { self, nixpkgs }: {
    defaultPackage.x86_64-linux =
      let pkgs = import nixpkgs { system = "x86_64-linux"; };
      in pkgs.callPackage ./default.nix { };
    devShell.x86_64-linux = import ./shell.nix {
      pkgs = import nixpkgs { system = "x86_64-linux"; };
    };

    defaultPackage.x86_64-darwin =
      let pkgs = import nixpkgs { system = "x86_64-darwin"; };
      in pkgs.callPackage ./default.nix { };
    devShell.x86_64-darwin = import ./shell.nix {
      pkgs = import nixpkgs { system = "x86_64-darwin"; };
    };
  };
}
