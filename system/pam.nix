{ ... }:

{
  services.gnome.gnome-keyring.enable = true;
  services.gnome.seahorse.enable = true;

  # What is starting this. I dont want this
  security.pam.services.kwallet = {
    name = "kwallet";
    enableKwallet = false;
  };
}
