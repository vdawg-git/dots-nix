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
      dbus-update-activation-environment --systemd DISPLAY

      ${lib.getExe' pkgs.hyprland "Hyprland"} # Use `exec Hyprland` to auto-restart on exit/crash instead
    fi
  '';

  # Hopefully fixes the keyring not unlocking by default https://github.com/NixOS/nixpkgs/issues/174099#issuecomment-1201697954
  services.xserver.displayManager.sessionCommands = ''
    ${lib.getBin pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all
  '';
}
