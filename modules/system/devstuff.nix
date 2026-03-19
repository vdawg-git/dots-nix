{pkgs, ...}: {
  programs.direnv = {
    enable = true;
    loadInNixShell = true;
    nix-direnv.enable = true;
  };

  environment.etc."direnv/direnv.toml".text = ''
    [global]
    hide_env_diff = true
    strict_env   = true
  '';

  environment.systemPackages = with pkgs; [
    # Just have a global NodeJs version for ease of use, too
    # nodePackages_latest.nodejs
    # corepack
    bun
    direnv
  ];
}
