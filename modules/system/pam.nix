{...}: {
  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true;

  # Unlock GPG keyring on login
  # https://github.com/JohnRTitor/nix-conf/commit/53bc83aef18849976d5a42cc727d38dd0e38c5b0
  security.pam.services = let
    gnupg = {
      enable = true;
      noAutostart = true;
      storeOnly = true;
    };
  in {
    login = {
      enableGnomeKeyring = true;
      inherit gnupg;
    };

    greetd = {
      enableGnomeKeyring = true;
      inherit gnupg;
    };

    greetd-password = {
      enableGnomeKeyring = true;
    };

    tuigreet = {
      enableGnomeKeyring = true;
      inherit gnupg;
    };

    gdm-password = {
      enableGnomeKeyring = true;
      inherit gnupg;
    };

    kwallet = {
      name = "kwallet";
      enableKwallet = false;
    };

    services.dbus.packages = [pkgs.gnome-keyring pkgs.gcr];

    services.xserver.displayManager.sessionCommands = ''
      eval $(gnome-keyring-daemon --start --daemonize --components=ssh,secrets)
      export SSH_AUTH_SOCK
    '';
  };
}
