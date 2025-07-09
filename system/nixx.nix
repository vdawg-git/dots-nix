{ ... }:

{
  environment.systemPackages = with pkgs; [
    nixfmt-rfc-style
  ];

  programs.nix-index.enable = true;
}
