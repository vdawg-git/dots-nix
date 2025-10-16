{pkgs, ...}: {
  programs.direnv = {
    enable = true;
    loadInNixShell = true;
    direnvrcExtra = "";
    nix-direnv.enable = true;
    silent = true;
  };

  environment.systemPackages = with pkgs; [
    uv
    corepack_latest
    bun
    direnv
  ];
}
