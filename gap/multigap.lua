require 'torch'
require 'nn'
require 'LanguageModel'
require 'gap/utils'
require 'gap/singlegap'

-- fill in a string with multiple gaps
-- string_with_gap: the string to fill in
-- gap_char: the character which denoting the 'gap' (e.g. string.char(127))
-- model: loaded sequence model
function fill_multi_gaps(string_with_gap, gap_char, model)

	print ("calling fill_multi_gaps... ")
	
	local gaps = {}

	local gap_pos = string.find(string_with_gap, gap_char)
	local prev_gap_pos = 0

	if (gap_pos == nil) then
		return {gaps, string_with_gap}
	end

	local prefix = string_with_gap:sub(0, gap_pos - 1)

	while (gap_pos ~= nil) 
	do
		local gap_size = 0
		-- moving gap pos pass all the gap_char
		while (string_with_gap:sub(gap_pos, gap_pos) == gap_char and gap_pos <= #string_with_gap) do
			gap_pos = gap_pos + 1
			gap_size = gap_size + 1
		end 

		prev_gap_pos = gap_pos
		gap_pos = string.find(string_with_gap, gap_char, prev_gap_pos)

		local postfix
		if (gap_pos == nil) then
			postfix = string_with_gap:sub(prev_gap_pos, #string_with_gap)
		else 
			postfix = string_with_gap:sub(prev_gap_pos, gap_pos - 1)
		end

		local single_gap = fill_single_gap(prefix, gap_size, postfix, model)

		prefix = single_gap[1]
		table.insert(gaps, single_gap[2])
	end

	return {gaps, prefix}
end

-- TESTING

-- CHECKPOINT_PATH = 'models/cv/checkpoint_17000.t7' 
-- local model = get_model_by_path(CHECKPOINT_PATH)

-- local gap_char = find_char_to_represent_gap(model)
-- local string_with_gap = "Indeed i" .. gap_char .. gap_char .. "was submerged" .. gap_char .. gap_char .. gap_char .. " the water"

-- print(fill_multi_gaps(string_with_gap, gap_char, model))