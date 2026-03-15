{pkgs, ...}: let
  ghidraScaled = pkgs.symlinkJoin {
    name = "ghidra-scaled";
    paths = [pkgs.ghidra];
    nativeBuildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/ghidra \
        --set _JAVA_OPTIONS "-Dsun.java2d.uiScale=2 -Dswing.aatext=true -Dawt.useSystemAAFontSettings=on"
    '';
  };
in {
  home.packages = [
    ghidraScaled
  ];
}
