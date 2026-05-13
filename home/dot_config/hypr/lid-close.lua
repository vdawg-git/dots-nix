hl.bind(
	"switch:on:Lid Switch",
	hl.dsp.exec_cmd([[hyprctl keyword monitor "eDP-1, disable"]]),
	{ locked = true, description = "Disable internal monitor on lid close" }
)

hl.bind(
	"switch:off:Lid Switch",
	hl.dsp.exec_cmd("hyprctl reload"),
	{ locked = true, description = "Reload on lid open" }
)
