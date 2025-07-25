{ pkgs, ... }:

{
  # So that Vial can detect the keyboard
  services.udev.packages = with pkgs; [
    vial
  ];

  environment.systemPackages = with pkgs; [
    vial
  ];
}
