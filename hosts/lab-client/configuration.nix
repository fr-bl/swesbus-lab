{
  config,
  inputs,
  lib,
  pkgs,
  self,
  ...
}: {
  config = {
    lab = {
      # FIXME
      client.hostName = "lab-client-${toString config.lab.client.index}";
      server.hostName = "GESLAB_SWESBU";

      admin.name = "admin";
      admin.password = "take-care";

      wlan.enable = true;
      wlan.name = "GESLAB_SWEDRU SCHOOL OF BUSINESS";
      wlan.password = "geslab.moc_swedruschoolofbusiness";
    };

    # System
    networking.hostName = config.lab.client.hostName;
    system.stateVersion = "25.11";
    environment.etc."nixos".source = self.outPath;

    nix.settings = {
      experimental-features = ["nix-command" "flakes"];
      trusted-users = ["@wheel"];
    };

    # Users
    users.users = {
      ${config.lab.admin.name} = {
        isNormalUser = true;
        extraGroups = ["networkmanager" "wheel"];
        password = config.lab.admin.password;
      };

      cage.isNormalUser = true;
    };

    # Boot
    boot = {
      loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };

      # See https://wiki.nixos.org/wiki/Plymouth
      plymouth.enable = true;
      consoleLogLevel = 3;
      initrd.verbose = false;

      # Hide the OS choice for bootloaders.
      # It's still possible to open the bootloader list by pressing any key
      # It will just not appear on screen unless a key is pressed
      loader.timeout = 0;

      # See https://wiki.nixos.org/wiki/Swap#Zswap_swap_cache
      initrd.systemd.enable = true;

      kernelParams = [
        # Silent boot
        "quiet"
        "udev.log_level=3"
        "systemd.show_status=auto"

        # Zswap
        "zswap.enabled=1"
        "zswap.compressor=lz4"
        "zswap.max_pool_percent=25"
        "zswap.shrinker_enabled=1"
      ];
    };

    # Networking
    networking.wireless = lib.mkIf config.lab.wlan.enable {
      enable = true;
      networks.${config.lab.wlan.name}.psk = config.lab.wlan.password;
    };

    # Remote desktop
    services.cage = {
      enable = true;
      user = "cage";
      extraArguments = ["-d" "-s"];
      package =
        pkgs.writeShellScript "freerdp-connect"
        # bash
        ''
          ${pkgs.freerdp}/bin/sdl-freerdp /v:${config.lab.server.hostName}
        '';
    };

    # Wait for network before connecting to server
    systemd.services."cage-tty1" = {
      wants = ["network-online.target"];
      after = ["network-online.target"];
    };

    # Packages
    environment.systemPackages = [
      pkgs.cage
      pkgs.freerdp
      pkgs.nano
      pkgs.vim
    ];
  };

  imports = [
    inputs.disko.nixosModules.disko
    ./disko-config.nix
  ];

  options.lab = {
    client.index = lib.mkOption {
      type = lib.types.int;
      description = "The number assigned to the client.";
      example = 1;
    };

    client.hostName = lib.mkOption {
      type = lib.types.str;
      description = "The host name assigned to the client.";
    };

    server.hostName = lib.mkOption {
      type = lib.types.str;
      description = "The host name to connect to the server.";
    };

    wlan.enable = lib.mkEnableOption "the WLAN";

    wlan.name = lib.mkOption {
      type = lib.types.str;
      description = "The name of the WLAN.";
    };

    wlan.password = lib.mkOption {
      type = lib.types.str;
      description = "The password for the WLAN.";
    };

    admin.name = lib.mkOption {
      type = lib.types.str;
      description = "The name of the admin account on the client.";
    };

    admin.password = lib.mkOption {
      type = lib.types.str;
      description = "The password for the admin account on the client.";
    };
  };
}
