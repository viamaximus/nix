{ pkgs, ... }: {
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
    nerd-fonts.noto
    nerd-fonts.hack
    nerd-fonts.ubuntu
  ];

  fonts.fontconfig = {
    defaultFonts.sansSerif = ["Sans"];
    hinting.enable = true;
    hinting.style = "full";
    antialias = true;
    subpixel.rgba = "rgb";
  };
}
