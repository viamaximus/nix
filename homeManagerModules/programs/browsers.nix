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

  home.packages = with pkgs; [
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    ungoogled-chromium
  ];
}
