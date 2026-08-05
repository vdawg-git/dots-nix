{
  pkgs,
  inputs,
  ...
}: let
  baseTools = with pkgs; [
    # anki
    # mangayomi
    # obs-studio
    # onlyoffice-desktopeditors
    # vscode
    amberol
    bitwarden-desktop
    blanket
    blueman
    brave
    dragon-drop
    easyeffects
    eog
    file-roller
    fsearch
    gnome-control-center
    gnome-system-monitor
    haruna # Video player
    kitty
    lemmeknow # Identify strings and files
    mpv
    nautilus
    nerd-fonts.jetbrains-mono
    networkmanagerapplet
    nwg-panel
    obsidian
    pavucontrol
    puddletag
    python3
    qbittorrent-enhanced
    stablePkgs.rhythmbox
    swaynotificationcenter
    swayosd
    switcheroo # File conversion
    telegram-desktop
    vesktop
    vicinae
  ];

  cliTools = with pkgs; [
	ctx7
	unzip
    # harlequin # SQL Tui. Postgres, SQLite etc
    atuin
    bat
    beans
    bitwarden-cli
    brave-search-cli
    broot # explore directory trees (works with fifc)
    btop
    carapace # Fancy shell completions
    chafa # preview images, gif , pdf etc (works with fifc)
    codex
    delta # Git differ
    dotbot
    dust
    eza # Better ls (works with fish fifc)
    fastfetch
    fd # Complete paths (works with fifc)
    ffmpeg-headless
    file
    fnm
    fzf
    gcc # For Neovim Treesitter, so that it can create grammars
    gh
    git
    git-lfs
    glow
    grim
    gron # Make JSON grepable
    gum # fancy CLI tools
    hurl # Easy endpoint testing
    imagemagick
    inputs.moo.packages.${pkgs.stdenv.hostPlatform.system}.default
    jq
    killall
    lazygit
    lnav # Nice (the best I found) log viewer
    mediainfo
    megacmd
    mprocs
    ni # Unite all JS package managers commands - no more pnpm i in a bun project
    nodejs-slim
    playerctl
    pnpm-shell-completion
    procs # Complete processes and preview their tree (for fifc)
    rclone
    ripgrep # rg, faster grep
    rsync
    rtk
	lutris
    satty
    slurp
    starship # Fancy prompt
    swappy
    tealdeer
    tesseract
    tree
    wireguard-tools
    wl-clipboard
    wl-kbptr
    wlrctl
    yt-dlp
    zed-editor-fhs
    zip # For (un)zipping stuff, in case you wondered
    zoxide # Better cd
  ];
in {
  environment.systemPackages = baseTools ++ cliTools;

  # programs.firefox.enable = true;
  programs.fish.enable = true;

  programs.yazi = {
    enable = true;
    settings = {};
  };

  xdg.terminal-exec = {
    enable = true;
    settings = {
      default = [
        "kitty.desktop"
      ];
    };
  };
}
