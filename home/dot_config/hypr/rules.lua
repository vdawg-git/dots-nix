-- Window rules
-- Hyprland 0.55+ Lua syntax: https://wiki.hypr.land/Configuring/Basics/Window-Rules/

local rules = require("helper.rules")
local windowRules, layerRules, rx = rules.windowRules, rules.layerRules, rules.rx



windowRules({
	-- Floats

	{
		name = "floats",
		any = {
			class = {
				"org.kde.ark",
				"net.davidotek.pupgui2", -- ProtonUp-Qt
				"yad", -- Protontricks-Gtk
				"pavucontrol",
				"blueman-manager",
				"org.pulseaudio.pavucontrol",
				"nm-applet",
				"nm-connection-editor",
				"org.kde.polkit-kde-authentication-agent-1",
				"file-roller",
				"xdg-desktop-portal-gtk",
				"it.mijorus.smile",
				"fsearch", -- FSearch
				"eog", -- Image viewer
				"Mojosetup", -- GOG games installer
				"com.rafaelmardojai.Blanket",
				"io.gitlab.adhami3310.Converter",
				"com.gabm.satty",
				"org.gnome.FileRoller",
				"nwg-displays",
				"com-evacipated-cardcrawl-modthespire-Loader",
			},
			title = {
				"Media viewer",
				"org.kde.haruna",
				"Open File",
				"Create Automatic Playlist",
				"Nextcloud",
				rx("^wlroots - WL"),
			},
		},
		float = true,
	},

	{
		name = "codium-add-folder-dialog",
		match = {
			class = { "codium", "codium-url-handler", "VSCodium" },
			title = "Add Folder to Workspace",
		},
		float = true,
	},
	{
		name = "polkit-authentication-dialogs",
		any = {
			class = { "xfce-polkit", "mate-polkit", "polkit-mate-authentication-agent-1", "gcr-prompter"  },
			title = "Authentication required",
		},
		float = true,
		center = true,
		pin = true,
		stay_focused = true,
		no_screen_share = true,
	},
	{
		name = "steam-child-windows",
		match = {
			class = "steam",
			title = rx("negative:^([Ss]team)$"),
		},
		float = true,
	},
	{
		name = "floating-video-players",
		match = {
			class = { "mpv", "com.github.rafostar.Clapper" },
		},
		float = true,
	},
	{
		name = "fullscreen-idle-inhibit",
		match = {
			fullscreen = true,
		},
		idle_inhibit = "fullscreen",
	},

	-- App-specific dialog polish

	{
		name = "pavucontrol-centered",
		match = {
			class = { "org.pulseaudio.pavucontrol", "pavucontrol" },
		},
		float = true,
		center = true,
		pin = true,
		size = { "700", "600" },
	},
	{
		name = "blueman-manager-sized",
		match = {
			class = "blueman-manager",
		},
		float = true,
		center = true,
		size = { "800", "600" },
	},
	{
		name = "nwg-look",
		match = {
			class = "nwg-look",
		},
		float = true,
		center = true,
		size = { "700", "600" },
	},
	{
		name = "nwg-displays-sized",
		match = {
			class = "nwg-displays",
		},
		float = true,
		center = true,
		size = { "900", "600" },
	},
	{
		name = "missioncenter",
		match = {
			class = "io.missioncenter.MissionCenter",
		},
		float = true,
		center = true,
		pin = true,
		size = { "900", "600" },
	},
	{
		name = "gnome-calculator",
		match = {
			class = "org.gnome.Calculator",
		},
		float = true,
		center = true,
		size = { "700", "600" },
	},
	{
		name = "hyprland-share-picker",
		match = {
			class = "hyprland-share-picker",
		},
		float = true,
		center = true,
		pin = true,
		size = { "600", "400" },
	},
	{
		name = "easyeffects",
		match = {
			class = "com.github.wwmm.easyeffects",
		},
		float = true,
		center = true,
		size = { "(monitor_w*0.6)", "(monitor_h*0.65)" },
	},
	{
		name = "hyprpwcenter",
		match = {
			class = "hyprpwcenter",
		},
		float = true,
		center = true,
		size = { "(monitor_w*0.6)", "(monitor_h*0.6)" },
	},

	-- Picture-in-Picture

	{
		name = "picture-in-picture",
		match = {
			title = rx("^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$"),
		},
		float = true,
		keep_aspect_ratio = true,
		move = { "(monitor_w*0.73)", "(monitor_h*0.72)" },
		size = { "(monitor_w*0.25)", "(monitor_h*0.25)" },
		pin = true,
	},

	-- Dialogs

	{
		name = "centered-dialogs",
		match = {
			title = rx("^(Open File|Select a File|Choose wallpaper|Open Folder|Save As|Library|File Upload)(.*)$"),
		},
		float = true,
		center = true,
	},

	-- Privacy and security

	{
		name = "bitwarden-private",
		any = {
			class = "bitwarden",
			title = "Bitwarden",
		},
		float = true,
		center = true,
		no_screen_share = true,
	},
	{
		name = "no-screen-share",
		any = {
			class = { "org.keepassxc.KeePassXC", "KeePassXC", "keepassxc" ,"1password",  "vesktop", "swayosd", "qbittorrent" ,
		},
		},
		no_screen_share = true,
	},
	{
		name = "seahorse-private",
		match = {
			class = { "seahorse", "org.gnome.seahorse.Application" },
		},
		float = true,
		center = true,
		no_screen_share = true,
	},
	{
		name = "onepassword-private-popup",
		match = {
			class = "1password",
			float = true,
		},
		center = true,
		pin = true,
		stay_focused = true,
		no_screen_share = true,
	}

})

layerRules({
	-- Layer rules

	{
		name = "walker",
		match = {
			namespace = "walker",
		},
		no_anim = true,
		blur = true,
		ignore_alpha = 0.4,
	},
	{
		name = "swaync-control-center",
		match = {
			namespace = "swaync-control-center",
		},
		animation = "slide right",
		blur = true,
		ignore_alpha = 0.1,
	},
	{
		name = "swww-daemon",
		match = {
			namespace = "swww-daemon",
		},
		animation = "gnomed 88",
	},

	-- Blur

	{
		name = "waybar-blur",
		match = {
			namespace = "waybar",
		},
		blur = true,
		ignore_alpha = 0,
	},
	{
		name = "swaylock-blur",
		match = {
			namespace = "swaylock",
		},
		blur = true,
	},
	{
		name = "notifications-blur",
		match = {
			namespace = "notifications",
		},
		blur = true,
	},
	{
		name = "anyrun-blur",
		match = {
			namespace = "anyrun",
		},
		blur = true,
		ignore_alpha = 0,
	},
	{
		name = "gtk-layer-shell",
		match = {
			namespace = "gtk-layer-shell",
		},
		ignore_alpha = 0,
	},
	{
		name = "swaync-notification-window-blur",
		match = {
			namespace = "swaync-notification-window",
		},
		blur = true,
		ignore_alpha = 0.1,
	},
	{
		name = "swayosd-blur",
		match = {
			namespace = "swayosd",
		},
		blur = true,
		ignore_alpha = 0.1,
	},

})
