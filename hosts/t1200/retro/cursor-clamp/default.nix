# Built against the same hyprland as the session, so the plugin ABI always matches.
{
  lib,
  hyprland,
  hyprlandPlugins,
}:
hyprlandPlugins.mkHyprlandPlugin {
  pluginName = "cursor-clamp";
  version = "1.0";
  src = ./.;

  inherit (hyprland) nativeBuildInputs;
  dontConfigure = true; # plain compile, no cmake/meson

  buildPhase = ''
    runHook preBuild
    $CXX -O2 -shared -fPIC -std=c++2b --no-gnu-unique main.cpp -o cursor-clamp.so \
      $(pkg-config --cflags pixman-1 libdrm hyprland pangocairo libinput libudev wayland-server xkbcommon)
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 cursor-clamp.so $out/lib/libcursor-clamp.so
    runHook postInstall
  '';

  meta = {
    description = "Keep the cursor out of the t1200 bezel-hidden screen strips";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
