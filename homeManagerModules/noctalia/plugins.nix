{
  config,
  lib,
  ...
}:
lib.mkIf config.features.desktop.noctalia.enable {
  # Plugins materialize at runtime into $XDG_STATE_HOME/noctalia/plugins from the
  # official git source. System deps (gpu-screen-recorder, evtest) are installed
  # in default.nix. bongocat reads /dev/input/* (user is in the `input` group).
  programs.noctalia.settings.plugins = {
    enabled = [
      "noctalia/screen_recorder"
      "noctalia/translator"
      "noctalia/bongocat"
      "noctalia/wallhaven"
    ];
    source = [
      {
        name = "official";
        kind = "git";
        location = "https://github.com/noctalia-dev/official-plugins";
        auto_update = false;
      }
    ];
  };
}
