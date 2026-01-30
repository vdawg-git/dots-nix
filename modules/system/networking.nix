{
  # Enable networking
  networking.networkmanager.enable = true;
  # networking.useNetworkd = false;

  programs.nm-applet.enable = true;

  # Use Cloudflare DNS
  networking.nameservers = [
    "1.1.1.1"
    "9.9.9.9"
  ];

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [22 80 443 3000];
  };
}
