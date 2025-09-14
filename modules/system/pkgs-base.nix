{
  pkgs,
  inputs,
  ...
}: let
  baseTools = with pkgs; [
    amberol
    bitwarden-desktop
    blanket
    blueman
    brave
    celluloid
    dotbot
    dragon-drop
    eog
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
    rhythmbox
    swaynotificationcenter
    swayosd
    switcheroo # File conversion
    telegram-desktop
    vesktop
    vscode
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
    jq
    kalker # calculator
    kew
    lazygit
    mprocs
    playerctl
    playerctl
    pnpm-shell-completion
    procs # Complete processes and preview their tree (for fifc)
    rclone
    ripgrep # rg, faster grep
    rsync
    satty
    slurp
    starship # Fancy prompt
    superfile
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

    inputs.moo.packages.${pkgs.system}.default
  ];
in {
  environment.systemPackages = baseTools ++ cliTools;

  programs.file-roller.enable = true;
  programs.firefox.enable = true;
  programs.fish.enable = true;

  programs.yazi = {
    enable = true;
    settings = {};
  };
}
