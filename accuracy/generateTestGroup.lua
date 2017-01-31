-- break a big test file into smaller test cases for testing
-- path_to_file: path to the txt file for testing
-- test_file_size: number of character in a test file we want to generate (recommend: from 100 - 200)
function generateTestGroup(path_to_file, path_to_test_group, test_file_size)
  local f = io.open(path_to_file, "rb")

	if f == nil then
		return nil
	end

  local content = f:read("*all")
  print (content)
  -- creating a directory for the smaller test files
  os.execute("mkdir " .. path_to_test_group)

  -- start breaking test files
  count = 0
  cur_pos = 0
  while (cur_pos < #content) do
    count = count + 1
    print ('test no. ' .. count)
    print (content:sub(cur_pos + 1, cur_pos + test_file_size))
    print ('\n')
    cur_pos = cur_pos + test_file_size

    -- local report = io.open(path_to_report, "w")
    --
    -- report:write('Passage with missing characters: \n')
    -- report:write(test_set.numbered_string_with_gap	)
  end
end

generateTestGroup('accuracy/rawTestFiles/test1.txt', 'accuracy/rawTestFiles/testsetgroup2', 200)
