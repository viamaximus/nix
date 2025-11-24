{ config, pkgs, lib, ... }:

{
  services.mako = {
    enable = true;
    borderSize = lib.mkForce 2;
    borderRadius = lib.mkForce 15;
    width = lib.mkForce 350;
    height = lib.mkForce 150;
    padding = lib.mkForce "15";
    margin = lib.mkForce "20";
    defaultTimeout = lib.mkForce 5000;

    extraConfig = ''
      [urgency=low]
      border-color=${config.lib.stylix.colors.withHashtag.base04}

      [urgency=normal]
      border-color=${config.lib.stylix.colors.withHashtag.base0D}

      [urgency=high]
      border-color=${config.lib.stylix.colors.withHashtag.base08}
      background-color=${config.lib.stylix.colors.withHashtag.base01}
    '';
  };
}
