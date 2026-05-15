{ pkgs, ... }: {
  # Required for Yubikey/smartcard access (age-plugin-yubikey, GPG, etc.)
  services.pcscd.enable = true;
  services.udev.packages = [ pkgs.yubikey-personalization ];
}
