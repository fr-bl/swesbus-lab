{
  config,
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
  imports = [(modulesPath + "/installer/cd-dvd/iso-image.nix") ./hardware-configuration.nix inputs.home-manager.nixosModules.home-manager];

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
  services.getty.helpLine = "Run 'lab-help' for the Swesbus Lab manual.";

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.admin = self.homeModules.adminConfiguration;
    extraSpecialArgs = {inherit inputs self;};
  };

  # Desktop
  services.displayManager.gdm.enable = true;
  services.displayManager.autoLogin.user = "admin";
  services.desktopManager.gnome.enable = true;
  services.gnome.core-apps.enable = false;
  services.gnome.core-developer-tools.enable = false;
  services.gnome.games.enable = false;

  # Network
  networking.networkmanager.ensureProfiles.profiles.lab = {
    connection = {
      autoconnect = "true";
      id = config.networking.networkmanager.ensureProfiles.profiles.lab.wifi.ssid;
      interface-name = "wlp2s0";
      type = "wifi";
    };

    ipv4.method = "auto";
    ipv6.method = "auto";

    wifi.mode = "infrastructure";
    wifi.ssid = "GESLAB_SWEDRU SCHOOL OF BUSINESS";

    wifi-security.key-mgmt = "wpa-psk";
    wifi-security.psk = "geslab.moc_swedruschoolofbusiness";
  };

  # Image
  isoImage = {
    makeEfiBootable = true;
    makeUsbBootable = true;
  };

  # Packages
  environment.systemPackages = [
    # Apps
    selfPkgs.lab-help
    pkgs.gnome-user-docs
    pkgs.ephiphany # Web browser
    pkgs.ghostty # Terminal
    pkgs.nautilus # Files

    # Terminal
    diskoPkgs.disko
    pkgs.git
    pkgs.nano
    pkgs.vim

    # Bundle store paths
    clientConfig.system.build.toplevel
    clientConfig.system.build.destroyFormatMount
  ];
}
