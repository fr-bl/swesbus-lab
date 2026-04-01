{
  config,
  lib,
  ...
}: let
  cfg = config.boot;
in {
  options.boot = {
    silent = lib.mkEnableOption "silent boot";
  };

  config.boot = lib.mkIf cfg.silent {
    # See https://wiki.nixos.org/wiki/Plymouth
    plymouth.enable = true;
    consoleLogLevel = 3;
    initrd.verbose = false;

    # Hide the OS choice for bootloaders.
    # It's still possible to open the bootloader list by pressing any key
    # It will just not appear on screen unless a key is pressed
    loader.timeout = 0;

    kernelParams = [
      "quiet"
      "udev.log_level=3"
      "systemd.show_status=auto"
    ];
  };
}
