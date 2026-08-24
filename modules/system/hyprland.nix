{ pkgs, ... }: {
  # Enable Hyprland
  programs.hyprland = {
    enable = true;
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  systemd.user.targets.hyprland-session = {
    description = "Hyprland graphical session";
    bindsTo = ["graphical-session.target"];
    wants = ["graphical-session.target"];
    after = ["graphical-session.target"];
  };

  programs.hyprlock.enable = true;
  services.hypridle.enable = true;

  environment.systemPackages = with pkgs; [
    hyprcursor
    hyprland-qt-support
    hyprlock
    hyprpaper
    hyprpicker
    hyprshutdown
    hyprsunset
    kitty
  ];
}
