{pkgs, ...}: {
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

    supportedFilesystems = ["ntfs"];
    initrd.supportedFilesystems = ["ntfs"];
  };

  environment.etc."issue".text = ''
    \e[1;35mWelcome, VDawg\e[0m
    Host: \n
    Kernel: \r
    Date: \d \t

    \e[1;34mNixOS machine ready\e[0m

    (ﾉ◕ヮ◕)ﾉ*:･ﾟ✧
  '';
}
