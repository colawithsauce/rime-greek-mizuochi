local M = {}

local function join_path(base, name)
	if base == nil or base == "" then return name end
	local sep = "/"
	if base:find("\\") then sep = "\\" end
	return base .. sep .. name
end

local function is_ascii_letter(ch)
	return ch:match("^[A-Za-z]$") ~= nil
end

local function is_base_code(ch)
	return is_ascii_letter(ch) and ch ~= "q" and ch ~= "Q"
end

local function semantic_key(code)
	if code == "q" then return "punct=q" end
	if code == "Q" then return "punct=Q" end
	if code == "" then return nil end

	local base = code:sub(1, 1)
	if not is_base_code(base) then return nil end

	local breath = ""
	local accent = ""
	local iota = false
	local diaeresis = false

	for i = 2, #code do
		local ch = code:sub(i, i)
		if ch == '"' or ch == "q" then
			if breath ~= "" then return nil end
			breath = "rough"
		elseif ch == "'" or ch == "Q" then
			if breath ~= "" then return nil end
			breath = "smooth"
		elseif ch == "/" then
			if accent ~= "" then return nil end
			accent = "acute"
		elseif ch == "?" then
			if accent ~= "" then return nil end
			accent = "grave"
		elseif ch == "^" or ch == "\\" then
			if accent ~= "" then return nil end
			accent = "circumflex"
		elseif ch == "J" then
			if iota then return nil end
			iota = true
		elseif ch == ":" then
			if diaeresis then return nil end
			diaeresis = true
		else
			return nil
		end
	end

	return table.concat({
		"base=" .. base,
		"breath=" .. breath,
		"accent=" .. accent,
		"iota=" .. (iota and "1" or "0"),
		"diaeresis=" .. (diaeresis and "1" or "0"),
	}, ";")
end

M.semantic_key = semantic_key

local function load_codes(dict_name)
	local state = {
		code_to_text = {},
		key_to_text = {},
	}
	local paths = {
		join_path(rime_api.get_user_data_dir(), dict_name .. ".dict.yaml"),
		join_path(rime_api.get_shared_data_dir(), dict_name .. ".dict.yaml"),
	}

	for _, path in ipairs(paths) do
		local file = io.open(path, "r")
		if file then
			local in_body = false
			for line in file:lines() do
				if in_body then
					local text, code = line:match("^([^\t]+)\t([^\t]+)")
					if text and code then
						state.code_to_text[code] = state.code_to_text[code] or text
						local key = semantic_key(code)
						if key then
							state.key_to_text[key] = state.key_to_text[key] or text
						end
					end
				elseif line:match("^%.%.%.%s*$") then
					in_body = true
				end
			end
			file:close()
			return state
		end
	end

	return state
end

function M.get_state(env)
	if env.greek_mizuochi_state then return env.greek_mizuochi_state end
	local config = env.engine.schema.config
	local dict_name = config:get_string("translator/dictionary") or "greek_mizuochi"
	env.greek_mizuochi_state = load_codes(dict_name)
	return env.greek_mizuochi_state
end

function M.compose(state, code)
	local key = semantic_key(code)
	if key and state.key_to_text[key] then
		return state.key_to_text[key]
	end
	return state.code_to_text[code]
end

return M
