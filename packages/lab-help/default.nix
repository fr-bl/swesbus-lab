{
  # Options
  labHelpSource,
  md2htmlOptions ? {},
  # Dependencies
  bash,
  lib,
  makeDesktopItem,
  md4c,
  runCommand,
  symlinkJoin,
  w3m-nographics,
  ...
}: let
  md2htmlFinalOptions =
    {
      "full-html" = true;
      "html-title" = "Swesbus Lab Manual";
      "html-css" = "style.css";
    }
    // md2htmlOptions;

  md2htmlShell = lib.cli.toCommandLineShellGNU {} md2htmlFinalOptions;

  helpScript = runCommand "lab-help" {} ''
    shopt -s extglob globstar

    mkdir --parents md html
    cp ${labHelpSource} md/index.md

    ${lib.getExe md4c} ${md2htmlShell} --output=html/index.html md/index.md
    cp ${./style.css} html/style.css

    html_index="file://$out/share/lab-help/html/index.html"

    cat >lab-help <<EOF
    #!${lib.getExe bash}
    xdg-open "$html_index#\$1" || ${lib.getExe w3m-nographics} "$html_index#\$1"
    EOF

    mkdir --parents $out/share/lab-help
    cp --recursive md html $out/share/lab-help

    install -D lab-help $out/bin/lab-help
  '';

  desktopItem = makeDesktopItem {
    name = "lab-help";
    desktopName = "Swesbus Lab Manual";
    genericName = "System Manual";
    comment = "View the Swesbus Lab in a web browser";
    exec = "lab-help";
    categories = ["System"];
  };
in
  symlinkJoin {
    name = "lab-help";
    paths = [
      helpScript
      desktopItem
    ];
  }
