{
  description = "Flake utils demo";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/master";
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in
      rec {
        packages = flake-utils.lib.flattenTree {
          erlangR24 = ./shell.nix; 
        };
        defaultPackage = packages.erlangR24;
        apps.erlangR24 = flake-utils.lib.mkApp { drv = packages.erlangR24; };
        defaultApp = apps.erlangR24.app;
      }
    );
}
