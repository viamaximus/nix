{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;

  cfg = config.features.localLlm;

  # Q2_0 needs llama.cpp >= b11556; older builds load it and output garbage
  bonsai2 = pkgs.fetchurl {
    name = "Ternary-Bonsai-2-27B-Q2_0.gguf";
    url = "https://huggingface.co/prism-ml/Ternary-Bonsai-2-27B-gguf/resolve/839bd57023c1558945afea70a74fa83c054f35f9/Ternary-Bonsai-2-27B-Q2_0.gguf";
    hash = "sha256-T5mu0BuKh34VP5qmVppEQP4XxZcBzAlT421/RgVJ5w4=";
  };

  # default CUDA archs so it substitutes from cache.nixos-cuda.org
  llamaCuda = pkgs.llama-cpp.override {cudaSupport = true;};
in {
  options.features.localLlm = {
    enable = mkEnableOption "local LLM inference server (llama.cpp + CUDA) for Hermes Agent";

    host = mkOption {
      type = types.str;
      default = "0.0.0.0";
      description = "Listen address; reachable over tailscale0 unless openFirewall is set.";
    };

    port = mkOption {
      type = types.port;
      default = 8080;
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Open the port on the LAN firewall (tailscale0 is already trusted).";
    };

    contextSize = mkOption {
      type = types.int;
      default = 65536;
      description = "Context window.";
    };
  };

  config = mkIf cfg.enable {
    nix.settings = {
      extra-substituters = ["https://cache.nixos-cuda.org"];
      extra-trusted-public-keys = [
        "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
      ];
    };

    environment.systemPackages = [llamaCuda];

    services.llama-cpp = {
      enable = true;
      package = llamaCuda;
      openFirewall = cfg.openFirewall;
      settings = {
        inherit (cfg) host port;
        model = "${bonsai2}";
        alias = "bonsai-2-27b";
        jinja = true;
        n-gpu-layers = 99;
        flash-attn = "on";
        ctx-size = cfg.contextSize;
        # q8_0/f16 KV cache OOMs at 64k next to the desktop; Hermes needs >= 64k
        cache-type-k = "q4_0";
        cache-type-v = "q4_0";
        n-predict = 16384;
        parallel = 1;
        cache-ram = 8192;
        temp = 1.0;
        top-p = 0.95;
        top-k = 20;
        min-p = 0.05;
      };
    };
  };
}
