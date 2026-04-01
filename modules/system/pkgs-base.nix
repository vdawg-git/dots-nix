{
  pkgs,
  inputs,
  ...
}: let
  baseTools = with pkgs; [
    gum # fancy CLI tools
    onlyoffice-desktopeditors
    rustdesk-flutter
    amberol
    anki
    bitwarden-desktop
    blanket
    blueman
    brave
    claude-code-bin
    opencode
    opencode-desktop
    dotbot
    dragon-drop
    easyeffects
    eog
    ffmpeg-headless
    file-roller
    fsearch
    gcc # For Neovim Treesitter, so that it can create grammars
    git
    git-lfs
    gnome-control-center
    gnome-system-monitor
    haruna # Video player
    imagemagick
    kitty
    mediainfo
    megacmd
    mpv
    nautilus
    nerd-fonts.jetbrains-mono
    networkmanagerapplet
    nwg-displays
    nwg-panel
    obs-studio
    obsidian
    pavucontrol
    puddletag
    python3
    qbittorrent-enhanced
    quickshell
    stablePkgs.rhythmbox
    swaynotificationcenter
    swayosd
    switcheroo # File conversion
    telegram-desktop
    vesktop
    vicinae
    vscode
    wl-kbptr
    wlrctl
  ];

  cliTools = with pkgs; [
    # harlequin # SQL Tui. Postgres, SQLite etc
    atuin
    bat
    beads
    bitwarden-cli
    broot # explore directory trees (works with fifc)
    btop
    chafa # preview images, gif , pdf etc (works with fifc)
    delta # Git differ
    eza # Better ls (works with fish fifc)
    fastfetch
    fd # Complete paths (works with fifc)
    file
    fnm
    fzf
    gh
    grim
    hurl # Easy endpoint testing
    # inputs.beads-viewer.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.moo.packages.${pkgs.stdenv.hostPlatform.system}.default
    jq
    kalker # calculator
    kew
    killall
    lazygit
    lnav # Nice (the best I found) log viewer
    mprocs
    ni # Unite all JS package managers commands - no more pnpm i in a bun project
    playerctl
    pnpm-shell-completion
    procs # Complete processes and preview their tree (for fifc)
    rclone
    ripgrep # rg, faster grep
    rsync
    satty
    slurp
    starship # Fancy prompt
    swappy
    tealdeer
    tesseract
    tree
    vim
    wireguard-tools
    wl-clipboard
    yt-dlp
    zip # For (un)zipping stuff, in case you wondered
    zoxide # Better cd
  ];
in {
  environment.systemPackages = baseTools ++ cliTools;

  programs.firefox.enable = true;
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
