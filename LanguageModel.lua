require 'torch'
require 'nn'

require 'VanillaRNN'
require 'LSTM'

require 'gap/constants'

local utils = require 'util.utils'
local LM, parent = torch.class('nn.LanguageModel', 'nn.Module')
-- This means we are defining class nn.LanguageModel, inheritting nn.Module
-- More details on nn.Module: https://github.com/torch/nn/blob/master/doc/module.md#nn.Module

function LM:__init(kwargs)
  self.idx_to_token = utils.get_kwarg(kwargs, 'idx_to_token')
  self.token_to_idx = {}
  self.vocab_size = 0
  for idx, token in pairs(self.idx_to_token) do
    self.token_to_idx[token] = idx
    self.vocab_size = self.vocab_size + 1
  end

  self.model_type = utils.get_kwarg(kwargs, 'model_type')
  self.wordvec_dim = utils.get_kwarg(kwargs, 'wordvec_size')
  self.rnn_size = utils.get_kwarg(kwargs, 'rnn_size')
  self.num_layers = utils.get_kwarg(kwargs, 'num_layers')
  self.dropout = utils.get_kwarg(kwargs, 'dropout')
  self.batchnorm = utils.get_kwarg(kwargs, 'batchnorm')

  local V, D, H = self.vocab_size, self.wordvec_dim, self.rnn_size

  self.net = nn.Sequential()
  self.rnns = {}
  self.bn_view_in = {}
  self.bn_view_out = {}

  self.net:add(nn.LookupTable(V, D))
  for i = 1, self.num_layers do
    local prev_dim = H
    if i == 1 then prev_dim = D end
    local rnn
    if self.model_type == 'rnn' then
      rnn = nn.VanillaRNN(prev_dim, H)
    elseif self.model_type == 'lstm' then
      rnn = nn.LSTM(prev_dim, H)
    end
    rnn.remember_states = true
    table.insert(self.rnns, rnn)
    self.net:add(rnn)
    if self.batchnorm == 1 then
      local view_in = nn.View(1, 1, -1):setNumInputDims(3)
      table.insert(self.bn_view_in, view_in)
      self.net:add(view_in)
      self.net:add(nn.BatchNormalization(H))
      local view_out = nn.View(1, -1):setNumInputDims(2)
      table.insert(self.bn_view_out, view_out)
      self.net:add(view_out)
    end
    if self.dropout > 0 then
      self.net:add(nn.Dropout(self.dropout))
    end
  end

  -- After all the RNNs run, we will have a tensor of shape (N, T, H);
  -- we want to apply a 1D temporal convolution to predict scores for each
  -- vocab element, giving a tensor of shape (N, T, V). Unfortunately
  -- nn.TemporalConvolution is SUPER slow, so instead we will use a pair of
  -- views (N, T, H) -> (NT, H) and (NT, V) -> (N, T, V) with a nn.Linear in
  -- between. Unfortunately N and T can change on every minibatch, so we need
  -- to set them in the forward pass.
  self.view1 = nn.View(1, 1, -1):setNumInputDims(3)
  self.view2 = nn.View(1, -1):setNumInputDims(2)

  self.net:add(self.view1)
  self.net:add(nn.Linear(H, V))
  self.net:add(self.view2)
end


function LM:updateOutput(input)
  local N, T = input:size(1), input:size(2)
  self.view1:resetSize(N * T, -1)
  self.view2:resetSize(N, T, -1)

  for _, view_in in ipairs(self.bn_view_in) do
    view_in:resetSize(N * T, -1)
  end
  for _, view_out in ipairs(self.bn_view_out) do
    view_out:resetSize(N, T, -1)
  end

  return self.net:forward(input)
end


function LM:backward(input, gradOutput, scale)
  return self.net:backward(input, gradOutput, scale)
end


function LM:parameters()
  return self.net:parameters()
end


function LM:training()
  self.net:training()
  parent.training(self)
end


function LM:evaluate()
  self.net:evaluate()
  parent.evaluate(self)
end


function LM:resetStates()
  for i, rnn in ipairs(self.rnns) do
    rnn:resetStates()
  end
end


