---@class (exact) SetupMonitorSpec : HL.MonitorSpec
---@field optional? boolean

---@alias MonitorSetup SetupMonitorSpec[]

---@type MonitorSetup[]
local setups = {
	{
		{
			output = "desc:LG Electronics LG HDR 4K 102NTKFG7893",
			mode = "preferred",
			position = "auto",
			scale = 1.6,
		},
		{
			output = "desc:LG Display 0x06EA",
			mode = "2560x1600@60.0",
			position = "auto",
			disabled = true,
		},
	},

	{
		{
			output = "eDP-1",
			mode = "preferred",
			position = "auto",
			scale = 1.6,
		},
	},


	{
		{
			output = "desc:LG Electronics LG HDR 4K 102NTKFG7893",
			mode = "preferred",
			position = "auto",
			scale = 1.5,
		},
	},
}

---@type MonitorSetup
local defaultSetup = {
	{
		output = "eDP-1",
		mode = "2560x1600@60.0",
		position = "4140x0",
		scale = 1.6,
	},
	{
		output = "",
		mode = "preferred",
		position = "auto",
	},
}

---@param monitors HL.Monitor[]
---@return table<string, true>
local function getConnectedOutputs(monitors)
	local outputs = {}

	for _, monitor in ipairs(monitors) do
		outputs[monitor.name] = true
		outputs["desc:" .. monitor.description] = true
	end

	return outputs
end

---@param setup MonitorSetup
---@param connectedOutputs table<string, true>
---@return boolean matches
---@return integer score
local function scoreSetup(setup, connectedOutputs)
	local score = 0

	for _, spec in ipairs(setup) do
		if spec.output ~= "" then
			local matches = connectedOutputs[spec.output] == true

			if matches then
				score = score + 1
			elseif not spec.optional then
				return false, 0
			end
		end
	end

	return true, score
end

---@param monitors HL.Monitor[]
---@return MonitorSetup
local function getPreferredSetup(monitors)
	local connectedOutputs = getConnectedOutputs(monitors)
	local bestSetup = defaultSetup
	local bestScore = -1

	for _, setup in ipairs(setups) do
		local matches, score = scoreSetup(setup, connectedOutputs)

		if matches and score > bestScore then
			bestSetup = setup
			bestScore = score
		end
	end

	return bestSetup
end

---@param spec SetupMonitorSpec
---@return HL.MonitorSpec
local function toMonitorSpec(spec)
	---@type HL.MonitorSpec
	local monitorSpec = {}

	for key, value in pairs(spec) do
		if key ~= "optional" then
			monitorSpec[key] = value
		end
	end

	return monitorSpec
end

local lastAppliedSetupKey = nil

---@param setup MonitorSetup
---@return string
local function getSetupKey(setup)
	local parts = {}

	for _, spec in ipairs(setup) do
		parts[#parts + 1] = table.concat({
			spec.output or "",
			spec.mode or "",
			spec.position or "",
			tostring(spec.scale or ""),
			tostring(spec.disabled or false),
		}, "|")
	end

	return table.concat(parts, "\n")
end

---@param monitors HL.Monitor[]
---@return string
local function getConnectedOutputsKey(monitors)
	local outputs = {}

	for output in pairs(getConnectedOutputs(monitors)) do
		outputs[#outputs + 1] = output
	end

	table.sort(outputs)

	return table.concat(outputs, "\n")
end

local function applyPreferredSetup()
	local monitors = hl.get_monitors()
	local setup = getPreferredSetup(monitors)
	local setupKey = getConnectedOutputsKey(monitors) .. "\n--setup--\n" .. getSetupKey(setup)

	if setupKey == lastAppliedSetupKey then
		return
	end

	lastAppliedSetupKey = setupKey

	for _, monitor in ipairs(setup) do
		hl.monitor(toMonitorSpec(monitor))
	end
end

local applyTimer = hl.timer(applyPreferredSetup, { timeout = 50, type = "oneshot" })
applyTimer:set_enabled(false)

local function scheduleApplyPreferredSetup()
	applyTimer:set_enabled(false)
	applyTimer:set_enabled(true)
end

hl.on("monitor.added", scheduleApplyPreferredSetup)
hl.on("monitor.removed", scheduleApplyPreferredSetup)

applyPreferredSetup()
