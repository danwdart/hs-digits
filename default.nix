{
  nixpkgs ? import <nixpkgs> {},
  compiler ? "ghc94",
  haskell-tools ? import (builtins.fetchTarball "https://github.com/danwdart/haskell-tools/archive/master.tar.gz") {
    nixpkgs = nixpkgs;
    compiler = compiler;
  }
}:
let
  gitignore = nixpkgs.nix-gitignore.gitignoreSourcePure [ ./.gitignore ];
  haskell = nixpkgs.pkgs.haskell;
  haskellPackages = haskell.packages;
  lib = haskell.lib;
  tools = haskell-tools compiler;
  myHaskellPackages = haskellPackages.${compiler}.override {
    overrides = self: super: rec {
      digits = lib.dontHaddock (self.callCabal2nix "digits" (gitignore ./.) {});
    };
  };
  shell = myHaskellPackages.shellFor {
    packages = p: [
      p.digits
    ];
    buildInputs = tools.defaultBuildTools;
    withHoogle = false;
  };
  exe = lib.justStaticExecutables (myHaskellPackages.digits);
in
{
  inherit shell;
  digits = lib.justStaticExecutables (myHaskellPackages.digits);
}
