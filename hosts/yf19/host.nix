{pkgs, ...}: {
  imports = [./hardware.nix];

  networking.hostName = "yf19";

  environment.systemPackages = with pkgs; [
  ];
}
