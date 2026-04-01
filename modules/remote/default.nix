{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.remote;

  arguments = ["${pkgs.freerdp}/bin/xfreerdp" "/v:${cfg.host}" "/u:${cfg.user.name}" "/p:${cfg.user.password}"] ++ cfg.extraArguments;
  package = pkgs.writeShellScript "lab-client-connect" (lib.escapeShellArgs arguments);
in {
  options.remote = {
    enable = lib.mkEnableOption "RDP client";

    host = lib.mkOption {
      type = lib.types.str;
      description = "The hostname or IP address of the remote server.";
    };

    index = lib.mkOption {
      type = lib.types.int;
      description = "The index of the remote user.";
    };

    user.name = lib.mkOption {
      type = lib.types.str;
      description = "The name of the remote user.";
    };

    user.password = lib.mkOption {
      type = lib.types.str;
      description = "The password for the remote user.";
    };

    extraArguments = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "Additional command line arguments to pass to FreeRDP.";
    };

    package = lib.mkOption {
      type = lib.types.package;
      description = "The package that starts the RDP session.";
    };
  };

  config = lib.mkIf cfg.enable {
    remote.package = package;

    users.users.remote.isNormalUser = true;

    services.cage = {
      enable = true;
      user = "remote";
      extraArguments = ["-s"];
      program = cfg.package;
    };

    systemd.services."cage-tty1" = {
      wants = ["network-online.target"];
      after = ["network-online.target"];
    };

    hardware.graphics.enable = true;
  };
}
