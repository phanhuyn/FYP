require 'accuracy/generateTest'
require 'gap/utils'

-- return a list of files/folder in a directory
function scandir(directory)
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('ls -a "'..directory..'"')
    for filename in pfile:lines() do
        i = i + 1
        if i > 2 then
          table.insert(t, filename)
        end
    end
    pfile:close()
    return t
end

-- read all the txt files in a test_set_group folder for n times
-- return a list of accuracy (one element = one running time)
-- report is a csv file
function runTestGroup(path_to_test_set_group, model, no_of_run_times, path_to_report_file)

    local timebefore = os.time()

    local gap_char = find_char_to_represent_gap(model)
    local test_files = scandir(path_to_test_set_group)

    -- writing to txt file
  	local report = io.open(path_to_report_file, "w")

    report:write('run_id,correct,incorrect\n')

    local trueCount = 0
    local wrongCount = 0
    for j = 1, no_of_run_times do
      print ("Interation no. " .. j)
      for i = 1,#test_files do
        test_set = generateTestSet(path_to_test_set_group .. test_files[i], 'testset', gap_char)
        test_result = runSingleTest(test_set, model)
        trueCount = trueCount + test_result.trueCount
        wrongCount = wrongCount + test_result.wrongCount
      end
      report:write(j .. "," .. trueCount .. "," .. wrongCount .. "\n")
      trueCount = 0
      wrongCount = 0
    end
    report:close()

    local timeafter = os.time()
    print ("Report for test group at: " .. path_to_test_set_group .. " generated.")
    print ("Total running time: " .. (timeafter - timebefore)/60 .. " minutes")
end

function runTestGroup2(path_to_test_set_group, model, path_to_report_group)
    local gap_char = find_char_to_represent_gap(model)
    local test_files = scandir(path_to_test_set_group)
    os.execute("mkdir " .. path_to_report_group)
    for i = 1,#test_files do
      testCase = generateTestSet(path_to_test_set_group .. test_files[i], 'testset', gap_char)
      generateSingleDetailReport(testCase, path_to_report_group .. test_files[i], model)
      print ('report for ' .. path_to_test_set_group .. test_files[i] .. ' generated')
    end
end

CHECKPOINT_PATH = 'models/cv/checkpoint_17000.t7'
local model = get_model_by_path(CHECKPOINT_PATH)
runTestGroup('accuracy/rawTestFiles/testsetgroup3/', model, 100, 'accuracy/reports/testsetgroup3.csv')
