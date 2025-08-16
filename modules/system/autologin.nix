{
  pkgs,
  lib,
  ...
}: {
  services.xserver.displayManager.lightdm.enable = false;
  services.getty.autologinUser = "vdawg"; # Auto-login user on boot

  environment.loginShellInit = ''
    # Launch Hyprland on TTY1, return to TTY when exiting
    if [ "$(tty)" = "/dev/tty1" ]; then
      ${lib.getExe' pkgs.hyprland "Hyprland"} # Use `exec Hyprland` to auto-restart on exit/crash instead
    fi
  '';
}
