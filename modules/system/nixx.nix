{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    nixfmt-rfc-style # CLI formatter
    comma # Run anything instantly with `, some-app`
    manix # Easy NixOS docs searcher
    any-nix-shell # Use Fish after going into a shell
  ];

  # Idk why, but this failed
  programs.command-not-found.enable = false;
  # And this works hopefully
  programs.nix-index.enable = true;

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 15d --keep 3";
    flake = "/home/vdawg/dotfiles"; # sets NH_OS_FLAKE variable for you
  };
}
