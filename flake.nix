{
  description = "Infrastructure for the Swesbus ICT lab";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    nixpkgs,
    self,
    ...
  }: let
    lib = nixpkgs.lib;
    specialArgs = {inherit inputs self;};
    client-indices = lib.range 1 50;
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in {
    packages.x86_64-linux = {
      lab-manager-iso = self.nixosConfigurations.lab-manager.config.system.build.isoImage;
      lab-help = pkgs.callPackage ./packages/lab-help {labHelpSource = ./README.md;};
    };

    nixosModules = {
      remote = ./modules/remote;
      silentBoot = ./modules/silentBoot;
      zswap = ./modules/zswap;
    };

    homeModules.adminConfiguration = ./users/admin/configuration.nix;

    nixosConfigurations =
      {
        lab-manager = lib.nixosSystem {
          inherit specialArgs;
          modules = [./hosts/lab-manager/configuration.nix];
        };
      }
      // builtins.listToAttrs (map (index: let
        hostName = "lab-client-${toString index}";
        labModule = {remote.index = index;};
      in
        lib.nameValuePair hostName (lib.nixosSystem {
          inherit specialArgs;
          modules = [./hosts/lab-client/configuration.nix labModule];
        }))
      client-indices);
  };
}
