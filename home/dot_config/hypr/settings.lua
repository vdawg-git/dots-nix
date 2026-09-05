-- Hyprland 0.55+ Lua syntax: https://wiki.hypr.land/Configuring/Basics/Variables/

hl.config({
	input = {
		kb_layout = "us,gr",
		kb_options = "compose:ralt",
		natural_scroll = true,
		float_switch_override_focus = 2,

		repeat_rate = 50,
		repeat_delay = 250,

		follow_mouse = 1,
		accel_profile = "flat",
		sensitivity = 0.0,

		touchpad = {
			natural_scroll = true,
			clickfinger_behavior = true,
			disable_while_typing = true,
		},
	},

	general = {
		layout = "dwindle",
		gaps_in = 4,
		gaps_out = 8,
		gaps_workspaces = 20,
		border_size = 1,
		["col.active_border"] = {
			colors = {
				"rgba(212,190,152,0.70)",
				"rgba(212,190,152,0.30)",
			},
			angle = 40,
		},
		["col.inactive_border"] = "rgba(168,153,132,0.15)",
		resize_on_border = true,

		snap = {
			enabled = true,
			window_gap = 4,
			monitor_gap = 5,
			respect_gaps = true,
		},
	},

	decoration = {
		rounding = 22,
		rounding_power = 4,

		dim_inactive = false,
		dim_special = 0.5,
		dim_strength = 0.06,

		border_part_of_window = false,

		blur = {
			enabled = true,
			size = 10,
			passes = 3,
			new_optimizations = true,
			xray = false,
			contrast = 0.9,
			brightness = 0.9,
			noise = 0.4,
			vibrancy = 2,
			vibrancy_darkness = 0.2,
			special = false,
			popups = true,
			popups_ignorealpha = 0.6,
		},

		shadow = {
			enabled = true,
			range = 120,
			scale = 0.95,
			render_power = 80,
			offset = { 0, 4 },
			color = "rgba(000000FC)",
			color_inactive = "rgba(00000050)",
		},
	},

	animations = {
		enabled = true,
		workspace_wraparound = false,
	},

	dwindle = {
		preserve_split = true,
		special_scale_factor = 0.8,
	},

	binds = {
		workspace_back_and_forth = false,
		allow_workspace_cycles = true,
	},

	ecosystem = {
		no_donation_nag = true,
	},

	misc = {
		disable_splash_rendering = true,
		force_default_wallpaper = 0,
		disable_hyprland_logo = true,
		focus_on_activate = false,
		animate_manual_resizes = true,
		close_special_on_empty = true,
		enable_swallow = false,
		swallow_regex = "^(kitty)$",
	},
})

---@param value any
---@return number|nil
---@return number|nil
local function getMonitorSizePair(value)
	return value.x or value[1], value.y or value[2]
end

---@param monitor HL.Monitor
---@return boolean
local function isBigMonitor(monitor)
	local physicalWidthMm, physicalHeightMm = getMonitorSizePair(monitor.size)

	if physicalWidthMm and physicalHeightMm and physicalWidthMm < 2000 and physicalHeightMm < 2000 then
		local diagonalInches = math.sqrt(physicalWidthMm ^ 2 + physicalHeightMm ^ 2) / 25.4

		return diagonalInches >= 24
	end

	local effectiveWidth = monitor.width / monitor.scale
	local effectiveHeight = monitor.height / monitor.scale

	return effectiveWidth >= 2400 and effectiveHeight >= 1350
end

local function getSingleTiledWindowGap()
	for _, monitor in ipairs(hl.get_monitors()) do
		if isBigMonitor(monitor) then
			return 40
		end
	end

	return 24
end

-- More space if there is only one tiled window.
local function applySingleTiledWindowGap()
	hl.workspace_rule({ workspace = "w[t1]", gaps_out = getSingleTiledWindowGap() })
end

hl.on("monitor.added", applySingleTiledWindowGap)
hl.on("monitor.removed", applySingleTiledWindowGap)
applySingleTiledWindowGap()

-- Animation curves

hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("md3_standard", { type = "bezier", points = { { 0.2, 0 }, { 0, 1 } } })
hl.curve("md3_decel", { type = "bezier", points = { { 0.05, 0.7 }, { 0.1, 1 } } })
hl.curve("md3_accel", { type = "bezier", points = { { 0.3, 0 }, { 0.8, 0.15 } } })
hl.curve("overshot", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.1 } } })
hl.curve("crazyshot", { type = "bezier", points = { { 0.1, 1.5 }, { 0.76, 0.92 } } })
hl.curve("hyprnostretch", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.0 } } })
hl.curve("menu_decel", { type = "bezier", points = { { 0.1, 1 }, { 0, 1 } } })
hl.curve("menu_accel", { type = "bezier", points = { { 0.38, 0.04 }, { 1, 0.07 } } })
hl.curve("easeInOutCirc", { type = "bezier", points = { { 0.85, 0 }, { 0.15, 1 } } })
hl.curve("easeOutCirc", { type = "bezier", points = { { 0, 0.55 }, { 0.45, 1 } } })
hl.curve("easeOutExpo", { type = "bezier", points = { { 0.16, 1 }, { 0.3, 1 } } })
hl.curve("softAcDecel", { type = "bezier", points = { { 0.26, 0.26 }, { 0.15, 1 } } })
hl.curve("md2", { type = "bezier", points = { { 0.4, 0 }, { 0.2, 1 } } })
hl.curve("bounce", {type = "spring", mass = 1.05, stiffness = 450, dampening = 30 })
hl.curve("windows-general", {type = "spring", mass = 1.15, stiffness = 100, dampening = 15 })
hl.curve("specialIn", {type = "spring", mass = 1, stiffness = 800, dampening = 42 })

-- Animation configs

hl.animation({ leaf = "windows", enabled = true, speed = 1, bezier = "md3_decel", style = "popin 60%" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 1.5, spring = "bounce",  style = "popin 60%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 0.8, bezier = "md3_accel", style = "popin 60%" })
hl.animation({ leaf = "border", enabled = false, speed = 0.2, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 3, bezier = "md3_decel" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "menu_decel", style = "slide" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.2, bezier = "menu_accel" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 2, bezier = "menu_decel" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 0.5, bezier = "menu_accel" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "menu_decel", style = "slide" })
hl.animation({ leaf = "specialWorkspaceIn", enabled = true, speed = 4, spring = "specialIn", style = "slidevert" })
hl.animation({ leaf = "specialWorkspaceOut", enabled = true, speed = 1.2, bezier = "md3_decel", style = "slidevert" })
