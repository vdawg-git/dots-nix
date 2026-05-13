-- Shared Lua values for Hyprland config files.

---@class HyprVariables
---@field main_mod string
---@field font_family string
---@field font_family_clock string
---@field colors table<string, string>

---@type HyprVariables
local variables = {
	main_mod = "SUPER",

	font_family = "Monaspace Argon",
	font_family_clock = "Monaspace Argon Medium",

	colors = {
		fg0 = "rgb(ddc7a1)",
		fg = "rgb(d4be98)",
		fg1 = "rgb(c5b18d)",

		red = "rgb(ea6962)",
		orange = "rgb(e78a4e)",
		yellow = "rgb(d8a657)",
		green = "rgb(a9b665)",
		aqua = "rgb(89b482)",
		blue = "rgb(7daea3)",
		purple = "rgb(d3869b)",

		dim_red = "rgb(b85651)",
		dim_orange = "rgb(bd6f3e)",
		dim_yellow = "rgb(c18f41)",
		dim_green = "rgb(8f9a52)",
		dim_aqua = "rgb(72966c)",
		dim_blue = "rgb(68948a)",
		dim_purple = "rgb(ab6c7d)",

		bg0 = "rgb(101010)",
		bg1 = "rgb(1c1c1c)",
		bg = "rgb(292828)",
		bg2 = "rgb(32302f)",
		bg3 = "rgb(383432)",
		bg4 = "rgb(3c3836)",
		bg5 = "rgb(45403d)",
		bg6 = "rgb(504945)",
		bg7 = "rgb(5a524c)",
		bg8 = "rgb(665c54)",
		bg9 = "rgb(7c6f64)",

		grey0 = "rgb(7c6f64)",
		grey1 = "rgb(928374)",
		grey2 = "rgb(a89984)",
	},
}

vars = variables

return variables
