{
  # Enable networking
  networking.networkmanager.enable = true;
  # networking.useNetworkd = false;

  programs.nm-applet.enable = true;

  # Use Cloudflare DNS
  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNS = ["1.1.1.3#cloudflare-dns.com" "1.0.0.1#cloudflare-dns.com"];
      FallbackDNS = ["9.9.9.9#dns.quad9.net"];
      DNSOverTLS = "yes";
      DNSSEC = "yes";
      Domains = ["~."];
      Cache = "yes";
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [22 80 443 3000];
  };

  # --- Starlink performance tuning ---
  boot.kernelModules = ["tcp_bbr"];

  boot.kernel.sysctl = {
    # BBR + fair queueing — biggest single win on Starlink's lossy, bursty link
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";

    # Buffers sized for Starlink BDP (~250 Mbps × 60 ms ≈ 2 MB; 4× safety = 8 MB)
    "net.core.rmem_max" = 67108864;
    "net.core.wmem_max" = 67108864;
    "net.ipv4.tcp_rmem" = "4096 262144 33554432";
    "net.ipv4.tcp_wmem" = "4096 65536 33554432";

    # Don't drop cwnd after idle — Starlink flows restart constantly
    "net.ipv4.tcp_slow_start_after_idle" = 0;

    # Probe MTU black holes instead of silently stalling
    "net.ipv4.tcp_mtu_probing" = 1;

    # ECN helps during the 15-second satellite handover spikes
    "net.ipv4.tcp_ecn" = 1;

    "net.ipv4.tcp_fastopen" = 3;
    "net.core.netdev_max_backlog" = 4096;
  };
}
