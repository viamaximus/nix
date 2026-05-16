{
  pkgs,
  config,
  inputs,
  ...
}: {
  programs = {
    firefox = {
      enable = true;
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
