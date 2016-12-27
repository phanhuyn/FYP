require 'torch'
require 'nn'
require 'LanguageModel'
require 'gap/utils'
-- require 'gap/singlegap'

CHECKPOINT_PATH = 'cv/checkpoint_17000.t7' 

-- model for sampling
local model = get_model_by_path(CHECKPOINT_PATH)


-- return a string containing all the characters in a model
function get_all_chars_in_model(model)
	-- geting a sample
	local opt = {}
	opt.gpu = -1
	opt.start_text = 'a'
	local sample = model:probs(opt)

	-- decoding a string of all char, sorted by its decoded index
	local encoded = torch.Tensor(sample:size()[1])
	for i=1, sample:size()[1] do 
		encoded[i] = i
	end

	all_chars_in_model = model:decode_string(encoded)

	return all_chars_in_model
end


all_chars_in_model = get_all_chars_in_model(model)

print (all_chars_in_model)

print (string.find(all_chars_in_model,"a"))

