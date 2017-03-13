require 'torch'
require 'nn'
require 'LanguageModel'
require 'gap/utils'
require 'gap/singlegap'

-- fill in a string with multiple gaps
-- string_with_gap: the string to fill in
-- gap_char: the character which denoting the 'gap' (e.g. string.char(127))
-- model: loaded sequence model
-- return: an object with
-- 	gaps: list of gaps
--  prefix: at the final return it would be the full sentence
function fill_multi_gaps(string_with_gap, gap_char, model)

	-- print ("calling fill_multi_gaps... ")

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

		-- print ('calling single gap with:')
		-- print ('prefix = ' .. prefix)
		-- print ('postfix = ' .. postfix)
		local single_gap = fill_single_gap(prefix, gap_size, postfix, model)

		prefix = single_gap[1]
		table.insert(gaps, single_gap[2])
	end

	return {gaps, prefix}
end

-- TESTING

-- CHECKPOINT_PATH = 'models/cv/checkpoint_17000.t7'
-- local model = get_model_by_path(CHECKPOINT_PATH)
--
-- local gap_char = find_char_to_represent_gap(model)
-- local string_with_gap = "Indeed i" .. gap_char .. gap_char .. gap_char .. "as submerge" .. gap_char .. gap_char .. gap_char .. "y the water"
--
-- print(fill_multi_gaps(string_with_gap, gap_char, model))


-- fill in a string with multiple gap in a naive manner (select the highest probability without looking forward), which is faster
-- string_with_gap: the string to fill in
-- gap_char: the character which denoting the 'gap' (e.g. string.char(127))
-- model: loaded sequence model
-- return: an object with
-- 	gaps: list of gaps
--  full_sentence: at the final return it would be the full sentence
function naive_fill_multi_gaps(string_with_gap, gap_char, model)

	local gaps = {}

	local gap_pos = string.find(string_with_gap, gap_char)
	local prev_gap_pos = 0

	if (gap_pos == nil) then
		return {gaps, string_with_gap}
	end

	local full_sentence = string_with_gap:sub(0, gap_pos - 1)

	while (gap_pos ~= nil)
	do
		local gap_size = 0

		-- moving gap pos pass all the gap_char
		while (string_with_gap:sub(gap_pos, gap_pos) == gap_char and gap_pos <= #string_with_gap) do
			gap_pos = gap_pos + 1
			gap_size = gap_size + 1
		end

		local prefix = string_with_gap:sub(prev_gap_pos, gap_pos - 1 - gap_size)

		prev_gap_pos = gap_pos
		gap_pos = string.find(string_with_gap, gap_char, prev_gap_pos)

		local postfix
		if (gap_pos == nil) then
			postfix = string_with_gap:sub(prev_gap_pos, #string_with_gap)
		else
			postfix = string_with_gap:sub(prev_gap_pos, gap_pos - 1)
		end

		local single_gap = model:naiveFillSingleGap(prefix, gap_size, postfix)

		local gap = single_gap:sub(#prefix+1, #prefix+gap_size)
		table.insert(gaps, gap)

		full_sentence = full_sentence .. gap .. postfix
	end

	model:resetStates()
	return {gaps, full_sentence}
end

--[[
DEPRECATED
]]
function fill_multi_gaps3(string_with_gap, gap_char, model, naive)

	naive = naive or false

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

		local single_gap = model:naiveFillSingleGap(prefix, gap_size, postfix)
		model:resetStates()
		table.insert(gaps, single_gap:sub(#prefix+1, #prefix+gap_size))

		prefix = single_gap
	end

	return {gaps, prefix}
end

-- CHECKPOINT_PATH = 'models/cv/checkpoint_17000.t7'
-- local model = get_model_by_path(CHECKPOINT_PATH)
--
-- local gap_char = find_char_to_represent_gap(model)
--
-- local string_with_gap = "Indeed i" .. gap_char .. gap_char .. gap_char .. "as submerge" .. gap_char .. gap_char .. gap_char .. "y the water"

-- print(fill_multi_gaps(string_with_gap, gap_char, model))

--
-- local timebefore = os.time()
-- print(naive_fill_multi_gaps(string_with_gap, gap_char, model))
-- local timeafter = os.time()
--
-- print ((timeafter - timebefore)/60)
