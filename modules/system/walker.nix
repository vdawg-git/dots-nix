{
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    inputs.walker.nixosModules.default
  ];

  programs.walker = {
    enable = true;
    runAsService = true;
  };

  services.elephant = {
    enable = true;
    installService = true;
  };

  nix.settings = {
    substituters = [
      "https://walker-git.cachix.org"
      "https://github.com/abenz1267/walker"
    ];
    trusted-public-keys = [
      "walker-git.cachix.org-1:vmC0ocfPWh0S/vRAQGtChuiZBTAe4wiKDeyyXM0/7pM="
      "walker.cachix.org-1:fG8q+uAaMqhsMxWjwvk0IMb4mFPFLqHjuvfwQxE4oJM="
    ];
  };
}
