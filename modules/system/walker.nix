{
  pkgs,
  inputs,
  ...
}: {
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

  environment.systemPackages = [
    inputs.walker.packages.${pkgs.system}.default
  ];

  systemd.user.services.walker = {
    description = "Walker Application Launcher";
    wantedBy = ["graphical-session.target"];
    partOf = ["graphical-session.target"];
    serviceConfig = {
      ExecStart = "${inputs.walker.packages.${pkgs.system}.default}/bin/walker --gapplication-service";
      Restart = "on-failure";
      RestartSec = 5;
      TimeoutStopSec = 10;
    };
  };
}
