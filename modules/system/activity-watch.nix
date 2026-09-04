{
  pkgs,
  lib,
  ...
}: let
  exportCategorySettings = pkgs.writeShellScript "aw-export-category-settings" ''
    set -euo pipefail

    config_dir="$HOME/.config/activitywatch"
    output="$config_dir/category-settings.json"
    tmp="$output.tmp"

    trap '${lib.getExe' pkgs.coreutils "rm"} -f "$tmp"' EXIT

    ${lib.getExe' pkgs.coreutils "mkdir"} -p "$config_dir"
    ${lib.getExe pkgs.curl} --fail --silent --show-error --retry 30 --retry-delay 1 --retry-connrefused \
      http://localhost:5600/api/0/settings/classes \
      | ${lib.getExe pkgs.jq} --sort-keys . > "$tmp"
    ${lib.getExe' pkgs.coreutils "mv"} "$tmp" "$output"
  '';
in {
  environment.systemPackages = with pkgs; [
    awatcher
    activitywatch
  ];

  systemd.user.services.aw-server = {
    description = "ActivityWatch time tracker server";
    enable = true;

    wantedBy = ["graphical-session.target"];

    serviceConfig = {
      ExecStart = "${lib.getExe' pkgs.activitywatch "aw-server"}";
      Restart = "always";
      RestartSec = 5;
      TimeoutStopSec = 90;
      ProtectSystem = "full";
      RestrictRealtime = true;
      ProtectHostname = true;
      ProtectKernelTunables = true;
    };
  };

  systemd.user.services.aw-export-category-settings = {
    description = "Export ActivityWatch category settings";
    enable = true;

    serviceConfig = {
      Type = "oneshot";
      ExecStart = exportCategorySettings;
    };

    after = ["aw-server.service"];
    requires = ["aw-server.service"];
    wantedBy = ["graphical-session.target"];
  };

  # The default activity watcher is not compatible with Wayland
  systemd.user.services.awatcher = {
    description = "Awatcher for ActivityWatch. Wayland compatible window and afk watcher.";
    enable = true;

    serviceConfig = {
      ExecStartPre = "${lib.getExe' pkgs.coreutils "sleep"} 15";
      ExecStart = "${lib.getExe pkgs.awatcher}";
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
    requires = ["aw-server.service"];
    wantedBy = ["graphical-session.target"];
  };
}
