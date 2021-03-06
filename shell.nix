with (import <nixpkgs> {}).pkgs;
let
  nixpkgs = builtins.fetchGit {
      url = "https://github.com/J3T4R0/Nix-erl";
    #  sha256 = "12wc9kh6qpa56zd0hb6api4n0v52vgggba3j5x9n2n1sck67hhmc";
  };                                 
  erlang = import ./NixOS/pkgs/development/interpreters/erlang/R24.nix; 
  #erlang = import erlang_source.nixpkgs {};

  #erlang = NixOS.pkgs.development.interpreters.erlang.R24;

   buildElixir = pkgs.callPackage (import "${nixpkgs}/NixOS/pkgs/development/interpreters/elixir/generic-builder.nix") { erlang = erlang; };
   elixir = buildElixir {
      version = "1.12.0-rc.1";
      minimumOTPVersion = "24";
      sha256 = "05kp3n2mh603ajqpkkanxxw8n101x7xck6c2jyi9b3f3g4jkssnl";
    }; 

    inherit (pkgs.lib) optional optionals;

in pkgs.mkShell rec {  
  name = "elixir-1.12.0-rc.1_dev_env";  
  buildInputs = with pkgs; [
    rebar
    rebar3
    erlang
    elixir
   ] ++ optional stdenv.isLinux inotify-tools ++ optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [ CoreFoundation CoreServices ]);
}
