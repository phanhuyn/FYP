require 'torch'
require 'nn'
require 'LanguageModel'
require 'gap/util'
require 'gap/singlegap'

local cmd = torch.CmdLine()

-- Which model to use 
cmd:option('-checkpoint', 'cv/checkpoint_17000.t7')

cmd:option('-start_text', 'hell')
cmd:option('-sample', 1)
cmd:option('-temperature', 1)
cmd:option('-gpu', -1)
cmd:option('-verbose', 0)
cmd:option('-threshold', 0.01)

local opt = cmd:parse(arg)

-- Loading pre-trained model
local checkpoint = torch.load(opt.checkpoint)
local model = checkpoint.model
model:evaluate()