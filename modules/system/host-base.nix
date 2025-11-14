{
  pkgs,
  lib,
  ...
}: {
  time.timeZone = lib.mkDefault "Europe/Berlin";

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
  services.printing.enable = lib.mkDefault false;

  users.mutableUsers = true;
  users.users = {
    vdawg = {
      isNormalUser = true;
      shell = pkgs.fish;
      description = "personal account";
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
      packages = with pkgs; [
        # Just have a global NodeJs version for ease of use, too
        nodePackages_latest.nodejs
      ];
    };
  };

  nix.settings.trusted-users = ["root" "vdawg"];

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Core system libraries
    stdenv.cc.cc.lib # libstdc++, libgcc_s
    glibc # libc, libm, libdl, libpthread
    mesa # libgbm.so.1, libGL.so.1
    libxkbcommon # libxkbcommon.so.0
  ];

  nix = {
    package = pkgs.nix;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  # Speeds up build times. Fish enables this by default for some completions
  documentation.man.generateCaches = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
