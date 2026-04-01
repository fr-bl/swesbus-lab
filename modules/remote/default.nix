{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.remote;

  arguments = ["${pkgs.freerdp}/bin/xfreerdp" "/v:${cfg.host}" "/u:${cfg.user.name}" "/p:${cfg.user.password}"] ++ cfg.extraArguments;
  connectionScript = pkgs.writeShellScriptBin "lab-remote-session" (lib.escapeShellArgs arguments);

  desktopItem = pkgs.makeDesktopItem {
    name = "lab-remote-session";
    desktopName = "Remote Session";
    genericName = "RDP Client";
    comment = "Connect to the RDP server using FreeRDP.";
    exec = "lab-remote-session";
    categories = ["System"];
  };

  package = pkgs.symlinkJoin {
    name = "lab-remote-session";
    paths = [connectionScript desktopItem];
  };

  sessionDesktopItem = pkgs.makeDesktopItem {
    name = "lab-remote-session";
    desktopName = "Remote Session";
    genericName = "RDP Client";
    comment = "Connect to the RDP server using FreeRDP.";
    exec = "${lib.getExe pkgs.cage} -s -- lab-remote-session";
    categories = ["System"];
    destination = "/share/wayland-sessions";
    derivationArgs.passthru.providedSessions = [ "lab-remote-session" ];
  };
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

    hardware.graphics.enable = true;

    environment.systemPackages = [cfg.package sessionDesktopItem];
  };
}
