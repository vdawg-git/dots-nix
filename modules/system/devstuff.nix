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
    (
      corepack.override {nodejs = pkgs.nodejs_latest;}
    )
    bun
    direnv
  ];
}
