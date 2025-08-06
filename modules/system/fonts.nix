{ pkgs, ... }:

{
  fonts.pkgs = with pkgs; [
    monaspace
  ];

  environment.systemPackages = with pkgs; [
    fontfinder
  ];
}
