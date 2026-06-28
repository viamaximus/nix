{
  config,
  lib,
  ...
}:
lib.mkIf config.features.desktop.noctalia.enable {
  # Top bar on every monitor (workspaces are per-monitor by default).
  # margin_ends = 0 spans the full width (default 180 inset is why it looked
  # short); margin_edge = 0 sits flush to the top edge (default 10). Bump them
  # for a floating look.
  programs.noctalia.settings.bar.main = {
    position = "top";
    thickness = 30;
    margin_ends = 0;
    margin_edge = 0;
    capsule = true;

    start = ["launcher" "workspaces" "active_window"];
    center = ["media" "clock" "weather"];
    end = [
      "sysmon"
      "noctalia/bongocat:cat"
      "audio_visualizer"
      "tray"
      "bluetooth"
      "network"
      "volume"
      "nightlight"
      "power_profile"
      "keyboard_layout"
      "noctalia/wallhaven:wallhaven"
      "noctalia/screen_recorder:service"
      "notifications"
      "control-center"
      "session"
    ];
  };

  # Per-widget settings.
  programs.noctalia.settings.widget = {
    # Wired connections otherwise show the raw interface name (e.g. enp42s0);
    # hide the label so only the network icon shows.
    network.show_label = false;

    # bongocat keyboard reactivity is off until input devices are set. Glob all
    # keyboards (needs evtest + membership in the `input` group, both present).
    "noctalia/bongocat:cat".input_devices = ["/dev/input/by-id/*-event-kbd"];
  };
}

