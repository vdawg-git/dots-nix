{
  pkgs,
  inputs,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs; [
    walker
  ];

  systemd.user.services.walker = {
    description = "Walker Application Launcher";
    wantedBy = ["graphical-session.target"];
    partOf = ["graphical-session.target"];
    serviceConfig = {
      ExecStart = "${lib.getExe' pkgs.walker "walker"} --gapplication-service";
      Restart = "on-failure";
      RestartSec = 5;
      TimeoutStopSec = 10;
    };
  };
}
