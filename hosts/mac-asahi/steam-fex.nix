{
  pkgs,
  inputs,
  lib,
  ...
}: let
  # x86_64 Steam/Mesa never get built here - they're substituted as prebuilt
  # binaries from cache.nixos.org and only ever executed via FEX inside a
  # muvm microVM (Apple Silicon can't run x86_64 natively).
  pkgsX86 = import inputs.nixpkgs {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };

  steamRunFree = pkgsX86.steam-run-free;
  mesa64 = pkgsX86.mesa;
  mesa32 = pkgsX86.pkgsi686Linux.mesa;

  # Bridges the guest into the x86_64 Steam runtime: Mesa (for the guest-side
  # Vulkan ICD used by muvm's --gpu-mode=venus passthrough to the host's
  # Asahi GPU driver), steam-run's FHS wrapper, and a PulseAudio shm
  # workaround (shared memory doesn't cross the microVM boundary).
  muvmSteamInit = pkgs.writeShellScript "muvm-steam-init.sh" ''
    ln -snf ${mesa64} /run/opengl-driver
    ln -snf ${mesa32} /run/opengl-driver-32
    ln -snf ${steamRunFree}/bin/steam-run /run/steam-run-free
    echo 1 > /proc/sys/kernel/print-fatal-signals || true
    echo enable-shm=no > /run/pulse.conf
  '';

  muvmSteam = pkgs.writeShellApplication {
    name = "muvm-steam";
    runtimeInputs = [pkgs.muvm pkgs.dbus];
    text = ''
      launcher="$HOME/.local/share/muvm-steam/steam-launcher/bin_steam.sh"
      if [[ ! -x "$launcher" ]]; then
        echo "Steam bootstrap not found at $launcher" >&2
        echo "Download+extract it once with:" >&2
        echo "  mkdir -p ~/.local/share/muvm-steam && cd ~/.local/share/muvm-steam && curl -sL -o steam.tar.gz https://repo.steampowered.com/steam/archive/stable/steam_latest.tar.gz && tar xzf steam.tar.gz" >&2
        exit 1
      fi

      # muvm needs a real pty to forward the child's stdio; without one
      # (e.g. invoked from a .desktop file) it silently drops all output.
      exec script -qec "muvm -i -t --gpu-mode=venus \
        -e DISPLAY -e WAYLAND_DISPLAY -e XDG_RUNTIME_DIR -e DBUS_SESSION_BUS_ADDRESS \
        -e PULSE_CLIENTCONFIG=/run/pulse.conf \
        --emu fex -x ${muvmSteamInit} -- \
        dbus-run-session -- ${steamRunFree}/bin/steam-run '$launcher' $*" /dev/null
    '';
  };
in {
  environment.systemPackages = [
    pkgs.fex
    pkgs.muvm
    muvmSteam
  ];
}
