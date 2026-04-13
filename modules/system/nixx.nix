{pkgs, ...}: let
  # For some reason the nix-index module just isnt working well with comma, so lets do it manually.
  updateNixIndex = pkgs.writeShellScriptBin "update-nix-index" ''
    set -euo pipefail

    filename="index-$(uname -m | sed 's/^arm64$/aarch64/')-$(uname | tr A-Z a-z)"

    cache_dir="$HOME/.cache/nix-index"

    mkdir -p "$cache_dir"
    cd "$cache_dir"

    ${pkgs.wget}/bin/wget -q -N \
      "https://github.com/nix-community/nix-index-database/releases/latest/download/$filename"

    ln -f "$filename" files

    echo "✔ nix-index database updated"
  '';
in {
  environment.systemPackages = with pkgs; [
    alejandra # Fast nice nix code formatter
    manix # Easy NixOS docs searcher
    any-nix-shell # Use Fish after going into a shell

    comma # Run anything instantly with `, some-app`

    updateNixIndex
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
