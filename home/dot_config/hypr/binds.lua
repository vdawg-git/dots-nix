local vars = require("variables")
local mod = vars.main_mod

hl.bind(mod .. " + Q", hl.dsp.window.kill(), { description = "Kill active window" })
hl.bind(mod .. " + W", hl.dsp.window.float(), { description = "Toggle floating" })
hl.bind(mod .. " + return", hl.dsp.window.fullscreen(), { description = "Toggle fullscreen" })

hl.bind(mod .. " + T", hl.dsp.exec_cmd("kitty"), { description = "Open terminal" })
hl.bind(mod .. " + E", hl.dsp.exec_cmd("nautilus --new-window"), { description = "Open file manager" })
hl.bind("CTRL + space", hl.dsp.exec_cmd("vicinae toggle"), { description = "Toggle launcher" })
hl.bind(mod .. " + V", hl.dsp.layout("togglesplit"), { description = "Toggle dwindle split" })

hl.bind(mod .. " + X", hl.dsp.exec_cmd("hyprlock"), { description = "Lock screen" })
hl.bind(
	"switch:on:Lid Switch",
	hl.dsp.exec_cmd("[ $(hyprctl monitors -j | jq 'length') -le 1 ] && hyprlock && systemctl suspend"),
	{ locked = true, description = "Suspend on lid close" }
)

hl.bind(
	mod .. " + S",
	hl.dsp.exec_cmd([[grim -g "$(slurp -w 0)" - | satty -f - -o -]]),
	{ description = "Screenshot region" }
)
hl.bind(
	mod .. " + CTRL + S",
	hl.dsp.exec_cmd("grim - | satty -f - --fullscreen --initial-tool crop -o -"),
	{ description = "Screenshot screen" }
)

hl.bind(
	mod .. " + code:60",
	hl.dsp.exec_cmd("swaync-client -rs && swaync-client -t"),
	{ description = "Toggle notification center" }
)

hl.bind(
	mod .. " + ALT + C",
	hl.dsp.exec_cmd("~/.config/hypr/scripts/ocr-region.sh"),
	{ description = "OCR selected region" }
)

hl.bind(
	mod .. " + ALT + SHIFT + C",
	hl.dsp.exec_cmd("~/.config/hypr/scripts/ocr-region.sh deu"),
	{ description = "OCR selected region in German" }
)

hl.bind(
	mod .. " + ALT + H",
	hl.dsp.exec_cmd("~/.config/hypr/scripts/toggle-hyprsunset.sh"),
	{ description = "Toggle Hyprsunset" }
)

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("swayosd-client --output-volume raise"), { locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("swayosd-client --output-volume lower"), { locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("swayosd-client --input-volume mute-toggle"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("swayosd-client --brightness raise"), { locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("swayosd-client --brightness lower"), { locked = true })

hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("swayosd-client --playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("swayosd-client --playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("swayosd-client --playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("swayosd-client --playerctl previous"), { locked = true })

hl.bind(mod .. " + left", hl.dsp.focus({ direction = "l" }))
hl.bind(mod .. " + right", hl.dsp.focus({ direction = "r" }))
hl.bind(mod .. " + up", hl.dsp.focus({ direction = "u" }))
hl.bind(mod .. " + down", hl.dsp.focus({ direction = "d" }))

hl.bind(mod .. " + y", hl.dsp.focus({ workspace = "1" }))
hl.bind(mod .. " + u", hl.dsp.focus({ workspace = "2" }))
hl.bind(mod .. " + i", hl.dsp.focus({ workspace = "3" }))
hl.bind(mod .. " + o", hl.dsp.focus({ workspace = "4" }))
hl.bind(mod .. " + p", hl.dsp.focus({ workspace = "5" }))
hl.bind(mod .. " + bracketleft", hl.dsp.focus({ workspace = "6" }))

hl.bind(mod .. " + SHIFT + y", hl.dsp.window.move({ workspace = "1" }))
hl.bind(mod .. " + SHIFT + u", hl.dsp.window.move({ workspace = "2" }))
hl.bind(mod .. " + SHIFT + i", hl.dsp.window.move({ workspace = "3" }))
hl.bind(mod .. " + SHIFT + o", hl.dsp.window.move({ workspace = "4" }))
hl.bind(mod .. " + SHIFT + p", hl.dsp.window.move({ workspace = "5" }))
hl.bind(mod .. " + SHIFT + bracketleft", hl.dsp.window.move({ workspace = "6" }))

hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mod .. " + L", hl.dsp.focus({ workspace = "m+1" }))
hl.bind(mod .. " + H", hl.dsp.focus({ workspace = "m-1" }))

hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + SHIFT + mouse:272", hl.dsp.window.resize(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind(mod .. " + SHIFT + j", hl.dsp.window.move({ direction = "d" }))
hl.bind(mod .. " + SHIFT + k", hl.dsp.window.move({ direction = "u" }))
hl.bind(mod .. " + SHIFT + h", hl.dsp.window.move({ direction = "l" }))
hl.bind(mod .. " + SHIFT + l", hl.dsp.window.move({ direction = "r" }))

hl.bind(mod .. " + SHIFT + ALT + h", hl.dsp.workspace.move({ monitor = "-1" }))
hl.bind(mod .. " + SHIFT + ALT + l", hl.dsp.workspace.move({ monitor = "+1" }))

hl.bind(mod .. " + ALT + right", hl.dsp.window.resize({ x = 24, y = 0, relative = true }), { repeating = true })
hl.bind(mod .. " + ALT + left", hl.dsp.window.resize({ x = -24, y = 0, relative = true }), { repeating = true })
hl.bind(mod .. " + ALT + up", hl.dsp.window.resize({ x = 0, y = -24, relative = true }), { repeating = true })
hl.bind(mod .. " + ALT + down", hl.dsp.window.resize({ x = 0, y = 24, relative = true }), { repeating = true })

hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
	scale = 1,
})

hl.gesture({
	fingers = 4,
	direction = "vertical",
	action = "special",
	workspace_name = "scratchpad",
})

hl.gesture({
	fingers = 3,
	direction = "vertical",
	action = "move",
	mods = mod,
})

hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "move",
	mods = mod,
})

hl.gesture({
	fingers = 4,
	direction = "right",
	action = function()
		hl.dispatch(hl.dsp.exec_cmd([[notify-send "hii"]]))
	end,
})

hl.gesture({
	fingers = 4,
	direction = "left",
	action = function()
		hl.dispatch(hl.dsp.exec_cmd("swayosd-client --playerctl previous"))
	end,
})

hl.config({
	gestures = {
		workspace_swipe_distance = 100,
		workspace_swipe_cancel_ratio = 0.2,
		workspace_swipe_invert = true,
		workspace_swipe_direction_lock = false,
	},
})
