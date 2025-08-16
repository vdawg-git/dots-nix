{pkgs, ...}: {
  imports = [./hardware.nix];

  networking.hostName = "swordfish";

  environment.systemPackages = with pkgs; [
  ];
}
