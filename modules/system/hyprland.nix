{pkgs, ...}: {
  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  programs.hyprlock.enable = true;
  services.hypridle.enable = true;

  environment.systemPackages = with pkgs; [
    hyprpicker
    hyprcursor
    hyprlock
    hypridle
    swww
    kitty
  ];
}
