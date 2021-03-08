# Easy Haskell Language Server Nix

Easy Haskell Language Server tooling with Nix!

## Example Usage

### Quickstart

The quickest way to start using this project is to import the derivation
directly from this GitHub project and load up all versions of the Haskell
Language Server in a `shell.nix` file.

**NOTE:** This README may be out of date, and the `rev` and `sha256` provided
below might not be the latest version!

Remember to check the latest revision and update it if necessary, substituting
the `sha256` value with `pkgs.lib.fakeSha256` to get the latest SHA256 hash.

```nix
{ pkgs ? import <nixpkgs> { } }:
let
  inherit (pkgs) callPackage fetchFromGitHub mkShell;
  easy-hls-src = fetchFromGitHub {
    owner  = "jkachmar";
    repo   = "easy-hls-nix";
    rev    = "b0ceb9277963eb39a8bb279f187e38b36d7d63db";
    sha256 = "1UD7GIHLZyJueRMPpUiV1SoeBEwFyz6tgCRijDvfWkU=";
  };
  easy-hls = callPackage easy-hls-src {};
in

mkShell {
  buildInputs = [ easy-hls ];
}
```

### Explicitly Selecting GHC Versions

This project includes _all_ of the binaries associated with a particular
version of the Haskell Language Server.

While this can be convenient for a global installation (e.g. with `nix-env` or
`nix profile`), some projects may only need to support a single version of GHC
and the maintainer may not want to carry around any unnecessary dependencies.

In that case, the supported GHC versions can be overridden by explicitly
supplying a `ghcVersions` argument, as follows:

```
# ...see the Quickstart example above for details...
easy-hls = callPackage easy-hls-src {
  ghcVersions = [ "8.8.4" ];
};
```

This will provide the `haskell-language-server-wrapper` and
`haskell-language-server-8.8.4` binaries **and no others**.

### Flakes (Advanced)

This project supports Nix Flakes!

Contributors familiar with Nix Flakes are welcome to use it directly (via
`nix profile` or their own `flake.nix` file) and invited to contribute
user-friendly documentation if they find Flakes support to be particularly
helpful.

#### One poissble way
add `easy-hls-nix` as your flake input

``` nix
inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-20.09";
    easy-hls.url = "github:yuanw/easy-hls-nix/overlay";
    easy-hls.inputs.nixpkgs.follows = "nixpkgs";
  };
```

add `haskell-language-server` in your flake (or one of the) overlay,and import overlay into our instance of nixpkgs. 

``` nix
  let
      overlay = final: prev: {
        hls = (final.callPackage easy-hls { });
      };
    in {
     inherit overlay;
    }  } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            overlay
          ];
        };
```
and add `pkgs.hls` in your devshell

you can do `which  haskell-language-server-wrapper` to verify `haskell-language-server` is in your devshell path

Here is a full [https://github.com/yuanw/blog/blob/e806c005e634a1cb81caffaef2294351c2531f47/flake.nix](example) using `easy-hls-nix` with Nix Flakes
