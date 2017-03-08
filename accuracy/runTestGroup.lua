require 'accuracy/generateTest'
require 'accuracy/runTest'
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

--[[
 Run generated test set group on a model
]]
function runGeneratedTestGroup(path_to_test_set_group, model, no_of_run_times, path_to_report_file)

    local timebefore = os.time()
    local gap_char = find_char_to_represent_gap(model)
    local test_files = scandir(path_to_test_set_group)

    local report = io.open(path_to_report_file, "w")

    report:write('test_id,correct,incorrect\n')
    for i = 1, math.min(no_of_run_times,#test_files) do
      print('Running test no. ' .. i)
      test_set = table.load(path_to_test_set_group .. test_files[i])
      test_result = runSingleTest(test_set, model)
      report:write(i .. "," .. test_result.trueCount .. "," .. test_result.wrongCount .. "\n")
    end
    report:close()

    local timeafter = os.time()
    print ("Report for test group at: " .. path_to_test_set_group .. " generated.")
    print ("Total running time: " .. (timeafter - timebefore)/60 .. " minutes")
end


function compareModel(path_to_test_file, paths_to_models, number_of_iteration, path_to_report_file)
  local timebefore = os.time()

  local model = get_model_by_path(paths_to_models[1])
  local gap_char = find_char_to_represent_gap(model)
  local test_set = generateTestSet(path_to_test_file, 'testset', gap_char)

  for i = 1, #paths_to_models do
    print ('----------------------------------')
    print ('model: ' .. paths_to_models[i])
    model = get_model_by_path(paths_to_models[i])
    test_result = runSingleTest(test_set, model)
    local trueCount = test_result.trueCount
    local wrongCount = test_result.wrongCount
    print ('true count: ' .. trueCount)
    print ('wrong count: ' .. wrongCount)
    print ('accuracy: ' .. trueCount/(trueCount+wrongCount))
  end

  local timeafter = os.time()
  print ("Total running time: " .. (timeafter - timebefore)/60 .. " minutes")
end
--[[
  read all the txt files in a test_set_group folder, generate test based the text
  result is detail of each gap
]]
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


-- GENERATE TEST CASES
-- CHECKPOINT_PATH = 'models/sherlock_holmes_1_128/sherlock_holmes_1_128_10000.t7'
-- local model = get_model_by_path(CHECKPOINT_PATH)
-- local gap_char = find_char_to_represent_gap(model)
-- generateTestSetAndStore('accuracy/rawTestFiles/harrypotter_onefile/harrypotter2.txt', 'accuracy/generatedTestCases/harrypotter/', gap_char, 100)

-- function runTestGroup3(path_to_test_set_group, model, path_to_report_group1, path_to_report_group2)
--     local gap_char = find_char_to_represent_gap(model)
--     local test_files = scandir(path_to_test_set_group)
--     os.execute("mkdir " .. path_to_report_group1)
--     os.execute("mkdir " .. path_to_report_group2)
--     for i = 1,#test_files do
--       testCase = generateTestSet(path_to_test_set_group .. test_files[i], 'testset', gap_char)
--       generateSingleDetailReport(testCase, path_to_report_group1 .. test_files[i], model)
--       generateSingleDetailReport3(testCase, path_to_report_group2 .. test_files[i], model)
--       print ('report for ' .. path_to_test_set_group .. test_files[i] .. ' generated')
--     end
-- end

-- 2_256
-- CHECKPOINT_PATH = 'models/sherlock_holmes_cleaned_3_128/sherlock_holmes_cleaned_3_128_9965.t7'
-- local model = get_model_by_path(CHECKPOINT_PATH)
-- runTestGroup('accuracy/rawTestFiles/harrypotter_onefile/', model, 100, 'accuracy/reports/sherlock_holmes_cleaned_3_128_tested_with_harry_potter.csv')

-- runTestGroup2('accuracy/rawTestFiles/harrypotter_onefile/', model, 'accuracy/reports/sherlock_holmes_2_256_tested_with_harry_potter_new_engine/')

-- runTestGroup3('accuracy/rawTestFiles/harrypotter2/', model, 'accuracy/reports/sherlock_holmes_2_256_naive_tested_with_harry_potter_slow/', 'accuracy/reports/sherlock_holmes_2_256_naive_tested_with_harry_potter_fast/')

-- CHECKPOINT_PATH = 'models/sherlock_holmes_cleaned_3_128/sherlock_holmes_cleaned_3_128_9965.t7'
-- local model = get_model_by_path(CHECKPOINT_PATH)
-- runTestGroup('accuracy/rawTestFiles/harrypotter_onefile_cleaned/', model, 100, 'accuracy/reports/sherlock_holmes_cleaned_3_128_tested_with_harry_potter.csv')


CHECKPOINT_PATH = 'models/sherlock_holmes_1_128/sherlock_holmes_1_128_10000.t7'
local model = get_model_by_path(CHECKPOINT_PATH)
runGeneratedTestGroup('accuracy/generatedTestCases/harrypotter/', model, 20, 'accuracyTestResult/sherlock_holmes_1_128_ITER_10000.csv')
