{ ... }:

{
  environment.systemPackages = with pkgs; [
    nixfmt-rfc-style
    comma # Run anything instantly with `, some-app`
    manix # Easy NixOs docs searcher
  ];

  programs.nix-index.enable = true;
}
