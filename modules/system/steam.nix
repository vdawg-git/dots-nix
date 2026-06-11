{pkgs, ...}: {
  programs.steam = {
    enable = true;

    remotePlay.openFirewall = false; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = false; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = false; # Open ports in the firewall for Steam Local Network Game Transfers

    package = pkgs.steam.override {
      extraLibraries = pkgs: with pkgs; [];

      extraPkgs = pkgs: with pkgs; [];
    };
  };
}
