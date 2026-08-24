hl.on("hyprland.start", function()
  hl.exec_cmd("~/.config/hypr/scripts/polkit.sh")
  hl.exec_cmd("sleep 1 && dbus-update-activation-environment --systemd --all && systemctl --user start hyprland-session.target")

  hl.exec_cmd("hypridle")

  hl.exec_cmd("hyprctl setcursor Bibata-Modern-Classic 24")
  hl.exec_cmd("hypridle")
  hl.exec_cmd("swayosd-server")

  hl.exec_cmd("aw-qt")
  hl.exec_cmd("sleep 15 && aw-awatcher")

  hl.exec_cmd("hyprsunset")

  hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme prefer-dark")
  hl.exec_cmd("~/.config/hypr/scripts/loadgtk.sh")

  hl.exec_cmd("vicinae server")

  hl.exec_cmd("nwg-panel")
  hl.exec_cmd("swaync")
  hl.exec_cmd("blueman-applet")
  hl.exec_cmd("nm-applet --indicator")

  hl.exec_cmd("hyprpaper")
  hl.exec_cmd("mega-cmd-server")

  hl.exec_cmd("playerctld daemon")
end)

hl.on("hyprland.shutdown", function()
  hl.exec_cmd("systemctl --user stop hyprland-session.target")
end)
