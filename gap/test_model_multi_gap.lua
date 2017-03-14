require 'torch'
require 'nn'
require 'LanguageModel'
require 'gap/utils'
require 'gap/singlegap'
require 'gap/multigap'

CHECKPOINT_PATH = 'models/cv/checkpoint_17000.t7'
local model = get_model_by_path(CHECKPOINT_PATH)
local gap_char = find_char_to_represent_gap(model)

-- local string_with_gap = "Indeed i" .. gap_char .. gap_char .. gap_char .. "as submerge" .. gap_char .. gap_char .. gap_char .. "y the water"
--local string_with_gap = "Nearly ten years had pass" .. gap_char .. gap_char .. " since the Dursleys " .. gap_char .. gap_char .. "d woken" .. gap_char .. gap_char .. "p to find the" .. gap_char ..gap_char .. " nephew on the f" .. gap_char .. gap_char .. "nt step" .. gap_char .. " but Privet Drive had hardly c" .. gap_char .. gap_char .."nged at a" .. gap_char .. gap_char
local string_with_gap = "Nearly ten years had passed since the Dursleys had woken up to find the" .. gap_char ..gap_char .. " nephew on the f" .. gap_char .. gap_char .. "nt step" .. gap_char .. " but Privet Drive had hardly c" .. gap_char .. gap_char .."nged at a" .. gap_char .. gap_char .. "."

-- print(model:fillMultiGap(string_with_gap, gap_char, nil))
--print(fill_multi_gaps(string_with_gap,gap_char,model))
--------------------------------------------
-- TIME TEST
--------------------------------------------

-- local timebefore = os.time()
-- for i=1,10 do
--   model:fillMultiGap(string_with_gap, gap_char)
-- end
-- local timeafter = os.time()
-- print ('time by model:fillMultiGap')
-- print (timeafter - timebefore)
--
-- timebefore = os.time()
-- for i=1,10 do
--   fill_multi_gaps(string_with_gap, gap_char, model)
-- end
-- timeafter = os.time()
-- print ('time by singlegap')
-- print (timeafter - timebefore)


-- local timebefore = os.time()
-- for i=1,1000 do
--   model:probs2("abcdefghijabcdefghijabcdefghijabcdefghij")
-- end
-- local timeafter = os.time()
-- print ('time forwarding 40 char 1000 times')
-- print (timeafter - timebefore)
--
-- local LSTM_states = model:getLSTMStates()
--
-- timebefore = os.time()
-- for i=1,1000 do
--   model:probs2("abcdefghij", LSTM_states)
-- end
-- timeafter = os.time()
-- print ('time loading state and forwarding 10 char 1000 times')
-- print (timeafter - timebefore)
