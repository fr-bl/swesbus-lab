{
  config,
  inputs,
  pkgs,
  self,
  ...
}: let
    replaceVariables = builtins.replaceStrings ["$index"] [(toString config.remote.index)];
    jsonConfig = builtins.mapAttrs (_: replaceVariables) (builtins.fromJSON (builtins.readFile ./configuration.json));
in {
  # Client
  networking.hostName = "lab-client-${toString config.remote.index}";
  users.users.admin.name = "admin";
  users.users.admin.password = "admin";

  # RDP connection
  remote.enable = true;
  remote.host = jsonConfig.rdp_host;
  remote.user.name = jsonConfig.rdp_user;
  remote.user.password = jsonConfig.rdp_password;
  remote.extraArguments = ["/cert:ignore" "+f"];

  # WiFi
  networking.networkmanager.ensureProfiles.profiles.lab.wifi.ssid = jsonConfig.wifi_ssid;
  networking.networkmanager.ensureProfiles.profiles.lab.wifi-security.psk = jsonConfig.wifi_password;

  # Partitions
  disko.devices.disk.main.device = "/dev/mmcblk0";
  disko.devices.disk.main.content.partitions.root.size = "12G";
  disko.devices.disk.main.content.partitions.swap.size = "8G";

  # Packages
  # Find more on https://search.nixos.org/packages
  environment.systemPackages = [
    pkgs.git
    pkgs.python3

    # Editors
    pkgs.helix
    pkgs.nano
    pkgs.vim
  ];

  # Imports
  imports = [
    ./disko-configuration.nix
    ./hardware-configuration.nix
    ./system-configuration.nix
    inputs.disko.nixosModules.disko
    self.nixosModules.remote
    self.nixosModules.silentBoot
    self.nixosModules.zswap
  ];
}
