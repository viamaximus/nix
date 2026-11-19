{
  config,
  lib,
  inputs,
  ...
}: let
  cfg = config.features.hermes;
in {
  imports = [inputs.hermes-agent.homeManagerModules.default];

  options.features.hermes = {
    enable = lib.mkEnableOption "Hermes Agent CLI and desktop app (from the official flake)";
  };

  # services.hermes-agent left off so ~/.hermes/config.yaml stays editable
  config = lib.mkIf cfg.enable {
    programs.hermes-agent = {
      enable = true;
      desktop.enable = true;
    };
  };
}
