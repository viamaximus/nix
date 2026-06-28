{config, ...}: {
  services.tailscale = {
    enable = true;
    # Allow accepting subnet routes / exit nodes advertised by other nodes.
    useRoutingFeatures = "client";
    # Use Tailscale's MagicDNS when bringing the interface up.
    extraUpFlags = ["--accept-dns=true"];
  };

  networking.firewall = {
    # Trust traffic on the tailnet; allow the WireGuard UDP port for
    # direct (non-DERP) connections.
    trustedInterfaces = ["tailscale0"];
    allowedUDPPorts = [config.services.tailscale.port];
  };
}
