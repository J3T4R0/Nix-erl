{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/master";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.erlangR24 {
      inherit self nixpkgs;
      let 
        pkgs = import nixpkgs {
          config = { allowUnfree = true; };
      };
      in {
        devShell.x86_64-linux = ./shell.nix; };
      };
    };
}
