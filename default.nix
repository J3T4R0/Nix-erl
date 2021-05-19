with builtins;
with lib;
self: super:
let
 
  fetchRebar3Deps = (import ./_support/fetch-rebar3-deps.nix);
  rebar3-13 = (import ./rebar3/rebar3-13.nix);
  rebar3-14 = (import ./rebar3/rebar3-14.nix);
  erlang-ls-0-13-0 = (import ./erlang-ls/erlang-ls-0.13.0.nix);
  erlang-24-0-1 = (import ./erlang/R24.nix);
  erlangLib = (import ./lib/imported-from-nixpkgs/development/beam-modules/lib.nix) self super;

  erlangManifest = builtins.fromJSON (builtins.readFile ./erlang-manifest.json);

  erlangReleases =
    builtins.map erlangManifestEntryToRelease erlangManifest;

  erlangManifestEntryToRelease = { version, rev, sha256 }@args:
    {
      name = "erlang-" + (builtins.replaceStrings ["."] ["-"] version);
      value = buildPackages args; 
    };

buildPackages = { version, rev, sha256 }:
    let
      majorVersion = super.lib.versions.major version;
      nixpkgs = builtins.fetchTarball {
            url = "https://github.com/J3T4R0/Nix-erl/archive/refs/tags/1.0.tar.gz";
            sha256 = "5b66ad663e097cabf89544ddfabb59c92b846788cdf3bc3935048c87c5dfe0c5";
      };
      sources = import ./erlang/R24.nix; 
      pkgs = import sources.nixpkgs {}; 

    in
      if majorVersion == "17" then
        # Unsupported, but seems to work
        rec {
          erlang = self.beam.interpreters.erlangR18.override { inherit version sha256; };
          rebar3 = self.beam.packages.erlang.rebar3.override { inherit erlang; };
        }
      else if majorVersion == "18" then
        rec {
          erlang = self.beam.interpreters.erlangR18.override { inherit version sha256; };
          rebar3 = self.beam.packages.erlang.rebar3.override { inherit erlang; };
        }
      else if majorVersion == "19" then
        rec {
          erlang = self.beam.interpreters.erlangR19.override { inherit version sha256; };
          rebar3 = self.beam.packages.erlang.rebar3.override { inherit erlang; };
        }
      else if majorVersion == "20" then
        rec {
          erlang = self.beam.interpreters.erlangR20.override { inherit version sha256; };
          rebar3 = self.beam.packages.erlang.rebar3.override { inherit erlang; };
        }
      else if majorVersion == "21" then
        rec {
          erlang = self.beam.interpreters.erlangR21.override { inherit version sha256; };
          rebar3 = self.beam.packages.erlang.rebar3.override { inherit erlang; };
        }
      else if majorVersion == "22" then
        let
          newScope = extra: super.lib.callPackageWith (super // extra);
        in
          super.lib.makeScope newScope (scope: {
            erlang = self.beam.interpreters.erlangR22.override { inherit version sha256; };

            rebar3 = scope.callPackage rebar3-14 {};

            erlang-ls = scope.callPackage erlang-ls-0-13-0 {};

            buildRebar3 = scope.callPackage ({erlang, rebar3}: self.beam.packages.erlang.buildRebar3.override {
              inherit erlang rebar3;
            }) {};

            fetchRebar3Deps = scope.callPackage fetchRebar3Deps {};
          })
      else if builtins.elem majorVersion ["23" "24"] then
        let
          newScope = extra: super.lib.callPackageWith (super // extra);
          # try to support old nixpkgs that don't have erlangR23
        in
          super.lib.makeScope newScope (scope: {
            _private.stdenv = callPackage ./my-stdenv.nix {};
            inherit version sha256;   

            rebar3 = newScope.callPackage rebar3-14 {};              
            erlang-ls = newScope.callPackage erlang-ls-0-13-0 {};                                                                               
            fetchRebar3Deps = newScope.callPackage fetchRebar3Deps {};  
            erlang = self.beam.interpreters.erlangR22.override { inherit version sha256; };

            buildRebar3 = newScope.callPackage ({erlang, rebar3}: self.beam.packages.erlang.buildRebar3.override {
                inherit erlang rebar3;
            }) {};   
            
            erlangChannel = makeScope newScope (self: with self; { 
              erlang = super.erlang.override { 
                wxSupport = false; 
              };

            mkShell = rec { 
              buildInputs = with pkgs; [  
                erlang
                rebar3 
                erlang-ls
              ]; 
            };
          });
          })
      else
        throw ("nixerl does not currently have support for Erlang with major version: " + majorVersion);

in
  {
    nixerl = (super.nixerl or {}) // (builtins.listToAttrs erlangReleases);
  }
