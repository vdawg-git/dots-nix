# and webcam
{
  config,
  pkgs,
  ...
}: {
  # Try to fix screensharing
  boot.kernelModules = ["uvcvideo" "v4l2loopback"];
  boot.extraModulePackages = with config.boot.kernelPackages; [v4l2loopback];
  # For screensharing specifically
  services.pipewire.wireplumber.enable = true;

  # Essential packages for video
  environment.systemPackages = with pkgs; [
    v4l-utils
    libcamera
    pipewire
  ];

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
