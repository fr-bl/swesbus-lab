{
  config,
  inputs,
  pkgs,
  self,
  ...
}: {
  # Client
  networking.hostName = "lab-client-${toString config.remote.index}";
  users.users.admin.name = "admin";
  users.users.admin.password = "onion-refresh-unsorted";

  # RDP connection
  remote.enable = true;
  remote.host = "192.168.10.10";
  remote.user.name = "User ${toString config.remote.index}";
  remote.user.password = "123";
  remote.extraArguments = ["/cert:ignore" "+f"];

  # WiFi
  networking.networkmanager.ensureProfiles.profiles.lab.wifi.ssid = "GESLAB_SWEDRU SCHOOL OF BUSINESS";
  networking.networkmanager.ensureProfiles.profiles.lab.wifi-security.psk = "geslab.moc_swedruschoolofbusiness";

  networking.wireless.networks.lab.ssid = "GESLAB_SWEDRU SCHOOL OF BUSINESS";
  networking.wireless.networks.lab.psk = "geslab.moc_swedruschoolofbusiness";

  # Partitions
  disko.devices.disk.main.device = "/dev/mmcblk0";
  disko.devices.disk.main.content.partitions.root.size = "12G";
  disko.devices.disk.main.content.partitions.swap.size = "8G";

  # Packages
  # Find more on https://search.nixos.org/packages
  environment.systemPackages = [
    pkgs.cage
    pkgs.freerdp
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
