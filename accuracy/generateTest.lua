require 'gap/multigap'
require 'gap/utils'

-- Generate a test set from a text file

-- a test set is a lua table, including:
-- 1. a string with gap
-- 2. an array of correct chars to be filled in.

-- After generating the test set, the function wrote the test set table to accuracy/rawTestFiles/<testsetname>

-- CONFIG
MIN_PREFIX = 5
MAX_PREFIX = 30
MIN_GAP = 1
MAX_GAP = 2

MIN_TAIL = 10

-- method to generate a test_set
-- test_set: a dict with two elements:
-- 1. string_with_gap: string with random gaps denoted with gap_char
-- 2. answer: list of gaps
function generateTestSet(path_to_file, test_set_name, gap_char)
	local f = io.open(path_to_file, "rb")

	if f == nil then
		return nil
	end

    local content = f:read("*all")
    local string_with_gap = ''
		local numbered_string_with_gap = ''
		local pos = 0
    local test_set = {}
    local gap = {}

		local gap_count = 1
    while (pos < #content) do
    	local string_len = math.random(MIN_PREFIX, MAX_PREFIX)
    	string_with_gap = string_with_gap .. content:sub(pos+1, pos + string_len)
    	numbered_string_with_gap = numbered_string_with_gap .. content:sub(pos+1, pos + string_len)
			pos = pos + string_len

    	if pos > #content - MIN_TAIL then
    		break
    	end

    	local gap_len = math.random(MIN_GAP, MAX_GAP)
    	string_with_gap = string_with_gap .. string.rep(gap_char, gap_len)
			numbered_string_with_gap = numbered_string_with_gap .. string.rep(gap_char, gap_len)
			numbered_string_with_gap = numbered_string_with_gap .. '(' ..  gap_count .. ')'
			gap_count = gap_count + 1
    	table.insert(gap, content:sub(pos+1, pos + gap_len))
    	pos = pos + gap_len
    end

		string_with_gap = string_with_gap .. content:sub(pos+1, #content)
		numbered_string_with_gap = numbered_string_with_gap .. content:sub(pos+1, #content)

    test_set.string_with_gap = string_with_gap
		test_set.original_string = content
    test_set.answer = gap
		test_set.gap_char = gap_char
		test_set.numbered_string_with_gap = numbered_string_with_gap

    f:close()
    return test_set
end
