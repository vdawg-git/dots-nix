{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    quickemu # Quickly create a Windows VM
  ];

  hardware.graphics.enable32Bit = true;
}
