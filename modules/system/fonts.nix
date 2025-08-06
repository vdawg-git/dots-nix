{ pkgs, ... }:

{
  fonts.packages = with pkgs; [
    monaspace
  ];

  environment.systemPackages = with pkgs; [
    fontfinder
  ];
}
