{ pkgs, ... }:
let
  baseTools = with pkgs; [
    bitwarden-desktop
    blanket
    blueman
    brave
    bun
    clang
    cmake
    dotbot
    dragon-drop
    eog
    fastfetch
    fsearch
    gcc
    git
    git-lfs
    gnome-calculator
    gnome-system-monitor
    gnumake
    grim
    hyprsunset
    imagemagick
    keyd
    kitty
    libclang
    libxkbcommon
    lsof
    mediainfo
    megacmd
    monaspace
    mpv
    nautilus
    nerd-fonts.jetbrains-mono
    nixfmt-rfc-style
    nwg-displays
    nwg-panel
    obs-studio
    obsidian
    openssl.dev
    pavucontrol
    pkg-config
    python3
    qbittorrent-enhanced
    rhythmbox
    sassc # For the generation of the Colloid theme
    swaynotificationcenter
    swayosd
    switcheroo # File conversion
    swww
    telegram-desktop
    tesseract
    vesktop
    vscode.fhs
    walker
    wget
    wireguard-tools
    zlib.dev
  ];

  cliTools = with pkgs; [
    bat
    bitwarden-cli
    btop
    delta # Git differ
    fnm
    fzf
    hurl # Easy endpoint testing
    jq
    kalker # calculator
    kew
    lazygit
    pnpm-shell-completion
    rclone
    ripgrep # rg, faster grep
    rsync
    rustup
    satty
    slurp
    starship # Fancy prompt
    swappy
    tree
    vim
    wl-clipboard
    yt-dlp
    zip
    zoxide # Better cd
  ];
in
{
  environment.systemPackages = baseTools ++ cliTools;

  programs.file-roller.enable = true;
  programs.firefox.enable = true;
  programs.fish.enable = true;
}
