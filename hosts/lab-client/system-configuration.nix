{
  config,
  pkgs,
  self,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) system;
  selfPkgs = self.packages.${system};
in {
  config = {
    # Nix
    system.stateVersion = "25.11";
    environment.etc."nixos".source = self.outPath;

    nix.settings = {
      experimental-features = ["nix-command" "flakes"];
      trusted-users = ["@wheel"];
    };

    # Users
    users.users.admin = {
      description = "Admin";
      isNormalUser = true;
      extraGroups = ["wheel"];
    };

    users.users.remote = {
      description = "Remote Session";
      isNormalUser = true;
      hashedPassword = "";
    };

    services.getty.helpLine = "Run 'lab-help' for the Swedru Lab manual.";

    # Login
    services.displayManager = {
      gdm.enable = true;
      defaultSession = "lab-remote-session";
      autoLogin.user = "remote";
    };

    systemd.services.display-manager = {
      wants = ["network-online.target"];
      after = ["network-online.target"];
    };

    # Desktop
    services.desktopManager.gnome.enable = true;
    services.gnome.core-developer-tools.enable = false;
    services.gnome.games.enable = false;

    # Security
    security.polkit.enable = true;

    # Network
    networking.networkmanager.ensureProfiles.profiles.lab = {
      connection = {
        autoconnect = "true";
        autoconnect-priority = "10";
        id = config.networking.networkmanager.ensureProfiles.profiles.lab.wifi.ssid;
        interface-name = "wlp2s0";
        type = "wifi";
      };

      ipv4.method = "auto";
      ipv6.method = "auto";

      wifi.mode = "infrastructure";
      wifi-security.key-mgmt = "wpa-psk";
    };

    systemd.services.connect-lab-wifi = {
      description = "Enable WiFi interface";
      wantedBy = [ "network.target" ];
      after = [ "NetworkManager.service" ];

      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.networkmanager}/bin/nmcli radio wifi on";
      };
    };

    # SSH
    services.fail2ban.enable = true;
    services.openssh = {
      enable = true;
      settings.AllowUsers = ["admin"];
    };

    # Boot
    boot.silent = true;
    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    # Zswap
    zswap.enable = true;
    zswap.settings = {
      compressor = "lz4";
      max_pool_percent = 25;
      shrinker_enabled = true;
    };

    # Programs
    environment.systemPackages = [selfPkgs.lab-help];
  };
}
