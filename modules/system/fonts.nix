{pkgs, ...}: {
  fonts.packages = with pkgs; [
    stablePkgs.google-fonts
    stablePkgs.monaspace
    stablePkgs.nerd-fonts.gohufont
  ];

  # environment.systemPackages = with pkgs; [ ];
}
