local vars = require("variables")
local mod = vars.main_mod

hl.bind(
	mod .. " + a",
	hl.dsp.exec_cmd("wl-kbptr -o modes=floating,click -o mode_floating.source=detect"),
	{ description = "Start wl-kbptr floating mode" }
)

hl.bind(
	mod .. " + SHIFT + a",
	hl.dsp.exec_cmd("wl-kbptr -o modes=tile,bisect,click"),
	{ description = "Start wl-kbptr tile mode" }
)

hl.layer_rule({
	name = "wl-kbptr",
	match = {
		namespace = "selection",
	},
	no_anim = true,
})
