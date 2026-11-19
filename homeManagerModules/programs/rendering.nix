{
  config,
  lib,
  pkgs,
  ...
}: {
  options.features.rendering.blender.enable =
    lib.mkEnableOption "Blender (CUDA build on x86_64)"
    // {default = true;};

  config.home.packages = with pkgs;
    lib.optionals config.features.rendering.blender.enable [
      (blender.override {
        cudaSupport = pkgs.stdenv.hostPlatform.isx86_64;
      })
    ]
    ++ lib.optionals stdenv.hostPlatform.isx86_64 [
      davinci-resolve
    ];
}
