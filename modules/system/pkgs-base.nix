{ pkgs, ... }:
{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    any-nix-shell
    telegram-desktop
    zip
    bat
    bitwarden-cli
    bitwarden-desktop
    blanket
    blueman
    brave
    btop
    bun
    clang
    cmake
    delta
    dragon-drop
    eog
    fastfetch
    fnm
    fsearch
    fzf
    gcc
    git
    git-lfs
    gnome-calculator
    gnome-system-monitor
    gnumake
    grim
    hyprsunset
    imagemagick
    jq
    kalker
    kdePackages.kdenlive
    kew
    keyd
    kitty
    lazygit
    libclang
    lsof
    libxkbcommon
    mediainfo
    megacmd
    mpv
    nautilus
    neovim
    nerd-fonts.jetbrains-mono
    nixfmt-rfc-style
    nwg-displays
    nwg-panel
    obs-studio
    obsidian
    openssl.dev
    pavucontrol
    pkg-config
    pnpm-shell-completion
    python3
    qbittorrent-enhanced
    rclone
    rhythmbox
    ripgrep
    rsync
    rustup
    sassc # For the generation of the Colloid theme
    satty
    slurp
    starship
    swappy
    swaynotificationcenter
    swayosd
    switcheroo
    swww
    tesseract
    tree
    vesktop
    vim
    vscode.fhs
    walker
    wget
    wireguard-tools
    wl-clipboard
    yt-dlp
    zlib.dev
    zoxide
  ];

  programs.file-roller.enable = true;
}
