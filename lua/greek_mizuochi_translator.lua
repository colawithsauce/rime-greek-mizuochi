local core = require("greek_mizuochi_core")

local help_input = ";help"
local help_rows = {
	{ "字母", "a α, b β, g γ, d δ, e ε, h η, i ι, k κ" },
	{ "大写", "Shift 同码：A Α, B Β, G Γ, D Δ, E Ε" },
	{ "送气", "q 或 \"：aq ἁ, e\" ἑ, r\" ῥ" },
	{ "不送气", "Q 或 '：aQ ἀ, eQ ἐ, rQ ῤ" },
	{ "重音", "/ 锐音，? 钝音，^ 或 \\ 曲音" },
	{ "附标", "J 下标 iota；: 分音符" },
	{ "顺序自由", "aJq/ = aq/J = a/qJ = ᾅ" },
	{ "标点", "单独 q = ·；单独 Q = ;" },
	{ "自动提交", "不可继续组合时上屏：eq/k -> ἕκ" },
	{ "帮助", ";help" },
}

local function translator(input, seg, env)
	if input == help_input then
		for _, row in ipairs(help_rows) do
			yield(Candidate("greek_mizuochi_help", seg.start, seg._end, row[1], " " .. row[2]))
		end
		return
	end

	local state = core.get_state(env)
	local text = core.compose(state, input)
	if text then
		yield(Candidate("greek_mizuochi", seg.start, seg._end, text, ""))
	end
end

return translator
