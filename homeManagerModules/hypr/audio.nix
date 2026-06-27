{
  config,
  pkgs,
  lib,
  osConfig,
  ...
}: let
  cfg = config.features.desktop.hyprland;
  hostName = osConfig.networking.hostName or "";

  # Quick wofi-driven audio output switcher.
  # Lists sinks by their friendly description, sets the chosen one as the
  # default, and moves any currently-playing streams over to it.
  audio-switcher = pkgs.writeShellApplication {
    name = "audio-switcher";
    runtimeInputs = with pkgs; [pulseaudio wofi jq libnotify];
    text = ''
      sinks="$(pactl -f json list sinks)"
      default="$(pactl get-default-sink)"

      # Build "description" menu, marking the current default.
      menu="$(echo "$sinks" | jq -r --arg def "$default" \
        '.[] | (if .name == $def then "  " else "   " end) + .description')"

      choice="$(echo "$menu" | wofi --dmenu --prompt "Audio Output" --width 500 --height 250 || true)"
      [ -z "$choice" ] && exit 0

      # Strip the marker prefix and resolve the description back to a sink name.
      desc="''${choice#   }"
      desc="''${desc#  }"
      name="$(echo "$sinks" | jq -r --arg d "$desc" '.[] | select(.description == $d) | .name' | head -n1)"
      [ -z "$name" ] && exit 0

      pactl set-default-sink "$name"

      # Move every active playback stream to the new sink.
      pactl list short sink-inputs | while read -r idx _; do
        pactl move-sink-input "$idx" "$name" || true
      done

      notify-send -t 2000 "Audio Output" "$desc"
    '';
  };

  # Quick wofi-driven microphone (input) switcher.
  # Lists sources by description, sets the chosen one as the default, and
  # moves any active recording streams over to it.
  mic-switcher = pkgs.writeShellApplication {
    name = "mic-switcher";
    runtimeInputs = with pkgs; [pulseaudio wofi jq libnotify];
    text = ''
      # Exclude monitor sources (loopbacks of outputs), keep real inputs.
      sources="$(pactl -f json list sources | jq '[.[] | select(.monitor_source_index == null or (.name | endswith(".monitor") | not))]')"
      default="$(pactl get-default-source)"

      menu="$(echo "$sources" | jq -r --arg def "$default" \
        '.[] | (if .name == $def then "  " else "   " end) + .description')"

      choice="$(echo "$menu" | wofi --dmenu --prompt "Microphone" --width 500 --height 250 || true)"
      [ -z "$choice" ] && exit 0

      desc="''${choice#   }"
      desc="''${desc#  }"
      name="$(echo "$sources" | jq -r --arg d "$desc" '.[] | select(.description == $d) | .name' | head -n1)"
      [ -z "$name" ] && exit 0

      pactl set-default-source "$name"

      # Move every active recording stream to the new source.
      pactl list short source-outputs | while read -r idx _; do
        pactl move-source-output "$idx" "$name" || true
      done

      notify-send -t 2000 "Microphone" "$desc"
    '';
  };
in {
  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.pavucontrol
      audio-switcher
      mic-switcher
    ];

    # On-screen slider overlay shown whenever volume/mute changes. This is what
    # makes "scroll over the waybar audio widget" give visual feedback, and is
    # especially useful on tower which has no media keys.
    services.swayosd.enable = true;

    # Tower: the NVIDIA GPU exposes one digital audio sink at a time, selected
    # by the card profile. The Dell S3225QS (center monitor, its only display
    # with speakers) sits on the HDMI 4 connector (hdmi-stereo-extra3). Lock the
    # card to that profile and give the sink a friendly name ("Dell32") so it
    # shows up sanely in the switcher and pavucontrol.
    xdg.configFile."wireplumber/wireplumber.conf.d/51-dell-audio.conf" = lib.mkIf (hostName == "tower") {
      text = ''
        monitor.alsa.rules = [
          {
            matches = [
              { device.name = "alsa_card.pci-0000_2b_00.1" }
            ]
            actions = {
              update-props = {
                device.profile = "output:hdmi-stereo-extra3"
              }
            }
          }
          {
            matches = [
              { node.name = "alsa_output.pci-0000_2b_00.1.hdmi-stereo-extra3" }
            ]
            actions = {
              update-props = {
                node.description = "Dell32"
                node.nick = "Dell32"
              }
            }
          }
        ]
      '';
    };
  };
}
