---@class Rules.Regex
---@field __kind "rx"
---@field pattern string

---@alias Rules.Pattern string|Rules.Regex|(string|Rules.Regex)[]
---@alias Rules.Match table<string, Rules.Pattern|number|boolean>

---@class Rules.WindowRule: HL.WindowRuleSpec
---@field name string
---@field match? Rules.Match
---@field any? table<string, Rules.Pattern>

---@class Rules.LayerRule: HL.LayerRuleSpec
---@field name string
---@field match? Rules.Match
---@field any? table<string, Rules.Pattern>

---@class Rules.Helper
---@field rx fun(pattern: string): Rules.Regex
---@field windowRules fun(rules: Rules.WindowRule[])
---@field layerRules fun(rules: Rules.LayerRule[])

---@param pattern string
---@return Rules.Regex
local function rx(pattern)
	return { __kind = "rx", pattern = pattern }
end

---@type table<string, true>
local patternKeys = {
	class = true,
	title = true,
	initialClass = true,
	initialTitle = true,
	tag = true,
	workspace = true,
	namespace = true,
}

---@param value unknown
---@return boolean
local function isRx(value)
	return type(value) == "table" and value.__kind == "rx"
end

---@param s string
---@return string
local function escapeRegex(s)
	return tostring(s):gsub("([%^%$%(%)%%%.%[%]%*%+%-%?%{%}%|])", function(char)
		return "\\" .. char
	end)
end

---@param s string
---@return string
local function compileExact(s)
	return "^(?i:" .. escapeRegex(s) .. ")$"
end

---@param value string|Rules.Regex
---@return string
local function compileOne(value)
	if isRx(value) then
		---@cast value Rules.Regex
		return value.pattern
	end

	---@cast value string
	return compileExact(value)
end

---@param values Rules.Pattern
---@return string
local function compileList(values)
	if type(values) ~= "table" or isRx(values) then
		return compileOne(values)
	end

	if #values == 0 then
		error("empty matcher list")
	end

	local parts = {}
	for _, value in ipairs(values) do
		table.insert(parts, compileOne(value))
	end

	return table.concat(parts, "|")
end

---@param match Rules.Match|nil
---@return table<string, string|number|boolean>
local function compileMatch(match)
	local out = {}

	for key, value in pairs(match or {}) do
		if patternKeys[key] then
			out[key] = compileList(value)
		else
			out[key] = value
		end
	end

	return out
end

---@param tbl table
---@return table
local function copy(tbl)
	local out = {}
	for key, value in pairs(tbl) do
		out[key] = value
	end
	return out
end

---@param rule Rules.WindowRule|Rules.LayerRule
---@return table
local function ruleOptions(rule)
	local opts = {}

	for key, value in pairs(rule) do
		if key ~= "any" and key ~= "match" then
			opts[key] = value
		end
	end

	return opts
end

---@param kind string
---@param rule Rules.WindowRule|Rules.LayerRule
local function validateRule(kind, rule)
	if not rule.name then
		error(kind .. ": rule missing name")
	end

	if not rule.match and not rule.any then
		error(kind .. ": rule '" .. tostring(rule.name) .. "' needs match or any")
	end
end

---@param kind string
---@param rule Rules.WindowRule|Rules.LayerRule
local function validateAny(kind, rule)
	if not rule.any then
		return
	end

	for key, _ in pairs(rule.any) do
		if not patternKeys[key] then
			error(kind .. ": rule '" .. tostring(rule.name) .. "' has invalid any key: " .. tostring(key))
		end
	end
end

---@param rules Rules.WindowRule[]
local function windowRules(rules)
	for _, rule in ipairs(rules) do
		validateRule("windowRules", rule)
		validateAny("windowRules", rule)

		local opts = ruleOptions(rule)

		if rule.match then
			local emitted = copy(opts)
			emitted.match = compileMatch(rule.match)
			hl.window_rule(emitted)
		end

		if rule.any then
			for key, values in pairs(rule.any) do
				local emitted = copy(opts)
				emitted.name = rule.name .. "-" .. key
				emitted.match = {
					[key] = compileList(values),
				}
				hl.window_rule(emitted)
			end
		end
	end
end

---@param rules Rules.LayerRule[]
local function layerRules(rules)
	for _, rule in ipairs(rules) do
		validateRule("layerRules", rule)
		validateAny("layerRules", rule)

		local opts = ruleOptions(rule)

		if rule.match then
			local emitted = copy(opts)
			emitted.match = compileMatch(rule.match)
			hl.layer_rule(emitted)
		end

		if rule.any then
			for key, values in pairs(rule.any) do
				local emitted = copy(opts)
				emitted.name = rule.name .. "-" .. key
				emitted.match = {
					[key] = compileList(values),
				}
				hl.layer_rule(emitted)
			end
		end
	end
end

---@type Rules.Helper
return {
	rx = rx,
	windowRules = windowRules,
	layerRules = layerRules,
}
