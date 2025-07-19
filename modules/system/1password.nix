{
  inputs,
  pkgs,
  ...
}:
{
  # Shell plugins
  imports = [ inputs._1password-shell-plugins.nixosModules.default ];

  programs = {
    _1password.enable = true;

    _1password-gui = {
      enable = true;
      # this makes system auth etc. work properly
      polkitPolicyOwners = [ "vdawg" ];
    };

    _1password-shell-plugins = {
      # enable 1Password shell plugins for bash, zsh, and fish shell
      enable = true;
      # the specified packages as well as 1Password CLI will be
      # automatically installed and configured to use shell plugins
      plugins = with pkgs; [
        # gh
        # awscli2
        # cachix
      ];
    };
  };
}
