-- Window rules
-- Hyprland 0.55+ Lua syntax: https://wiki.hypr.land/Configuring/Basics/Window-Rules/

-- Floats

hl.window_rule({
	name = "floats",
	match = {
		class = "^("
			.. "org.kde.ark"
			.. "|net.davidotek.pupgui2" -- ProtonUp-Qt
			.. "|yad" -- Protontricks-Gtk
			.. "|pavucontrol"
			.. "|blueman-manager"
			.. "|org.pulseaudio.pavucontrol"
			.. "|nm-applet"
			.. "|nm-connection-editor"
			.. "|org.kde.polkit-kde-authentication-agent-1"
			.. "|file-roller"
			.. "|xdg-desktop-portal-gtk"
			.. "|it.mijorus.smile"
			.. "|fsearch" -- FSearch
			.. "|eog" -- Image viewer
			.. "|Mojosetup" -- GOG games installer
			.. "|com.rafaelmardojai.Blanket"
			.. "|io.gitlab.adhami3310.Converter"
			.. "|com.gabm.satty"
			.. "|org.gnome.FileRoller"
			.. "|nwg-displays"
			.. ")$",
	},
	float = true,
})

hl.window_rule({
	name = "float-titles",
	match = {
		title = "^(Media viewer|org.kde.haruna|Open File|Create Automatic Playlist|Nextcloud)$|^(wlroots - WL)",
	},
	float = true,
})

hl.window_rule({
	name = "codium-add-folder-dialog",
	match = {
		class = "(codium|codium-url-handler|VSCodium)",
		title = "(Add Folder to Workspace)",
	},
	float = true,
})

hl.window_rule({
	name = "authentication-required-dialogs",
	match = {
		title = "^Authentication Required$",
	},
	float = true,
	center = true,
})

hl.window_rule({
	name = "polkit-authentication-dialogs",
	match = {
		class = "^(xfce-polkit|mate-polkit|polkit-mate-authentication-agent-1)$",
		title = "^(Authentication required|Authentication Required)$",
	},
	float = true,
	center = true,
	size = { "(monitor_w*0.35)", "(monitor_h*0.35)" },
})

hl.window_rule({
	name = "steam-child-windows",
	match = {
		class = "^[Ss]team$",
		title = "negative:^([Ss]team)$",
	},
	float = true,
})



hl.window_rule({
	name = "floating-video-players",
	match = {
		class = "^(mpv|com.github.rafostar.Clapper)$",
	},
	float = true,
})


hl.window_rule({
	name = "fullscreen-idle-inhibit",
	match = {
		fullscreen = true,
	},
	idle_inhibit = "fullscreen",
})

-- App-specific dialog polish

hl.window_rule({
	name = "pavucontrol-centered",
	match = {
		class = "^(org.pulseaudio.pavucontrol|pavucontrol)$",
	},
	float = true,
	center = true,
	pin = true,
	size = { "700", "600" },
})

hl.window_rule({
	name = "blueman-manager-sized",
	match = {
		class = "^blueman-manager$",
	},
	float = true,
	center = true,
	size = { "800", "600" },
})

hl.window_rule({
	name = "nwg-look",
	match = {
		class = "^nwg-look$",
	},
	float = true,
	center = true,
	size = { "700", "600" },
})

hl.window_rule({
	name = "nwg-displays-sized",
	match = {
		class = "^nwg-displays$",
	},
	float = true,
	center = true,
	size = { "900", "600" },
})

hl.window_rule({
	name = "missioncenter",
	match = {
		class = "^io.missioncenter.MissionCenter$",
	},
	float = true,
	center = true,
	pin = true,
	size = { "900", "600" },
})

hl.window_rule({
	name = "gnome-calculator",
	match = {
		class = "^org.gnome.Calculator$",
	},
	float = true,
	center = true,
	size = { "700", "600" },
})

hl.window_rule({
	name = "hyprland-share-picker",
	match = {
		class = "^hyprland-share-picker$",
	},
	float = true,
	center = true,
	pin = true,
	size = { "600", "400" },
})

hl.window_rule({
	name = "easyeffects",
	match = {
		class = "^com.github.wwmm.easyeffects$",
	},
	float = true,
	center = true,
	size = { "(monitor_w*0.6)", "(monitor_h*0.65)" },
})

