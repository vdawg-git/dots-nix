{ pkgs, ... }:
let
  username = "vdawg";
  # This dbus activate thing is nessecary so that the keychain gets unlocked (no more annoying password again)
  command = "dbus-update-activation-environment --systemd DISPLAY && uwsm start hyprland";
in
{
  # Force the Kernel to log in in TTY1 so that it does not override a possible instance
  # of greetd in TTY1. We work around this by telling both the kernel and Greetd to run
  # their services in different TTYs.
  boot.kernelParams = [ "console=tty1" ];
  services.greetd = {
    enable = true;
    vt = 2;

    # <https://man.sr.ht/~kennylevinsen/greetd/>
    settings = {
      initial_session = {
        command = "${command}";
        user = "${username}";
      };

      default_session = {
        user = "greeter";
        command = ''
          ${pkgs.greetd.tuigreet}/bin/tuigreet
                    --greeting 'Thou art returned. The sun doth rise on new opportunities ^-^'
                    --remember --remember-session
                    --asterisks-char ▓
                    --time --time-format '%I:%M %p | %a • %h | %F'
                    --cmd '${command}'
        '';
      };
    };
  };

  users.users.greeter = {
    isNormalUser = false;
    description = "greetd greeter user";
    extraGroups = [
      "video"
      "audio"
    ];
    linger = true;
  };

  # Unlock GPG keyring on login
  security.pam.services =
    let
      gnupg = {
        enable = true;
        noAutostart = true;
        storeOnly = true;
      };
    in
    {
      login = {
        enableGnomeKeyring = true;
        inherit gnupg;
      };

      greetd = {
        enableGnomeKeyring = true;
        inherit gnupg;
      };

      tuigreet = {
        enableGnomeKeyring = true;
        inherit gnupg;
      };
    };
}
