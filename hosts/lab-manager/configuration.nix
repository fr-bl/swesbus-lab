{
  inputs,
  modulesPath,
  pkgs,
  self,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) system;
  selfPkgs = self.packages.${system};
  diskoPkgs = inputs.disko.packages.${system};
  clientConfig = self.nixosConfigurations.lab-client-1.config;
in {
  imports = [(modulesPath + "/installer/cd-dvd/iso-image.nix") ./hardware-configuration.nix];

  # Nix
  networking.hostName = "lab-manager";
  system.stateVersion = "25.11";
  environment.etc."nixos".source = self.outPath;

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    trusted-users = ["@wheel"];
  };

  # Users
  users.users.admin = {
    isNormalUser = true;
    hashedPassword = "";
    extraGroups = ["networkmanager" "wheel"];
  };

  security.sudo.wheelNeedsPassword = false;

  services.getty = {
    autologinUser = "admin";
    helpLine = "Run 'lab-help lab-manager' for the Swedru Lab manual.";
  };

  # Networking
  networking.networkmanager.enable = true;

  # Image
  isoImage = {
    makeEfiBootable = true;
    makeUsbBootable = true;
  };

  # Packages
  environment.systemPackages = [
    diskoPkgs.disko
    pkgs.helix
    pkgs.nano
    pkgs.vim
    selfPkgs.lab-help

    # Bundle store paths
    clientConfig.system.build.toplevel
    clientConfig.system.build.destroyFormatMount
  ];
}
