{
  pkgs,
  config,
  inputs,
  ...
}: let
  keepassxc-browser = pkgs.fetchFirefoxAddon {
    name = "keepassxc-browser";
    url = "https://addons.mozilla.org/firefox/downloads/latest/keepassxc-browser/latest.xpi";
    hash = "sha256-81hHHn9VRaZKtp9IlxJwMxl6jZzeV0YySx2uJBorCik=";
  };
  ublock-origin = pkgs.fetchFirefoxAddon {
    name = "ublock-origin";
    url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
    hash = "sha256-8nMNKHcAV2OkXXZXSYkuk29JyucT0o96puoxRFS4nPE=";
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
