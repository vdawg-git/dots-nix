{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    nixfmt-rfc-style
    comma # Run anything instantly with `, some-app`
    manix # Easy NixOs docs searcher
  ];

  # Idk why, but this failed
  programs.command-not-found.enable = false;
  # And this works hopefully
  programs.nix-index.enable = true;
}
