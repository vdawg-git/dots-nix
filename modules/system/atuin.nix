{
  services.atuin = {
    enable = true;
    openFirewall = false;
  };

  # Dunno why, but the above did stopped installing it
  environment.systemPackages = with pkgs; [
    atuin
  ];
}
