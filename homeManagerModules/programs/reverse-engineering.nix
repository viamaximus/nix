{
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs;
    lib.optionals stdenv.isx86_64 [
      # ida-free 9.3 is a requireFile package: hex-rays gates downloads behind a
      # login, so Nix can't fetch the installer. To re-enable:
      #   1. Download ida-free-pc_93_x64linux.run from
      #      https://my.hex-rays.com/dashboard/download-center/installers/release/9.3/ida-free
      #   2. nix-store --add-fixed sha256 ida-free-pc_93_x64linux.run
      #   3. Uncomment the line below and rebuild.
      # ida-free
    ];
}
