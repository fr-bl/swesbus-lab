{
  description = "Infrastructure for the Swesbus ICT lab";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;}
    ({self, ...}: {
      systems = ["x86_64-linux"];

      perSystem = {
        lib,
        self',
        system,
        ...
      }: let
        specialArgs = {inherit inputs self;};
        client-indices = lib.range 1 50;
      in {
        packages.lab-manager-iso = self'.legacyPackages.nixosConfigurations.lab-manager.config.system.build.isoImage;

        legacyPackages.nixosConfigurations =
          {
            lab-manager = lib.nixosSystem {
              inherit system specialArgs;
              modules = [./hosts/lab-manager/configuration.nix];
            };
          }
          // builtins.listToAttrs (map (client-index: let
            hostName = "lab-client-${toString client-index}";
            labModule = {lab.client.index = client-index;};
          in
            lib.nameValuePair hostName (lib.nixosSystem {
              inherit system specialArgs;
              modules = [./hosts/lab-client/configuration.nix labModule];
            }))
          client-indices);
      };
    });
}
