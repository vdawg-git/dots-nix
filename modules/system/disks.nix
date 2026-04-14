{pkgs, ...}: {
  programs.partition-manager = {
    enable = true;
    package = lib.mkPackageOption pkgs ["kdePackages" "partitionmanager"];
  };
}
