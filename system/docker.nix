{ pkgs, ... }:

{
  # See https://nixos.wiki/wiki/Docker
  virtualisation.docker.enable = true;

  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  virtualisation.docker.daemon.settings = {
    userland-proxy = false;
    experimental = true;
    ipv6 = false;
    # metrics-addr = "0.0.0.0:9323";
    # fixed-cidr-v6 = "fd00::/80";
  };
}
