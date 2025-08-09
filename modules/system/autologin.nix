{ pkgs, lib, ... }:

{
  services.xserver.displayManager.lightdm.enable = false; # Disable default display manager (ensure no other DMs are enabled)
  services.getty.autologinUser = "vdawg"; # Auto-login user on boot
  environment.loginShellInit = ''
    # Launch Hyprland on TTY1, return to TTY when exiting
    if [ "$(tty)" = "/dev/tty1" ]; then
      ${lib.getExe' pkgs.hyprland} # Use `exec Hyprland` to auto-restart on exit/crash instead
    fi
  '';
}
