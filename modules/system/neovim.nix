{pkgs, ...}: {
  programs.neovim = {
    enable = true;
    defaultEditor = true; # sets '$EDITOR' to "nvim"
    configure = {
      packages.myVimPackage = with pkgs.vimPlugins; {
        start = [
          # XXX: Adds nvim-treesitter into Neovim's runtime by loading it
          # on launch. For reference, TS should never be allowed to
          # invoke its own commands to fetch and build grammars; Nix
          # can already handle this. The below derivation contains
          # nvim-treesitter, alongside all TS grammars. Alternatively
          # (nvim-treesitter.withPlugins (ps: pkgs.tree-sitter.allGrammars))
          # can be used, or the 'withPlugins' field can be fine-grained to
          # select specific grammars.
          nvim-treesitter.withAllGrammars # better highlighting
        ];
      };
    };
  };
}
