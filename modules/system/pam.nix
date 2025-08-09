{ ... }:

{
  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true;

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

      kwallet = {
        name = "kwallet";
        enableKwallet = false;
      };
    };
}
