{self, ...}: {
  config = {
    # Nix
    system.stateVersion = "25.11";
    environment.etc."nixos".source = self.outPath;

    nix.settings = {
      experimental-features = ["nix-command" "flakes"];
      trusted-users = ["@wheel"];
    };

    # Security
    security.polkit.enable = true;

    # SSH
    services.fail2ban.enable = true;
    services.openssh = {
      enable = true;
      settings.AllowUsers = ["admin"];
    };

    # Users
    users.users.admin = {
      isNormalUser = true;
      extraGroups = ["wheel"];
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
  };
}
