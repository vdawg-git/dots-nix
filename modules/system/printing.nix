{pkgs, ...}: {
  # printers
  services.printing.enable = true;
  services.printing.drivers = with pkgs; [
    gutenprint
  ];

  hardware.printers.ensurePrinters = [];

  # scanners
  hardware.sane = {
    enable = true;
    extraBackends = [pkgs.utsushi];
  };
  services.udev.packages = [pkgs.utsushi];
}
