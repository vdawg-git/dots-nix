{pkgs, ...}: {
  fonts.packages = with pkgs; [
    monaspace
    stablePkgs.google-fonts
  ];

  environment.systemPackages = with pkgs; [
  ];
}
