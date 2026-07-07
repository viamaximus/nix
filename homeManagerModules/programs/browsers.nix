{
  pkgs,
  config,
  inputs,
  ...
}: let
  keepassxc-browser = pkgs.fetchFirefoxAddon {
    name = "keepassxc-browser";
    url = "https://addons.mozilla.org/firefox/downloads/latest/keepassxc-browser/latest.xpi";
    hash = "sha256-TfnFTgopOqLjfpvPl+wwejWgDnjOuqmmjtulUsB8RWg=";
  };
  ublock-origin = pkgs.fetchFirefoxAddon {
    name = "ublock-origin";
    url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
    hash = "sha256-ec1CarWZgBxZ3+mJXLS4AC+vPaBZ9xEcJyGsEBaKO2Q=";
  };
in {
  programs = {
    firefox = {
      enable = true;
      profiles.default = {
        id = 0;
        isDefault = true;
        extensions.packages = [
          keepassxc-browser
          ublock-origin
        ];
      };
    };
  };

  home.sessionVariables = {
    BROWSER = "zen-beta";
  };

  home.packages = with pkgs; [
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    ungoogled-chromium
  ];
}
