require 'torch'
require 'nn'
require 'LanguageModel'
require 'gap/utils'
require 'gap/singlegap'


CHECKPOINT_PATH = 'models/cv/checkpoint_17000.t7'
local model = get_model_by_path(CHECKPOINT_PATH)
print(model:naiveFillSingleGap('Hearin', 10))
