{pkgs, ...}: {
  # Ah, this is not good. The killswitch was active without the app running. Took a very long time debug..
  # services.mullvad-vpn.enable = true;

  # environment.systemPackages = with pkgs; [
  #   mullvad-vpn
  # ];
}