function LM:encode_string(s)
  local encoded = torch.LongTensor(#s)
  for i = 1, #s do
    local token = s:sub(i, i)
    local idx = self.token_to_idx[token]
    assert(idx ~= nil, 'Got invalid idx')
    encoded[i] = idx
  end
  return encoded
end


function LM:decode_string(encoded)
  assert(torch.isTensor(encoded) and encoded:dim() == 1)
  local s = ''
  for i = 1, encoded:size(1) do
    local idx = encoded[i]
    local token = self.idx_to_token[idx]
    s = s .. token
  end
  return s
end


--[[
Sample from the language model. Note that this will reset the states of the
underlying RNNs.

Inputs:
- init: String of length T0
- max_length: Number of characters to sample

Returns:
- sampled: (1, max_length) array of integers, where the first part is init.
--]]
function LM:sample(kwargs)
  local T = utils.get_kwarg(kwargs, 'length', 100)
  local start_text = utils.get_kwarg(kwargs, 'start_text', '')
  local verbose = utils.get_kwarg(kwargs, 'verbose', 0)
  local sample = utils.get_kwarg(kwargs, 'sample', 1)
  local temperature = utils.get_kwarg(kwargs, 'temperature', 1)

  local sampled = torch.LongTensor(1, T)
  self:resetStates()

  local scores, first_t

  -- start_text in from the input, to seed the initial word
  if #start_text > 0 then
    if verbose > 0 then
      print('Seeding with: "' .. start_text .. '"')
    end
    local x = self:encode_string(start_text):view(1, -1)
    -- x is a tensor representing the start_text
    -- Note:
    -- self:encode_string(start_text): a column vector
    -- x: a row vector (view (1, -1) is like 'flattening' operation)
    local T0 = x:size(2) -- length of x e.i. start_text
    sampled[{{}, {1, T0}}]:copy(x)
    -- print(sampled)
    scores = self:forward(x)[{{}, {T0, T0}}]
    -- print(self:forward(x))
    -- forward is a method in nn.Module. This will not be override, but it will call
    -- updateOutput
    first_t = T0 + 1
  else
    if verbose > 0 then
      print('Seeding with uniform probabilities')
    end
    local w = self.net:get(1).weight
    -- seft.net: a local set in LM:init (nn.Sequential())
    scores = w.new(1, 1, self.vocab_size):fill(1)
    first_t = 1
  end

  -- score: !!! not the score of the next possible character
  -- first_t: the position to start generating text

  local _, next_char = nil, nil

  for t = first_t, T do
    -- by default, sample ~= 0
    if sample == 0 then
      _, next_char = scores:max(3)
      next_char = next_char[{{}, {}, 1}]
    else
       local probs = torch.div(scores, temperature):double():exp():squeeze()
       probs:div(torch.sum(probs))
       -- print(scores)

       -- using max instead of multinomial
       -- value, next_char = torch.max(probs,1)
       -- next_char = next_char:view(1, 1)

       next_char = torch.multinomial(probs, 1):view(1, 1)
       -- multinominal:
       -- multinominal(probs, 1):
       -- probs: a probability vector, not necessarily sum up to 1
       -- return a position in the probability vector, the likelihood of being selected
       -- is proportional to the values in the vector
       -- e.g. torchmultinomial(torch.Tensor({0.5, 0.5, 1, 0})) --> 50% is 3, 25% is 1, 25% is 2
       -- print (next_char)
    end
    sampled[{{}, {t, t}}]:copy(next_char)
    scores = self:forward(next_char)
  end

  self:resetStates()
  return self:decode_string(sampled[1])
end


--[[
Sample from the language model. And return the next position probability.
--]]
function LM:probs(kwargs)
  --local T = utils.get_kwarg(kwargs, 'length', 100)
  local start_text = utils.get_kwarg(kwargs, 'start_text', '')
  local temperature = utils.get_kwarg(kwargs, 'temperature', 1)
  --local sampled = torch.LongTensor(1, T)
  self:resetStates()

  local scores --, first_t

  local x = self:encode_string(start_text):view(1, -1)
  local T0 = x:size(2) -- length of x e.i. start_text

  scores = self:forward(x)[{{}, {T0, T0}}]

  local probs = torch.div(scores, temperature):double():exp():squeeze()
  probs:div(torch.sum(probs))
  --self:clearStates()
  return probs
end

--[[
  get next output probs with init state
--]]
function LM:probs2(start_text, LSTM_init_states)
  local temperature = 1

  self:resetStates()
  if (LSTM_init_states ~= nil) then
    self:setLSTMStates(LSTM_init_states)
  end

  local scores
  local x = self:encode_string(start_text):view(1, -1)

  local T0 = x:size(2) -- length of x e.i. start_text
  scores = self:forward(x)[{{}, {T0, T0}}]

  local probs = torch.div(scores, temperature):double():exp():squeeze()
  probs:div(torch.sum(probs))
  --self:resetStates()

  return probs
end

function LM:clearState()
  self.net:clearState()
end

--[[
  Getting last state of all the LSTM layers
  return: an array index from 1 to num_layers, each element is a table with h (hidden state)
  and c (cell state)
]]
function LM:getLSTMStates()
  local LSTM_states = {}
  for layer = 1,self.num_layers do
    LSTM_states[layer] = {}
    local LSTM = self.net.modules[layer+1]
    LSTM_states[layer].h = LSTM.output[{{}, LSTM.output:size(2)}]:clone()
    LSTM_states[layer].c = LSTM.cell[{{}, LSTM.cell:size(2)}]:clone()
    -- LSTM_states[layer].gates = LSTM.gates
  end
  return LSTM_states
end


--[[
  setting state of all the LSTM layers
]]
function LM:setLSTMStates(LSTM_states)
  assert(#LSTM_states == self.num_layers, 'setting states for LSTM must match the number of LSTM layers')
  for layer = 1,self.num_layers do
    local LSTM = self.net.modules[layer+1]
    -- LSTM:setState(LSTM_states[layer].h, LSTM_states[layer].c, LSTM_states[layer].gates)
    LSTM:setState(LSTM_states[layer].h, LSTM_states[layer].c)
  end
end

--[[
  Naive method (getting max base on prefix only) to fill single gap
]]
function LM:naiveFillSingleGap(prefix, gap_size, postfix, LSTM_states)

  local temperature = 1
  if (LSTM_states ~= nil) then
    self:setLSTMStates(LSTM_states)
  end

  local x = self:encode_string(prefix):view(1, -1)
  local T0 = x:size(2)

  local filled_in = torch.LongTensor(1, #prefix + gap_size)
  filled_in[{{}, {1, T0}}]:copy(x)
  local scores = self:forward(x)[{{}, {T0, T0}}]

  local _, next_char = nil, nil

  for t = #prefix + 1, #prefix + gap_size do
    local probs = torch.div(scores, temperature):double():exp():squeeze()
    probs:div(torch.sum(probs))
    _, next_char = torch.max(probs, 1)
    next_char = next_char:view(1,1)
    filled_in[{{}, {t, t}}]:copy(next_char)
    scores = self:forward(next_char)
  end

  -- local LSTM_state = self:getLSTMStates()
  -- print ('Printing LSTM state after filling gaps')
  -- for layer = 1,#LSTM_state do
  --   print ('layer ' .. layer)
  --   print (LSTM_state[layer].h:sum())
  --   print (LSTM_state[layer].c:sum())
  -- end

  return self:decode_string(filled_in[1]) .. postfix
end

--[[
  Method to fill single gap
]]
function LM:fillSingleGap(LSTM_init_states, init_probs, gap_size, encoded_postfix, opt)
  self:resetStates()
  self:setLSTMStates(LSTM_init_states)

  if opt == nil then
    opt = {}
    opt.threshold = THRESHOLD
  end

  local max_likelihood = -1
  local max_gap

  -- check if there is any value larger than threshold
  local max_next_char_likelihood = torch.max(init_probs,1)
  if (max_next_char_likelihood[1] <= opt.threshold) then
    _, next_char_t = torch.max(init_probs, 1)

    local next_char = next_char_t[1]

    local max_likelihood, filled_in_gap
    if gap_size == 1 then
      max_likelihood = self:checkSequenceLikelihood(LSTM_init_states, init_probs, torch.cat(torch.LongTensor{next_char},encoded_postfix))
    else
      local new_init_probs = self:probs2(self:decode_string(torch.Tensor{next_char}), LSTM_init_states)
      local new_LSTM_states = self:getLSTMStates()
      filled_in_gap, max_likelihood = self:fillSingleGap(new_LSTM_states, new_init_probs, gap_size -1, encoded_postfix)
      if USE_SUM then
        max_likelihood = max_likelihood + init_probs[next_char]
      else
        max_likelihood = max_likelihood*init_probs[next_char]
      end
    end

    if (filled_in_gap) then
      max_gap = torch.cat(torch.Tensor{next_char},filled_in_gap)
    else
      max_gap = torch.Tensor{next_char}
    end

    return max_gap, max_likelihood
  end

  for next_char = 1,self.vocab_size do
    -- print ('in LA:fillSingleGap, opt.threshold = ')
    -- print (opt.threshold)
    if init_probs[next_char] > opt.threshold then

      local next_char_likelihood, filled_in_gap
      if gap_size == 1 then
        next_char_likelihood = self:checkSequenceLikelihood(LSTM_init_states, init_probs, torch.cat(torch.LongTensor{next_char},encoded_postfix))
      else
        local new_init_probs = self:probs2(self:decode_string(torch.Tensor{next_char}), LSTM_init_states)
        local new_LSTM_states = self:getLSTMStates()
        filled_in_gap, next_char_likelihood = self:fillSingleGap(new_LSTM_states, new_init_probs, gap_size -1, encoded_postfix)
        if USE_SUM then
          next_char_likelihood = next_char_likelihood + init_probs[next_char]
        else
          next_char_likelihood = next_char_likelihood*init_probs[next_char]
        end
        -- if (next_char_likelihood > 1) then
        --   print ('With right char = ' .. self:decode_string(torch.Tensor{next_char}))
        --   print ('and left char  = ' .. self:decode_string(filled_in_gap))
        --   print ('prob = ' .. next_char_likelihood)
        -- end
      end
      if next_char_likelihood > max_likelihood then
        -- print ('--------------------------------------------------')
        -- print (self:decode_string(torch.Tensor{next_char}))
        -- self:checkSequenceLikelihood(LSTM_init_states, init_probs, torch.cat( torch.LongTensor{next_char}, encoded_postfix), true)
        if (filled_in_gap) then
          max_gap = torch.cat(torch.Tensor{next_char},filled_in_gap)
        else
          max_gap = torch.Tensor{next_char}
        end
        max_likelihood = next_char_likelihood
      end
    end
  end

  return max_gap, max_likelihood
end

--[[
  Check likelihood of the sequence, returning the sum
  args:
  - init_probs: probs vector of first character
  - encoded_sequence: the sequence to check, encoded to a LongTensor
  - use_sum: True or False. True meaning it uses sum of probability, else it'd use the product
]]
function LM:checkSequenceLikelihood(LSTM_init_states, init_probs, encoded_sequence, verbose)

  -- assume: size of encoded_sequence is larger than 0
  -- if (#encoded_sequence == 0 ) then
  --   return 0
  -- end
  local likelihood = init_probs[encoded_sequence[1]]
  if (likelihood < CUT_OFF_PROBS) then
    return 0
  end

  self:resetStates()

  self:setLSTMStates(LSTM_init_states)

  local scores = self:forward(encoded_sequence:view(1,-1))
  local probs = scores:double():exp():squeeze()

  if (verbose) then
    print (self:decode_string(torch.Tensor{encoded_sequence[1]}))
    print (likelihood)
  end

  -- only loop if the encoded_sequence is of length greater than 1
  if (probs:dim() > 1) then
    -- TODO can improve this, search for dividing pairwise?

    local cur_decay = 1

    for dim=1,probs:size(1)-1 do
      local current_char = encoded_sequence[dim+1]
      local next_char_prob = (probs[dim]:div(torch.sum(probs[dim])))[current_char]

      -- if (next_char_prob < CUT_OFF_PROBS) then
      --   return 0
      -- end
      -- print (cur_decay)
      
      if USE_SUM then
        cur_decay = cur_decay*PRODUCT_DECAY_FACTOR
        likelihood = likelihood + next_char_prob*cur_decay
      else
        cur_decay = cur_decay + PRODUCT_DECAY_FACTOR
        next_char_prob = math.pow(next_char_prob, cur_decay)
        likelihood = likelihood*next_char_prob*MAGNIFIY_FACTOR
      end

      if (verbose) then
        print (self:decode_string(torch.Tensor{current_char}))
        print (next_char_prob)
      end
    end
  end

  return likelihood
end

--[[
  Method to fill multiple gaps
]]
function LM:fillMultiGap(string_with_gap, gap_char, opt, lookforward_length)

  self:resetStates()

  if (opt == nil) then
    opt = {}
    opt.threshold = THRESHOLD
    opt.cutoffprobs = CUT_OFF_PROBS
  end

  local gaps = {}

  local gap_pos = string.find(string_with_gap, gap_char)
  local prev_gap_pos = 0

  if (gap_pos == nil) then
    return {gaps, string_with_gap}
  end

  local full_sen = string_with_gap:sub(0, gap_pos - 1)
  local prefix = full_sen
  local LSTM_init_states = nil
  while (gap_pos ~= nil)
  do
    local gap_size = 0
    -- moving gap pos pass all the gap_char
    while (string_with_gap:sub(gap_pos, gap_pos) == gap_char and gap_pos <= #string_with_gap) do
      gap_pos = gap_pos + 1
      gap_size = gap_size + 1
    end

    prev_gap_pos = gap_pos
    gap_pos = string.find(string_with_gap, gap_char, prev_gap_pos)

    local postfix
    if (gap_pos == nil) then
      postfix = string_with_gap:sub(prev_gap_pos, #string_with_gap)
    else
      postfix = string_with_gap:sub(prev_gap_pos, gap_pos - 1)
    end

    local init_probs = self:probs2(prefix, LSTM_init_states)
    LSTM_init_states = self:getLSTMStates()

    local encoded_gap, likelihood
    if (lookforward_length) then
      encoded_gap, likelihood = self:fillSingleGap(LSTM_init_states, init_probs, gap_size, self:encode_string(postfix:sub(1,lookforward_length)), opt)
    else
      encoded_gap, likelihood = self:fillSingleGap(LSTM_init_states, init_probs, gap_size, self:encode_string(postfix), opt)
    end

    local gap = self:decode_string(encoded_gap)
    full_sen = full_sen .. gap .. postfix
    prefix = gap .. postfix
    table.insert(gaps, gap)
  end

  self:resetStates()

  return {gaps, full_sen}
end


function LM:callwithLSTMState(LSTM)
  self:setLSTMStates(LSTM)
end
