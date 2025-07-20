{ pkgs, ... }:
{
  imports = [ ./hardware.nix ];

  networking.hostName = "legion";
}
