{
  pkgs,
  self,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) system;
  selfPkgs = self.packages.${system};
in {
  home.stateVersion = "25.11";
  
  xdg.autostart = {
    enable = true;
    entries = ["${selfPkgs.lab-help}/share/applications/lab-help.desktop"];
  };
}
