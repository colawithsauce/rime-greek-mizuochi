local core = require("greek_mizuochi_core")
local kNoop = 2

local function init(env)
	core.get_state(env)
end

local function current_commit_text(context, fallback)
	local text = context:get_commit_text()
	if text and text ~= "" then return text end
	return fallback
end

local function processor(key, env)
	if key:release() or key:ctrl() or key:alt() then return kNoop end

	local ch = key.keycode
	if ch < 0x21 or ch > 0x7e then return kNoop end
	if ch >= 0x30 and ch <= 0x39 then return kNoop end

	local next_char = string.char(ch)
	local context = env.engine.context
	local input = context.input
	if input == "" then return kNoop end

	local state = core.get_state(env)
	local text = core.compose(state, input)
	if not text then return kNoop end
	local next_input = input .. next_char
	if core.compose(state, next_input) then return kNoop end

	local commit_text = current_commit_text(context, text)
	context:clear()
	env.engine:commit_text(commit_text)
	return kNoop
end

return { init = init, func = processor }
