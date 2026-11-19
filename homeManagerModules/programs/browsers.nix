{
  pkgs,
  config,
  inputs,
  ...
}: let
  keepassxc-browser = pkgs.fetchFirefoxAddon {
    name = "keepassxc-browser";
    url = "https://addons.mozilla.org/firefox/downloads/file/5078406/keepassxc_browser-1.10.4.1.xpi";
    hash = "sha256-rkEVej8Bewdzq7ogl9WwBWJBYx0KOK021o0LJLGkCcE=";
  };
  ublock-origin = pkgs.fetchFirefoxAddon {
    name = "ublock-origin";
    url = "https://addons.mozilla.org/firefox/downloads/file/5203014/ublock_origin-1.75.4.xpi";
    hash = "sha256-4t9QPM589QaRMGGMNJaV9ivd2564wYkVbQJyaa5K4mc=";
  };
in {
  programs = {
    firefox = {
      enable = true;
      configPath = ".mozilla/firefox";
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
