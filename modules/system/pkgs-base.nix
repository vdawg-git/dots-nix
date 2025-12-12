{
  pkgs,
  inputs,
  ...
}: let
  baseTools = with pkgs; [
    amberol
    anki
    bitwarden-desktop
    blanket
    blueman
    brave
    clapper
    dotbot
    dragon-drop
    eog
    file-roller
    fsearch
    gcc # For Neovim Treesitter, so that it can create grammars
    git
    git-lfs
    gnome-control-center
    gnome-system-monitor
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
    teams-for-linux
    telegram-desktop
    vesktop
    vicinae
    vscode
    wl-kbptr
    wlrctl
  ];

  cliTools = with pkgs; [
    atuin
    bat
    bitwarden-cli
    broot # explore directory trees (for fifc)
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
    inputs.moo.packages.${pkgs.stdenv.hostPlatform.system}.default
    jq
    kalker # calculator
    kew
    killall
    lazygit
    mprocs
    ni
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
    zip
    zoxide # Better cd
    opencode
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
