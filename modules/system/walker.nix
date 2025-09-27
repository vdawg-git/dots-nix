{
  pkgs,
  inputs,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs; [walker];

  # dunno, the flake just isnt working..
  # imports = [
  #   inputs.walker.nixosModules.default
  # ];

  # programs.walker = {
  #   enable = true;
  #   # Idk why this is not working
  #   runAsService = true;
  # };

  nix.settings = {
    substituters = [
      "https://walker-git.cachix.org"
      "https://walker.cachix.org"
    ];
    trusted-public-keys = [
      "walker-git.cachix.org-1:vmC0ocfPWh0S/vRAQGtChuiZBTAe4wiKDeyyXM0/7pM="
      "walker.cachix.org-1:fG8q+uAaMqhsMxWjwvk0IMb4mFPFLqHjuvfwQxE4oJM="
    ];
  };
}
