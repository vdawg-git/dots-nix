{
  pkgs,
  stablePkgs,
  ...
}: {
  fonts.packages = [
    pkgs.monaspace
    pkgs.jetbrains-mono
    stablePkgs.google-fonts
  ];

  environment.systemPackages = with pkgs; [
    fontfinder
  ];
}
