{
  # Enable networking
  networking.networkmanager.enable = true;

  programs.nm-applet.enable = true;

  # Use Cloudflare DNS
  networking.nameservers = [
    "1.1.1.1"
    "9.9.9.9"
  ];
}
