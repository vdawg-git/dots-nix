{pkgs, ...}: {
  # Enable Hyprland
  programs.hyprland = {
    enable = true;
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  programs.hyprlock.enable = true;
  services.hypridle.enable = true;

  environment.systemPackages = with pkgs; [
    hyprcursor
    hyprdynamicmonitors
    hypridle
    hyprland-qt-support
    hyprlock
    hyprpaper
    hyprpicker
    hyprsunset
    kitty
  ];
}
