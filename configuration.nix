# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ./hardware/legion.nix
    inputs.home-manager.nixosModules.default
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 50;
  boot.loader.grub.enable = false;

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;


  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = false;

  services.atuin = {
    enable = true;
    openFirewall = true;
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  users.mutableUsers = false;
  users.users = {

    vdawg = {
      isNormalUser = true;
      shell = pkgs.fish;
      description = "personal account";
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
      hashedPassword = "$6$Zaay0c3zuB2PzJXS$T0QDNB4RZLghjLeK50Ygh5NVqbL/hl7uzgSTelo9ZLbHaQAWr83yJwucOVmEi1GYDb/lCDS36drksPrwmSuJ1/";
      packages = with pkgs; [
        #  thunderbird
      ];
    };

    ck = {
      isNormalUser = true;
      shell = pkgs.fish;
      description = "work account";
      hashedPassword = "$6$Zaay0c3zuB2PzJXS$T0QDNB4RZLghjLeK50Ygh5NVqbL/hl7uzgSTelo9ZLbHaQAWr83yJwucOVmEi1GYDb/lCDS36drksPrwmSuJ1/";
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
      packages = with pkgs; [ ];
    };
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      "vdawg" = import ./home.nix;
      # "ck" = import ./home.nix;
    };
  };

  programs.fish.enable = true;
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    libgcc
  ];

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "vdawg";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  # systemd.services."getty@tty1".enable = false;
  # systemd.services."autovt@tty1".enable = false;

  # Install firefox.
  programs.firefox.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    atuin
    aw-watcher-window
    switcheroo
    awatcher
    bat
    bitwarden-cli
    bitwarden-desktop
    blanket
    blueman
    brave
    btop
	hyprsunset
    delta
    dragon-drop
    eog
    fastfetch
    fsearch
    yt-dlp
    fzf
    nixfmt-rfc-style
    kdePackages.kdenlive
    kalker
    jq
    bun
    git
    git-lfs
    gnome-calculator
    gnome-system-monitor
    grim
    home-manager
    imagemagick
    kew
    keyd
    kitty
    mediainfo
    megacmd
    mpv
    nautilus
    neovim
    nerd-fonts.jetbrains-mono
    networkmanager
    networkmanagerapplet
    nwg-displays
    nwg-panel
    obsidian
    pavucontrol
    qbittorrent-enhanced
    rclone
    rhythmbox
    ripgrep
    rustup
    slurp
    starship
    rsync
    rhythmbox
    swappy
    swaynotificationcenter
    obs-studio
    swww
    tesseract
    tree
    tree
    rclone
    vesktop
    vim
    vscode.fhs
    wget
    wireguard-tools
    yazi
    zoxide
  ];

  nix = {
    package = pkgs.nix;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };


  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
