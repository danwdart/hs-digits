{
  nixpkgs ? import <nixpkgs> {},
  compiler ? "ghc910",
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
    shellHook = ''
      gen-hie > hie.yaml
      for i in $(find -type f | grep -v dist-newstyle); do krank $i; done
    '';
    buildInputs = tools.defaultBuildTools;
    withHoogle = false;
  };
  exe = lib.justStaticExecutables (myHaskellPackages.digits);
in
{
  inherit shell;
  digits = lib.justStaticExecutables (myHaskellPackages.digits);
}
