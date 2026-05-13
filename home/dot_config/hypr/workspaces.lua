local vars = require("variables")
local mod = vars.main_mod

hl.workspace_rule({
	workspace = "2",
	on_created_empty = "brave",
})

hl.workspace_rule({
	workspace = "5",
	on_created_empty = "moo",
})

hl.bind(
	mod .. " + n",
	hl.dsp.window.move({ workspace = "special:scratchpad" }),
	{ description = "Move window to scratchpad" }
)

hl.bind(mod .. " + m", hl.dsp.workspace.toggle_special("scratchpad"), { description = "Toggle scratchpad" })

hl.workspace_rule({
	workspace = "special:scratchpad",
	on_created_empty = "kitty",
})
