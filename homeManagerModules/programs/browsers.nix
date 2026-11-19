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
  imports = [inputs.zen-browser.homeModules.beta];

  programs = {
    zen-browser = {
      enable = true;
      policies.ExtensionSettings."{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
        installation_mode = "force_installed";
      };
    };

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
    ungoogled-chromium
  ];
}
