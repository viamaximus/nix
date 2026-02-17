{config, lib, ...}: let
  cfg = config.features.bluetooth;
in {
  options.features.bluetooth.enable = lib.mkEnableOption "bluetooth support" // {default = true;};

  config = {
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };

    hardware.bluetooth = lib.mkIf cfg.enable {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
        };
      };
    };
    services.blueman.enable = lib.mkIf cfg.enable true;
  };
}
