-- main program to fill in the missing space

-- print ('missing.lua running')

require 'torch'
require 'nn'
require 'LanguageModel'

local cmd = torch.CmdLine()

-- Which model to use 
cmd:option('-checkpoint', 'cv/checkpoint_100000.t7')

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

-- getting sample
-- local sample = model:probs(opt)


-- from the sample, pickout the all the indices which has the probability greater than a threshold
-- return both the values and the indices
-- sample: a Torch Tensor of probability, the indices of the tensor corresponded to the decoded character
-- threshold: double, the minimum probability to be selected
function get_sample_by_threshold(sample, threshold)
  local gt = torch.gt(sample,threshold)
  local index = torch.nonzero(gt)
  local value = sample[gt]
  return value, index
end


-- from the sample, pick out the top k indices with highest probability
-- sample: a Torch Tensor of probability, the indices of the tensor corresponded to the decoded character
-- n: number of indices to be selected
function get_highest_n_indices(sample, n)
  return sample:topk(n, true)
end

function check_likelihood(prefix, postfix, model)
  
  local likelihood = 0

  for i = 1, #postfix do
    local c = postfix:sub(0,i-1)
    opt.start_text = prefix .. c
    local sample = model:probs(opt)
    local next_char_likelihood = sample[model:encode_string(postfix:sub(i, i))[1]]
    if (next_char_likelihood < 0.01) then
      return 0
    end
    likelihood = likelihood + next_char_likelihood
  end

  return likelihood
end 


function fill_gap (prefix, size, postfix, model, current_likelihood, all_words)

  current_likelihood = current_likelihood or 0

  if (size == 0) then
    local word = prefix .. postfix
    local likelihood = check_likelihood(prefix, postfix, model) + current_likelihood
    if (likelihood > 0) then     
      table.insert(all_words, {word, likelihood})
    end
    return 
  end 
  opt.start_text = prefix
  local sample = model:probs(opt)
  
  local value, index = get_sample_by_threshold(sample, opt.threshold)

  for i=1, value:size()[1] 
  do 
    fill_gap(prefix .. model:decode_string(index[i]), size - 1, postfix, model, value[i] + current_likelihood, all_words)
    --print (i)
    --print (model:decode_string(index[i]))
    --print (value[i])
    --print ('----------------------------------'),
  end

  return value, index
end

function max(t, fn)
    if #t == 0 then return nil, nil end
    local key, value = 1, t[1]
    for i = 2, #t do
        if fn(value, t[i]) then
            key, value = i, t[i]
        end
    end
    return key, value
end

local all_words = {}

fill_gap('Indeed i', 2 ,'was submerged in the water', model, 1, all_words)

print(max(all_words, function(a,b) return a[2] < b[2] end))

all_words = {}



fill_gap('Indeed it was submerged ', 2 ,' the water', model, 1, all_words)

print(max(all_words, function(a,b) return a[2] < b[2] end))

all_words = {}



fill_gap('He ', 3, ' a singer.', model, 1, all_words)

print(max(all_words, function(a,b) return a[2] < b[2] end))

all_words = {}



fill_gap('There are two peop', 3, 'in this room.', model, 1, all_words)

print(max(all_words, function(a,b) return a[2] < b[2] end))

all_words = {}


fill_gap('There are two people ', 2 ,' this room.', model, 1, all_words)

print(max(all_words, function(a,b) return a[2] < b[2] end))

all_words = {}

-- sample = model:probs(opt)

-- print (sample)

-- index, value = fill_gap ('hell', 1, 'nothing', model)



