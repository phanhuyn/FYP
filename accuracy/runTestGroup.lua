require 'accuracy/generateTest'
require 'accuracy/runTest'
require 'gap/utils'
require 'gap/constants'

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
function runGeneratedTestGroup(path_to_test_set_group, model, no_of_run_times, path_to_report_file, naive, opt, lookforward_length, path_to_time_report)

    if (opt == nil) then
      opt = {}
      opt.threshold = THRESHOLD
      opt.cutoffprobs = CUT_OFF_PROBS
    end

    -- print ('in runGeneratedTestGroup')
    -- print (opt)

    local timebefore = os.time()
    local gap_char = find_char_to_represent_gap(model)
    local test_files = scandir(path_to_test_set_group)

    local report = io.open(path_to_report_file, "w")

    report:write('test_id,correct,incorrect\n')
    for i = 1, math.min(no_of_run_times,#test_files) do
      print('Running test no. ' .. i)
      -- print (path_to_test_set_group .. test_files[i])
      test_set = table.load(path_to_test_set_group .. test_files[i])

      local test_result
      if naive ~= nil then
        test_result = runSingleTest(test_set, model, naive, opt, lookforward_length)
      else
        test_result = runSingleTest(test_set, model, false, opt, lookforward_length)
      end

      report:write(i .. "," .. test_result.trueCount .. "," .. test_result.wrongCount .. "\n")
    end
    report:close()

    local timeafter = os.time()

    if (path_to_time_report ~= nil) then
      local time_report = io.open(path_to_time_report, "a")
      time_report:write((timeafter - timebefore) .. " seconds\n")
      time_report:close()
    end

    print ("Report for test group at: " .. path_to_test_set_group .. " generated.")
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

-----------------------------------------------
-- GENERATE TEST AND STORE
-----------------------------------------------

-- CHECKPOINT_PATH = 'models/vietnamese_cleaned_3_128/vietnamese_cleaned_3_128_30300.t7'
-- local model = get_model_by_path(CHECKPOINT_PATH)
-- generateTestSetAndStore('accuracy/rawTestFiles/gonewiththewind_cleaned.txt', 'accuracy/generatedTestCases/gonewiththewind/', model, 1)

function runGeneratedTestOnMultipleModels(model_paths, test_cases_path, test_run_no, report_paths, naive)
  for i=1, #model_paths  do
    local model = get_model_by_path(model_paths[i])
    runGeneratedTestGroup(test_cases_path, model, test_run_no, report_paths[i], naive)
  end
end

function runGeneratedTestOnMultipleModelsWithGPU(model_paths, test_cases_path, test_run_no, report_paths)
  for i=1, #model_paths  do
    local model = get_model_by_path_with_GPU(model_paths[i])
    runGeneratedTestGroup(test_cases_path, model, test_run_no, report_paths[i])
  end
end

function testChangingThresholdWithGPU(model_path, test_cases_path, test_run_no, report_path, thresholds)
  local model = get_model_by_path(model_path)
  for i=1,#thresholds do
    local report = report_path .. 'thresholds_' .. thresholds[i] .. '_.csv'
    local opt = {}
    opt.threshold = thresholds[i]
    opt.cutoffprobs = CUT_OFF_PROBS
    runGeneratedTestGroup(test_cases_path, model, test_run_no, report, false, opt)
  end
end

function testChangingLookForwardLength(model_path, test_cases_path, test_run_no, report_path, lookforward_lens, time_report_path)
  local model = get_model_by_path(model_path)
  for i=1,#lookforward_lens do
    local report = report_path .. 'lookforward_len_' .. lookforward_lens[i] .. '_.csv'
    runGeneratedTestGroup(test_cases_path, model, test_run_no, report, false, nil, lookforward_lens[i], time_report_path)
  end
end

-----------------------------------------------
-- THRESHOLD TESTING
-----------------------------------------------
-- thresholds = {0.6,0.7,0.8,0.9,1}
-- testChangingThresholdWithGPU('models/sherlock_holmes_3_128/sherlock_holmes_3_128_103800.t7', 'accuracy/generatedTestCases/harrypotter/', 100, 'accuracy/visualization/report-data/changing-threshold/', thresholds)


-----------------------------------------------
-- LOOK FORWARD LENGTH TESTING
-----------------------------------------------

-- lookforward_lens = {0,1,100}
-- testChangingLookForwardLength('models/sherlock_holmes_3_128/sherlock_holmes_3_128_103800.t7', 'accuracy/generatedTestCases/harrypotter/', 2, 'accuracy/visualization/report-data/changing-lookforwardlen/', lookforward_lens, 'accuracy/visualization/report-data/changing-lookforwardlen/timereport.txt')

-----------------------------------------------
-- METHOD OF ACCUMULATING PROBS
-----------------------------------------------
local model_path = 'models/sherlock_holmes_3_128/sherlock_holmes_3_128_103800.t7'
local model = get_model_by_path_with_GPU(model_path)
local path_to_report_file = 'accuracy/visualization/report-data/changing-method-of-accum-prob/product_decay.csv'
local test_cases_path = 'accuracy/generatedTestCases/harrypotter/'
runGeneratedTestGroup(test_cases_path, model, 100, path_to_report_file, false)

SHERLOCK_HOLMES__VARYING_SIZE_MODEL_PATHS = {
  'models/sherlock_holmes_1_128/sherlock_holmes_1_128_100000.t7',
  'models/sherlock_holmes_1_256/sherlock_holmes_1_256_103800.t7',
  'models/sherlock_holmes_1_512/sherlock_holmes_1_512_103800.t7',
  'models/sherlock_holmes_2_128/sherlock_holmes_2_128_103800.t7',
  'models/sherlock_holmes_2_256/sherlock_holmes_2_256_103800.t7',
  'models/sherlock_holmes_2_512/sherlock_holmes_2_512_103800.t7',
  'models/sherlock_holmes_3_128/sherlock_holmes_3_128_103800.t7',
  'models/sherlock_holmes_3_256/sherlock_holmes_3_256_103800.t7',
  'models/sherlock_holmes_3_512/sherlock_holmes_3_512_100000.t7',
}

SHERLOCK_HOLMES_REPORT_PATHS = {
  'accuracy/visualization/report-data/varying-size-iter-100000-devil-foot/sherlock_holmes_1_128.csv',
  'accuracy/visualization/report-data/varying-size-iter-100000-devil-foot/sherlock_holmes_1_256.csv',
  'accuracy/visualization/report-data/varying-size-iter-100000-devil-foot/sherlock_holmes_1_512.csv',
  'accuracy/visualization/report-data/varying-size-iter-100000-devil-foot/sherlock_holmes_2_128.csv',
  'accuracy/visualization/report-data/varying-size-iter-100000-devil-foot/sherlock_holmes_2_256.csv',
  'accuracy/visualization/report-data/varying-size-iter-100000-devil-foot/sherlock_holmes_2_512.csv',
  'accuracy/visualization/report-data/varying-size-iter-100000-devil-foot/sherlock_holmes_3_128.csv',
  'accuracy/visualization/report-data/varying-size-iter-100000-devil-foot/sherlock_holmes_3_256.csv',
  'accuracy/visualization/report-data/varying-size-iter-100000-devil-foot/sherlock_holmes_3_512.csv',
}
-- runGeneratedTestOnMultipleModels(SHERLOCK_HOLMES__VARYING_SIZE_MODEL_PATHS,'accuracy/generatedTestCases/devil_foot/', 2, SHERLOCK_HOLMES_REPORT_PATHS)

-----------------------------------------------
-- NAIVE TESTING
-----------------------------------------------
-- local model = get_model_by_path('models/sherlock_holmes_3_128/sherlock_holmes_3_128_103800.t7')
-- runGeneratedTestGroup('accuracy/generatedTestCases/harrypotter/', model, 100,   'accuracy/visualization/report-data/naive/harrypotter_3_128.csv', true)

-----------------------------------------------
-- NORMAL RUN TEST GROUP
-----------------------------------------------
--   CHECKPOINT_PATH = 'models/sherlock_holmes_1_128/sherlock_holmes_1_128_10000.t7'
--   local model = get_model_by_path(CHECKPOINT_PATH)
--   runGeneratedTestGroup('accuracy/generatedTestCases/harrypotter2/', model, 100, 'accuracy/visualization/report-data/changing-iteration-1-128-double-check/sherlock_holmes_1_128_ITER_10000.csv')

-- runTestGroup2('accuracy/rawTestFiles/harrypotter_onefile/', model, 'accuracy/reports/sherlock_holmes_2_256_tested_with_harry_potter_new_engine/')

-- CHECKPOINT_PATH = 'models/vietnamese_cleaned_3_128/vietnamese_cleaned_3_128_30300.t7'
-- local model = get_model_by_path(CHECKPOINT_PATH)
-- runGeneratedTestGroup('accuracy/generatedTestCases/gonewiththewind/', model, 2, 'accuracy/visualization/report-data/different-sequence-type/vietnamese_cleaned_3_128.csv')

function iteration_testing(testrunno)
  testrunno = testrunno or 100

  CHECKPOINT_PATH = 'models/sherlock_holmes_1_128/sherlock_holmes_1_128_10000.t7'
  local model = get_model_by_path(CHECKPOINT_PATH)
  runGeneratedTestGroup('accuracy/generatedTestCases/harrypotter2/', model, testrunno, 'accuracy/visualization/report-data/changing-iteration-1-128-double-check/sherlock_holmes_1_128_ITER_10000.csv')

  CHECKPOINT_PATH = 'models/sherlock_holmes_1_128/sherlock_holmes_1_128_20000.t7'
  local model = get_model_by_path(CHECKPOINT_PATH)
  runGeneratedTestGroup('accuracy/generatedTestCases/harrypotter2/', model, testrunno, 'accuracy/visualization/report-data/changing-iteration-1-128-double-check/sherlock_holmes_1_128_ITER_20000.csv')

  CHECKPOINT_PATH = 'models/sherlock_holmes_1_128/sherlock_holmes_1_128_30000.t7'
  local model = get_model_by_path(CHECKPOINT_PATH)
  runGeneratedTestGroup('accuracy/generatedTestCases/harrypotter2/', model, testrunno, 'accuracy/visualization/report-data/changing-iteration-1-128-double-check/sherlock_holmes_1_128_ITER_30000.csv')

  CHECKPOINT_PATH = 'models/sherlock_holmes_1_128/sherlock_holmes_1_128_40000.t7'
  local model = get_model_by_path(CHECKPOINT_PATH)
  runGeneratedTestGroup('accuracy/generatedTestCases/harrypotter2/', model, testrunno, 'accuracy/visualization/report-data/changing-iteration-1-128-double-check/sherlock_holmes_1_128_ITER_40000.csv')

  CHECKPOINT_PATH = 'models/sherlock_holmes_1_128/sherlock_holmes_1_128_50000.t7'
  local model = get_model_by_path(CHECKPOINT_PATH)
  runGeneratedTestGroup('accuracy/generatedTestCases/harrypotter2/', model, testrunno, 'accuracy/visualization/report-data/changing-iteration-1-128-double-check/sherlock_holmes_1_128_ITER_50000.csv')

  CHECKPOINT_PATH = 'models/sherlock_holmes_1_128/sherlock_holmes_1_128_60000.t7'
  local model = get_model_by_path(CHECKPOINT_PATH)
  runGeneratedTestGroup('accuracy/generatedTestCases/harrypotter2/', model, testrunno, 'accuracy/visualization/report-data/changing-iteration-1-128-double-check/sherlock_holmes_1_128_ITER_60000.csv')

  CHECKPOINT_PATH = 'models/sherlock_holmes_1_128/sherlock_holmes_1_128_70000.t7'
  local model = get_model_by_path(CHECKPOINT_PATH)
  runGeneratedTestGroup('accuracy/generatedTestCases/harrypotter2/', model, testrunno, 'accuracy/visualization/report-data/changing-iteration-1-128-double-check/sherlock_holmes_1_128_ITER_70000.csv')

  CHECKPOINT_PATH = 'models/sherlock_holmes_1_128/sherlock_holmes_1_128_80000.t7'
  local model = get_model_by_path(CHECKPOINT_PATH)
  runGeneratedTestGroup('accuracy/generatedTestCases/harrypotter2/', model, testrunno, 'accuracy/visualization/report-data/changing-iteration-1-128-double-check/sherlock_holmes_1_128_ITER_80000.csv')

  CHECKPOINT_PATH = 'models/sherlock_holmes_1_128/sherlock_holmes_1_128_90000.t7'
  local model = get_model_by_path(CHECKPOINT_PATH)
  runGeneratedTestGroup('accuracy/generatedTestCases/harrypotter2/', model, testrunno, 'accuracy/visualization/report-data/changing-iteration-1-128-double-check/sherlock_holmes_1_128_ITER_90000.csv')

  CHECKPOINT_PATH = 'models/sherlock_holmes_1_128/sherlock_holmes_1_128_100000.t7'
  local model = get_model_by_path(CHECKPOINT_PATH)
  runGeneratedTestGroup('accuracy/generatedTestCases/harrypotter2/', model, testrunno, 'accuracy/visualization/report-data/changing-iteration-1-128-double-check/sherlock_holmes_1_128_ITER_100000.csv')
end

-- iteration_testing()
-- CHECKPOINT_PATH = 'models/sherlock_holmes_1_128/sherlock_holmes_1_128_10000.t7'
-- local model = get_model_by_path_with_GPU(CHECKPOINT_PATH)
-- runGeneratedTestGroup('accuracy/generatedTestCases/harrypotter/', model, 10, 'accuracyTestResult/sherlock_holmes_1_128_ITER_10000.csv')
