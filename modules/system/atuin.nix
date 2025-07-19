{ pkgs, ... }:

{
  services.atuin = {
    enable = true;
    openFirewall = false;
  };

  # Dunno why, but the above did stop installing it
  environment.systemPackages = with pkgs; [
    atuin
  ];
}
