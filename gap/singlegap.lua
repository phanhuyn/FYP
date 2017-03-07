require 'torch'
require 'nn'
require 'LanguageModel'
require 'gap/utils'
require 'gap/constants'

-- NOTE ON getting sample
-- model:probs(opt) returns the probs vector of the next position in the sequence
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


-- check likelihood of the sequence created by concaternating prefix and postfix
function check_likelihood(prefix, postfix, model)
  local likelihood = 0
  local opt = {}
  opt.gpu = -1
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


-- fill a single gap with the specified 'gap_size' to complete the sequence: prefix_____postfix
-- with refer with the model
-- return: the filled in sentence, and the max value
function fill_single_gap (prefix, gap_size, postfix, model)

  -- print ("calling fill_single_gap: ")
  -- print (prefix)
  -- print (postfix)
  -- print (gap_size)

	local all_words = {} -- to store result
	inner_fill_single_gap (prefix, gap_size, postfix, model, 0, all_words)
	local full_sen = max(all_words, function(a,b) return a[2] < b[2] end)[1]
  local filled_gap = full_sen:sub(#prefix + 1, #prefix + gap_size)

  -- print (prefix .. "<gap>" .. postfix)
  -- print ("answer: " .. filled_gap)

  return {full_sen, filled_gap}
end


-- for usage of fill_single_gap
function inner_fill_single_gap (prefix, size, postfix, model, current_likelihood, all_words)
  current_likelihood = current_likelihood or 0

  if (size == 0) then
    local sequence = prefix .. postfix
    local likelihood = check_likelihood(prefix, postfix, model) + current_likelihood
    if (likelihood > 0) then
      table.insert(all_words, {sequence, likelihood})
    end
    return
  end

  local opt = {}
  opt.gpu = -1
  opt.start_text = prefix
  local sample = model:probs(opt)

  local value, index = get_sample_by_threshold(sample, THRESHOLD)

  for i=1, value:size()[1]
  do
    inner_fill_single_gap(prefix .. model:decode_string(index[i]), size - 1, postfix, model, value[i] + current_likelihood, all_words)
  end

  return value, index
end

-- TESTING

 -- Which model to use
CHECKPOINT_PATH = 'models/cv/checkpoint_17000.t7'

-- model for sampling
local model = get_model_by_path(CHECKPOINT_PATH)

-- local full_sen = fill_single_gap('Indeed i', 2 ,'was submerged in the water', model)


print(fill_single_gap('Indeed it was submerged ', 2 ,' the water', model)[1])

-- print(fill_single_gap('Indeed it was submerged ', 2 ,' the water', model)[2])

-- print(fill_single_gap('He ', 3, ' a singer.', model))

-- print(fill_single_gap('There are two peop', 3, 'in this room.', model))

-- print(fill_single_gap('There are two people ', 2 ,' this room.', model, 1, all_words))

-- Print sorted list of char
