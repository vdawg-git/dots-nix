{pkgs, ...}: {
  fonts.packages = with pkgs; [
    monaspace
    jetbrains-mono
    stablePkgs.google-fonts
  ];

  environment.systemPackages = with pkgs; [
    fontfinder
  ];
}
