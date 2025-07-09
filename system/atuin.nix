{ pkgs, ... }:

{
  services.atuin = {
    enable = true;
    openFirewall = true;
  };

  environment.systemPackages = with pkgs; [ atuin ];
}
