{ ... }:

{
  services.gnome3.gnome-keyring.enable = true;
  services.gnome3.seahorse.enable = true;

  # What is starting this. I dont want this
  security.pam.services.kwallet = {
    name = "kwallet";
    enableKwallet = false;
  };
}
