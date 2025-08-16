{pkgs, ...}: {
  imports = [./hardware.nix];

  networking.hostName = "legion";

  environment.systemPackages = with pkgs; [
  ];
}
