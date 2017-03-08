require 'torch'

-- get max value in a table
-- t: table
-- fn: function to compare two elements in the table
function max(t, fn)
    if #t == 0 then return nil, nil end
    local value = t[1]
    for i = 2, #t do
        if fn(value, t[i]) then
            value = t[i]
        end
    end
    return value
end

-- get model by path (path is the relative path to the checkpoint file)
function get_model_by_path(path)
	local checkpoint = torch.load(path)
	return checkpoint.model
end

-- get model by path with GPU (path is the relative path to the checkpoint file)
function get_model_by_path_with_GPU(path)
    require 'cutorch'
    require 'cunn'
    cutorch.setDevice(1)
    local checkpoint = torch.load(path)
    local model = checkpoint.model
    model:cuda()
    return model
end

-- return a string containing all the characters in a model
function get_all_chars_in_model(model)
    -- geting a sample
    local opt = {}
    opt.gpu = -1
    opt.start_text = 'a'
    local sample = model:probs(opt)
    model:resetStates()
    -- decoding a string of all char, sorted by its decoded index
    local encoded = torch.Tensor(sample:size()[1])
    for i=1, sample:size()[1] do
        encoded[i] = i
    end

    all_chars_in_model = model:decode_string(encoded)

    return all_chars_in_model
end


-- find a char which is not in the sample character's set, to denote the gap
function find_char_to_represent_gap(model)
    all_chars_in_model = get_all_chars_in_model(model)
    for i = 128, 255 do
        if not string.find(all_chars_in_model, string.char(i)) then
            return string.char(i)
        end
    end
    return false
end
