{
  config,
  inputs,
  modulesPath,
  pkgs,
  self,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) system;
  diskoPkgs = inputs.disko.packages.${system};
  clientConfig = self.legacyPackages.${system}.nixosConfigurations.lab-client-1.config;

  labHelp = ''
    To set up a wireless connection, run:
    > nmtui

    To copy and enter the client configuration, run:
    > cp --recursive --no-preserve all /etc/nixos swesbus-lab
    > cd swesbus-lab

    To read the documentation, run:
    > less README.md

    To edit the client configuration, run:
    > nano hosts/lab-client/configuration.nix

    To list available disks, run:
    > sudo lsblk -l

    To install the client with index 1 to disk "sda", run:
    > disko-install --flake .#lab-client-1 --disk main /dev/sda
    This will *irrevocably* erase all data on that disk!

    To reboot the system, run:
    > sudo reboot

    To show this message again, run:
    > lab-help
  '';

  labHelpBin =
    pkgs.writeShellScriptBin "lab-help"
    # bash
    ''
      cat ${pkgs.writeText "lab-help-text" labHelp}
    '';
in {
  imports = [(modulesPath + "/installer/cd-dvd/iso-image.nix") ./hardware-configuration.nix];

  # System
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
    greetingLine = "Welcome to the lab manager - ${config.system.nixos.distroName} ${config.system.nixos.label} (\m) - \l";
    helpLine = labHelp;
  };

  # Networking
  networking.networkmanager.enable = true;

  # Image
  isoImage = {
    makeEfiBootable = true;
    makeUsbBootable = true;
  };

  # Graphics
  hardware.graphics.enable = true;

  # Packages
  environment.systemPackages = [
    diskoPkgs.disko # Disk partitioning
    labHelpBin
    pkgs.cage
    pkgs.freerdp
    pkgs.nano
    pkgs.vim
    clientConfig.system.build.toplevel # Bundle target configuration
  ];
}
