{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    alejandra # Fast nice nix code formatter
    manix # Easy NixOS docs searcher
    any-nix-shell # Use Fish after going into a shell

    comma # Run anything instantly with `, some-app`
  ];

  # Idk why, but this failed
  programs.command-not-found.enable = false;
  # And this works hopefully
  programs.nix-index.enable = true;


  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 90d --keep 3";
    flake = "/home/vdawg/dotfiles"; # sets NH_OS_FLAKE variable for you
  };
}
