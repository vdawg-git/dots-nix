{pkgs, ...}: {
  # To make usb sticks under Nautilus work
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.devmon.enable = true;

  # Stuff for filesystems
  environment.systemPackages = with pkgs; [udisks nfs-utils exfatprogs];
}