hl.window_rule({
	name = "hyprpwcenter",
	match = {
		class = "^hyprpwcenter$",
	},
	float = true,
	center = true,
	size = { "(monitor_w*0.6)", "(monitor_h*0.6)" },
})

-- Picture-in-Picture

hl.window_rule({
	name = "picture-in-picture",
	match = {
		title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$",
	},
	float = true,
	keep_aspect_ratio = true,
	move = { "(monitor_w*0.73)", "(monitor_h*0.72)" },
	size = { "(monitor_w*0.25)", "(monitor_h*0.25)" },
	pin = true,
})

-- Dialogs

hl.window_rule({
	name = "centered-dialogs",
	match = {
		title = "^(Open File|Select a File|Choose wallpaper|Open Folder|Save As|Library|File Upload)(.*)$",
	},
	float = true,
	center = true,
})

-- Privacy and security

hl.window_rule({
	name = "bitwarden-private-float",
	match = {
		title = "^(Bitwarden)$",
	},
	float = true,
	center = true,
	no_screen_share = true,
})

hl.window_rule({
	name = "bitwarden-private-class",
	match = {
		class = "^(Bitwarden|bitwarden)$",
	},
	float = true,
	center = true,
	no_screen_share = true,
})

hl.window_rule({
	name = "keepassxc-private",
	match = {
		class = "^(org.keepassxc.KeePassXC|KeePassXC|keepassxc)$",
	},
	no_screen_share = true,
})

hl.window_rule({
	name = "seahorse-private",
	match = {
		class = "^(seahorse|org.gnome.seahorse.Application)$",
	},
	float = true,
	center = true,
	no_screen_share = true,
})

hl.window_rule({
	name = "onepassword-private",
	match = {
		class = "^(1password)$",
	},
	no_screen_share = true,
})

hl.window_rule({
	name = "onepassword-private-popup",
	match = {
		class = "^(1password)$",
		float = true,
	},
	center = true,
	pin = true,
	stay_focused = true,
	no_screen_share = true,
})

hl.window_rule({
	name = "private-title-windows",
	match = {
		title = "^(vesktop|swayosd|qbittorrent)$",
	},
	no_screen_share = true,
})

hl.window_rule({
	name = "gcr-prompter-private",
	match = {
		class = "^gcr-prompter$",
	},
	no_screen_share = true,
	pin = true,
	stay_focused = true,
})

-- Layer rules

hl.layer_rule({
	name = "walker",
	match = {
		namespace = "walker",
	},
	no_anim = true,
	blur = true,
	ignore_alpha = 0.4,
})

hl.layer_rule({
	name = "swaync-control-center",
	match = {
		namespace = "swaync-control-center",
	},
	animation = "slide right",
	blur = true,
	ignore_alpha = 0.1,
})

hl.layer_rule({
	name = "swww-daemon",
	match = {
		namespace = "swww-daemon",
	},
	animation = "gnomed 88",
})

-- Blur

hl.layer_rule({
	name = "waybar-blur",
	match = {
		namespace = "waybar",
	},
	blur = true,
	ignore_alpha = 0,
})

hl.layer_rule({
	name = "swaylock-blur",
	match = {
		namespace = "swaylock",
	},
	blur = true,
})

hl.layer_rule({
	name = "notifications-blur",
	match = {
		namespace = "notifications",
	},
	blur = true,
})

hl.layer_rule({
	name = "anyrun-blur",
	match = {
		namespace = "anyrun",
	},
	blur = true,
	ignore_alpha = 0,
})

hl.layer_rule({
	name = "gtk-layer-shell",
	match = {
		namespace = "gtk-layer-shell",
	},
	ignore_alpha = 0,
})

hl.layer_rule({
	name = "swaync-notification-window-blur",
	match = {
		namespace = "swaync-notification-window",
	},
	blur = true,
	ignore_alpha = 0.1,
})

hl.layer_rule({
	name = "swayosd-blur",
	match = {
		namespace = "swayosd",
	},
	blur = true,
	ignore_alpha = 0.1,
})

-- NWG-Panel
-- layer_rule({ match = { namespace = "gtk-layer-shell" }, blur = true })
-- layer_rule({ match = { namespace = "gtk-layer-shell" }, xray = true })
