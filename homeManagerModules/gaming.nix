{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    steam
    steam-run

    mangohud      
    goverlay      
    gamemode      
    protontricks  

    wineWowPackages.waylandFull
    winetricks
    lutris
    bottles  

    gamescope
  ];

  xdg.configFile."MangoHud/MangoHud.conf".text = ''
    toggle_hud = Shift_R+F12

    fps
    frametime
    frame_timing
    gpu_stats
    cpu_stats
    ram
    vram

    position = top-right
    font_size = 18
    background_alpha = 0.6
    hud_no_margin = 0
    table_columns = 2

    # fps_limit = 165
  '';

  xdg.configFile."gamemode.ini".text = ''
    [general]
    renice=10
    ioprio=0
    inhibit_screensaver=1

    [gpu]
    apply_gpu_optimisations=1

    [cpu]
    governor=performance

    [supervisor]
    # supervisor=systemd
  '';
}

