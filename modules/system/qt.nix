{pkgs, ...}: {
  environment.sessionVariables = {
    QT_QPA_PLATFORM = "wayland";

    QT_QPA_PLATFORMTHEME = "qt6ct";

    # To see debug messages for qt6 themeing
    QT_WAYLAND_DISABLE_WINDOWDECORATION = 1;

    # QT_STYLE_OVERRIDE = "kvantum";
    #  QT_AUTO_SCREEN_SCALE_FACTOR="1.5";
  };

  environment.systemPackages = with pkgs; [
    kdePackages.qtstyleplugin-kvantum
    kdePackages.qt6ct
    libsForQt5.qt5ct
  ];
}
