{
  pkgs,
  lib,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    awatcher
    activitywatch
  ];

  systemd.user.services.aw-server = {
    description = "ActivityWatch time tracker server";
    enable = true;

    wantedBy = [ "graphical-session.target" ];

    serviceConfig = {
      ExecStart = "${lib.getExe' pkgs.activitywatch "aq-qt"}";
      Restart = "always";
      RestartSec = 5;
      TimeoutStopSec = 90;
      ProtectSystem = "full";
      RestrictRealtime = true;
      ProtectHostname = true;
      ProtectKernelTunables = true;
    };
  };

  # The default activity watcher is not compatible with Wayland
  systemd.user.services.awatcher = {
    description = "Awatcher for ActivityWatch. Wayland compatible window and afk watcher.";
    enable = true;

    serviceConfig = {
      ExecStartPre = "${lib.getExe' pkgs.coreutils "sleep"} 15";
      ExecStart = "${lib.getExe' pkgs.awatcher "awatch"}";
      Restart = "always";
      RestartSec = 5;
      TimeoutStartSec = 120;
      TimeoutStopSec = 90;
      ProtectSystem = "full";
      RestrictRealtime = true;
      ProtectHostname = true;
      ProtectKernelTunables = true;
    };

    after = [
      "aw-server.service"
      "graphical-session.target"
    ];
    requires = [ "aw-server.service" ];
    wantedBy = [ "graphical-session.target" ];
  };

}
