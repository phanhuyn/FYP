require 'torch'
require 'nn'
require 'LanguageModel'
require 'gap/utils'
require 'gap/singlegap'

CHECKPOINT_PATH = 'models/cv/checkpoint_17000.t7'
local model = get_model_by_path(CHECKPOINT_PATH)

print ("produced by model:fillSingleGap")
local temp_prob = model:probs2('Nearly ten years had passed since the Dursleys had woken up to find the')
local LSTM_states = model:getLSTMStates()
local gap, likelihood = model:fillSingleGap(LSTM_states, temp_prob, 2, model:encode_string(' nephew.'), true)
print ('"' .. model:decode_string(gap) .. '"')
print (likelihood)

-- print ("produced by singlegap")
-- fill_single_gap('There are two peop', 3, 'in this room.', model)
-- print(fill_single_gap('Indeed it was submerged ', 3 ,'the water', model))

--print (model:checkSequenceLikelihood(LSTM_states, temp_prob, model:encode_string('ea you leave'), true))
--
-- print ('--------------------------------')
-- temp_prob = model:probs2('Indeed it was submerged')
-- LSTM_states = model:getLSTMStates()
-- print (model:checkSequenceLikelihood(LSTM_states, temp_prob, model:encode_string(' in the water'), true))


--------------------------------------------
-- TIME TEST
--------------------------------------------
-- local timebefore = os.time()
-- temp_prob = model:probs2('There are two peop')
-- LSTM_states = model:getLSTMStates()
-- for i=1,500 do
--   local gap, likelihood = model:fillSingleGap(LSTM_states, temp_prob, 3, model:encode_string('in this room.'))
-- -- print ('"' .. model:decode_string(gap) .. '"')
-- -- print (likelihood)
-- end
-- local timeafter = os.time()
-- print (timeafter - timebefore)
--
-- print ("produced by singlegap")
-- timebefore = os.time()
-- for i=1,500 do
--   fill_single_gap('There are two peop', 3, 'in this room.', model)
-- end
-- timeafter = os.time()
-- print (timeafter - timebefore)
