{ config, pkgs, lib, inputs, imports, ... }:
let
  userName = "vdawg";
  homeDirectory = "/home/${userName}";

  # The parent is this flake
  baseConfigDir = "/home/vdawg/dotfiles/home";
  dotPrefix = "dot_";

  configLinks = lib.pipe baseConfigDir [
    (builtins.readDir)
    (builtins.attrNames)
    (map toString)
    (map (dirName:
      let
        fromBase = "${baseConfigDir}/${dirName}";

        links = lib.pipe (builtins.readDir fromBase) [
          (builtins.attrNames)
          (map toString)
          (map getFromSymlinks)
          (map (toLink: {
            from = toLink;
            to = lib.removePrefix dotPrefix toLink;
          }))
        ];
      in links))
    (map ({ to, from }: "safe_link '${from}' '${to}'"))
    (lib.concatStringsSep "\n")
  ];

  passThroughPrefix = "pass_";

  getFromSymlinks = (dir:
    lib.pipe (builtins.readDir dir) [
      (builtins.attrNames)
      (map toString)
      (map (childDir:
        let
          absolutePath = "${dir}/${childDir}";
          isPassthrough = lib.hasInfix passThroughPrefix childDir;
          toSymlinks = if isPassthrough then
            (getToSymlinks absolutePath)
          else
            [ absolutePath ];

        in toSymlinks))
      (lib.flatten)
    ]);
in {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = userName;
  home.homeDirectory = homeDirectory;
  home.stateVersion = "25.05"; # Dont change to prevent breaking changes

  home.activation.linkDotfiles =
    lib.hm.dag.entryAfter [ "writeBoundary" ] configLinks;
  home.activation.init = lib.hm.dag.entryBefore [ "linkDotfiles" ] ''
    safe_link() {
      local src="$1"
      local dest="$2"

      echo $1

      mkdir -p "$(dirname "$dest")"  # make parent dir if needed

      if [ -L "$dest" ]; then
    	# It's a symlink — check if it points to the correct target
    	local current_target
    	current_target=$(readlink -f "$dest")
    	if [ "$(readlink -f "$src")" = "$current_target" ]; then
    	  echo "[✓] $dest already correctly linked"
    	  return 0
    	else
    	  echo "[✗] ERROR: $dest is a symlink, but points to $current_target, not $src"
    	  return 1
    	fi
      elif [ -e "$dest" ]; then
    	echo "[✗] ERROR: $dest already exists and is not a symlink"
    	return 1
      else
    	ln -s "$src" "$dest"
    	echo "[+] Linked $dest → $src"
    	return 0
      fi
    }
  '';

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  # home.file = {
  # # Building this configuration will create a copy of 'dotfiles/screenrc' in
  # # the Nix store. Activating the configuration will then make '~/.screenrc' a
  # # symlink to the Nix store copy.
  # ".screenrc".source = dotfiles/screenrc;

  # # You can also set the file content immediately.
  # ".gradle/gradle.properties".text = ''
  #   org.gradle.console=verbose
  #   org.gradle.daemon.idletimeout=3600000
  # '';
  # };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/vdawg/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = { EDITOR = "nvim"; };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs;
    [
      # Added so that programs have access to it (Treesitter Neovim needs it),
      # as systemPackages dont have (and like in this case kinda shouldnt) be in $PATH 
      gcc

      # # It is sometimes useful to fine-tune packages, for example, by applying
      # # overrides. You can do that directly here, just don't forget the
      # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
      # # fonts?
      # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

      # # You can also create simple shell scripts directly inside your
      # # configuration. For example, this adds a command 'my-hello' to your
      # # environment:
      # (pkgs.writeShellScriptBin "my-hello" ''
      #   echo "Hello, ${config.home.username}!"
      # '')
    ];
}
