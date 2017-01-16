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

function generateTestSet(path_to_file, test_set_name, gap_char)
	local f = io.open(path_to_file, "rb")

	if f == nil then
		return nil
	end

    local content = f:read("*all")
    local string_with_gap = ''
    local pos = 0
    local test_set = {}
    local gap = {}

    while (pos < #content) do
    	local string_len = math.random(MIN_PREFIX, MAX_PREFIX)
    	string_with_gap = string_with_gap .. content:sub(pos+1, pos + string_len)
    	pos = pos + string_len

    	if pos > #content - MIN_TAIL then
    		break
    	end

    	local gap_len = math.random(MIN_GAP, MAX_GAP)
    	string_with_gap = string_with_gap .. string.rep(gap_char, gap_len)
    	table.insert(gap, content:sub(pos+1, pos + gap_len))
    	pos = pos + gap_len
    end 

    test_set.string_with_gap = string_with_gap
    test_set.answer = gap

    f:close()
    return test_set
end



CHECKPOINT_PATH = 'models/cv/checkpoint_17000.t7' 

-- model for sampling
local model = get_model_by_path(CHECKPOINT_PATH)

local gap_char = find_char_to_represent_gap(model)

print (gap_char)

testCase = generateTestSet('accuracy/rawTestFiles/test.txt', 'testset', gap_char)

print (testCase)

local string_with_gap = testCase.string_with_gap

print(fill_multi_gaps(string_with_gap, gap_char, model))