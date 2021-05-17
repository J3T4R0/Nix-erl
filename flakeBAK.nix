{
  description = "Wx";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/master";

  outputs = { self, nixpkgs, flake-utils }@inputs:

    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system; 
          modules =
          [ ({ pkgs, ... }: {
                boot.isContainer = true;
    
                # Let 'nixos-version --json' know about the Git revision
                # of this flake.
                #system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;
                
                # Network configuration.
                networking.useDHCP = false;
                networking.firewall.allowedTCPPorts = [ 80 ];
                                    
                # Enable a web server.
                services.httpd = {
                  enable = true;
                  adminAddr = "morty@example.org";
                };
              })
            ];

          config = { allowUnfree = true; };
        };
      in
        {
          devShell = import ./shell.nix { inherit pkgs nixpkgs; };
        }
      );
#    nixosConfigurations.container = nixpkgs.lib.nixosSystem {
}
