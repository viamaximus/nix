{lib, ...}: {
  stylix = {
    # mkDefault so noctalia hosts (which theme via Noctalia templates) can turn
    # Stylix off without a priority clash.
    enable = lib.mkDefault true;
    polarity = "dark";
  };
}
