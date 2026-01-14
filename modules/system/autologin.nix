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
      dbus-update-activation-environment --systemd --all

      ${lib.getExe' pkgs.hyprland "start-hyprland"}
    fi
  '';

  # Still doesnt fix stuff, but helps a bit I think https://github.com/NixOS/nixpkgs/issues/174099#issuecomment-1201697954
  services.xserver.displayManager.sessionCommands = ''
    ${lib.getBin pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all
  '';
}
