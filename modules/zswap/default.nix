{
  config,
  lib,
  ...
}: let
  cfg = config.zswap;
in {
  options.zswap = {
    enable = lib.mkEnableOption "Zswap";

    settings = lib.mkOption {
      type = lib.types.attrsOf (lib.types.oneOf [lib.types.str lib.types.int lib.types.bool]);
    };
  };

  config = lib.mkIf cfg.enable {
    # See https://wiki.nixos.org/wiki/Swap#Zswap_swap_cache
    zswap.settings.enabled = true;

    boot = {
      initrd.systemd.enable = lib.mkIf (cfg.settings.compressor == "lz4") true;
      kernelParams = lib.mapAttrsToList (name: value: "zswap.${name}=${toString value}") cfg.settings;
    };
  };
}
