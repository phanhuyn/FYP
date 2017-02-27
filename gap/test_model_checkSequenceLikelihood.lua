require 'torch'
require 'nn'
require 'LanguageModel'
require 'gap/utils'
require 'gap/singlegap'

CHECKPOINT_PATH = 'models/cv/checkpoint_17000.t7'
local model = get_model_by_path(CHECKPOINT_PATH)
---------------------------------------
-- TEST MODEL:checkSequenceLikelihood
----------------------------------------
-- print ("produced by probs")
-- local opt = {}
-- opt.gpu = -1
-- local result1 = {}
--
-- opt.start_text = 'H'
-- table.insert(result1, model:probs(opt))
-- print (torch.pow(result1[1],2):sum())
--
-- opt.start_text = 'He'
-- table.insert(result1, model:probs(opt))
-- print (torch.pow(result1[2],2):sum())
--
-- opt.start_text = 'Hea'
-- table.insert(result1, model:probs(opt))
-- print (torch.pow(result1[3],2):sum())
--
-- opt.start_text = 'Hear'
-- table.insert(result1, model:probs(opt))
-- print (torch.pow(result1[4],2):sum())
--
-- model:resetStates()
-- print ("produced by checkSequenceLikelihood")
-- local result2 = model:checkSequenceLikelihood(nil,model:encode_string('Hear'))
--
-- for dim=1,result2:size(1) do
--   print (torch.pow(result2[dim],2):sum())
--   print (torch.equal(result2[dim], result1[dim]))
-- end


---------------------------------------
-- TEST MODEL:checkSequenceLikelihood (IF TWO OF THOSE PRINT OUT SAME VALUE -> METHOD WORKS)
----------------------------------------
print ("produced by singlegap - check_likelihood")
print (check_likelihood('For', ' us, parents', model))

model:resetStates()
print ("produced by model:checkSequenceLikelihood")
local temp_prob = model:probs2('For')
local LSTM_states = model:getLSTMStates()
print (model:checkSequenceLikelihood(LSTM_states, temp_prob, model:encode_string(' us, parents')))

-- test speed

local timebefore = os.time()
for i=1,500 do
  check_likelihood('For', ' us, parents', model)
end
local timeafter = os.time()
print ('check_likelihood takes ')
print (timeafter - timebefore)



timebefore = os.time()
for i=1,500 do
  model:checkSequenceLikelihood(LSTM_states, temp_prob, model:encode_string(' us, parents'))
end
timeafter = os.time()
print ('checkSequenceLikelihood takes ')
print (timeafter - timebefore)
