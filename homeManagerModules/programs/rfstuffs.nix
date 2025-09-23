{ config, pkgs, lib, ...}: 
{
  imports = [
  ];
  home.packages = with pkgs; [
    urh

    gnuradio
    gnuradioPackages.osmosdr
    gnuradioPackages.fosphor
    gnuradioPackages.bladeRF
    gnuradioPackages.lora_sdr

    soapybladerf
    libbladeRF

    airspy
    airspyhf
    soapyairspy

    aircrack-ng

    kismet

    wireshark

    rtl_433

    rtl-sdr

    gqrx

    hackrf
    soapyhackrf

    sdrangel

    qflipper

    python312Packages.rfcat

    sigdigger

    cyberchef

    proxmark3

    python313Packages.meshtastic

  ];
}
