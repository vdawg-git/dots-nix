{
  boot = {
    loader = {
      systemd-boot.enable = true;
      systemd-boot.configurationLimit = 50;
      efi.canTouchEfiVariables = true;
      grub.enable = false;
      timeout = 2;
    };

    initrd = {
      enable = true;
      verbose = false;
      systemd.enable = true;
    };

    consoleLogLevel = 3;
    plymouth.enable = false;
  };
}
