{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
  wrapGAppsHook3,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  cairo,
  cups,
  dbus,
  expat,
  glib,
  gtk3,
  libdrm,
  libgbm,
  libGL,
  libxkbcommon,
  libx11,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxrandr,
  libxcb,
  nspr,
  nss,
  pango,
  systemd,
  vulkan-loader,
  wayland,
  sources,
}: let
  platform = sources.platforms.${stdenv.hostPlatform.system}
    or (throw "backplane: unsupported system ${stdenv.hostPlatform.system}");
  inherit (sources) version;
  runtimeLibs = [libGL libdrm vulkan-loader wayland libxkbcommon];
in
  stdenv.mkDerivation {
    pname = "backplane";
    inherit version;

    src = fetchurl {
      url = "https://github.com/BackplaneWorks/Backplane/releases/download/v${version}/backplane-v${version}-${platform.target}.tar.gz";
      inherit (platform) hash;
    };

    sourceRoot = "backplane-${platform.target}";

    nativeBuildInputs = [autoPatchelfHook makeWrapper copyDesktopItems wrapGAppsHook3];

    buildInputs = [
      alsa-lib
      at-spi2-atk
      at-spi2-core
      cairo
      cups
      dbus
      expat
      glib
      gtk3
      libgbm
      libxkbcommon
      libx11
      libxcomposite
      libxdamage
      libxext
      libxfixes
      libxrandr
      libxcb
      nspr
      nss
      pango
      systemd
      stdenv.cc.cc.lib
    ];

    dontConfigure = true;
    dontBuild = true;
    dontStrip = true;
    dontWrapGApps = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/lib/backplane $out/bin
      cp -r . $out/lib/backplane/
      rm -f $out/lib/backplane/runtime/chrome-sandbox

      for f in $out/lib/backplane/runtime/resources/backplane-service/backplane-*; do
        ln -s "$f" $out/bin/$(basename "$f")
      done

      install -Dm644 runtime/resources/app/backplane.png \
        $out/share/icons/hicolor/512x512/apps/backplane.png

      runHook postInstall
    '';

    postFixup = ''
      makeWrapper $out/lib/backplane/runtime/backplane-desktop $out/bin/backplane \
        "''${gappsWrapperArgs[@]}" \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibs} \
        --set-default BACKPLANE_NO_UPDATE 1 \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}"
    '';

    desktopItems = [
      (makeDesktopItem {
        name = "backplane";
        desktopName = "Backplane";
        comment = "Agentic hardware development";
        exec = "backplane %U";
        icon = "backplane";
        categories = ["Development" "Electronics"];
        mimeTypes = ["x-scheme-handler/backplane"];
        startupWMClass = "Backplane";
      })
    ];

    passthru.updateScript = ./update.sh;

    meta = {
      description = "Agentic hardware development with deterministic KiCad/STEP viewers";
      homepage = "https://github.com/BackplaneWorks/Backplane";
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
      platforms = builtins.attrNames sources.platforms;
      mainProgram = "backplane";
    };
  }
