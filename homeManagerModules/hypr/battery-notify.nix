{ config, pkgs, lib, ... }: {
  config = lib.mkIf (config.features.desktop.hyprland.enable && !config.features.desktop.noctalia.enable) {
    systemd.user.services.battery-notify = {
      Unit.Description = "Battery level notifications";
      Service = {
        Type = "oneshot";
        ExecStart = let
          script = pkgs.writeShellScript "battery-notify" ''
            STATE="''${XDG_RUNTIME_DIR:-/tmp}/battery-notify-last"
            BAT=$(ls /sys/class/power_supply/ 2>/dev/null | grep -iE 'BAT|battery' | head -1)
            [ -z "$BAT" ] && exit 0

            CAPACITY=$(cat "/sys/class/power_supply/$BAT/capacity")
            STATUS=$(cat "/sys/class/power_supply/$BAT/status")

            if [ "$STATUS" != "Discharging" ]; then
              echo "100" > "$STATE"
              exit 0
            fi

            LAST=$(cat "$STATE" 2>/dev/null || echo "100")

            for threshold in 20 15 10 5; do
              if [ "$CAPACITY" -le "$threshold" ] && [ "$LAST" -gt "$threshold" ]; then
                ${pkgs.libnotify}/bin/notify-send \
                  -u critical \
                  -i battery-low \
                  "Battery Low" \
                  "Battery at ''${CAPACITY}%"
                break
              fi
            done

            echo "$CAPACITY" > "$STATE"
          '';
        in "${script}";
      };
    };

    systemd.user.timers.battery-notify = {
      Unit.Description = "Battery level notification timer";
      Timer = {
        OnBootSec = "1min";
        OnUnitActiveSec = "1min";
      };
      Install.WantedBy = [ "timers.target" ];
    };
  };
}
