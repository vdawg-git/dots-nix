{ pkgs, ... }:
let
  baseTools = with pkgs; [
    bitwarden-desktop
    blanket
    blueman
    brave
    bun
    dotbot
    dragon-drop
    eog
    fastfetch
    fsearch
    gcc # For Neovim Treesitter, so that it can create grammars
    git
    git-lfs
    gnome-calculator
    gnome-system-monitor
    grim
    imagemagick
    kitty
    mediainfo
    megacmd
    mpv
    nautilus
    nerd-fonts.jetbrains-mono
    nixfmt-rfc-style
    nwg-displays
    nwg-panel
    obs-studio
    obsidian
    pavucontrol
    python3
    qbittorrent-enhanced
    rhythmbox
    swaynotificationcenter
    swayosd
    switcheroo # File conversion
    telegram-desktop
    tesseract
    vesktop
    vscode.fhs
    walker
    wireguard-tools
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
    fd # Complete paths (works with fifc)
    file
    fnm
    fzf
    hurl # Easy endpoint testing
    jq
    kalker # calculator
    kew
    lazygit
    pnpm-shell-completion
    procs # Complete processes and preview their tree (for fifc)
    rclone
    ripgrep # rg, faster grep
    rsync
    rustup
    satty
    slurp
    starship # Fancy prompt
    superfile
    swappy
    tealdeer
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
