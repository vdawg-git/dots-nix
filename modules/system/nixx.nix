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
}
