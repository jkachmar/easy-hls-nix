{
  description = "Easy Haskell Language Server tooling for Nix.";

  # Pin unstable 'nixpkgs' by default.
  inputs.nixpkgs.url = "github:nixos/nixpkgs";

  outputs = { self, nixpkgs }:
   let
      # Generate a user-friendly version number.
      version = builtins.substring 0 8 self.lastModifiedDate;
      # System types to support.
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" ];
      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [ self.overlay ]; });
  in
  {
    overlay = final: prev: {};
    defaultPackage = forAllSystems (system:
      nixpkgsFor."${system}".callPackage ./default.nix { });
    defaultApp = forAllSystems (system: {
      type = "app";
      program = "${self.defaultPackage.${system}}/bin/haskell-language-server-wrapper";
    });
    devShell = forAllSystems (system: import ./shell.nix {
      pkgs = nixpkgsFor."${system}";
    });
    withGhcs = ghcVersions: forAllSystems (system:
      self.defaultPackage."${system}".overrideAttrs (old: {
        inherit ghcVersions;
      }));
  };
}
