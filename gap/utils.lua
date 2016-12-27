require 'torch'

-- get max value in a table
-- t: table
-- fn: function to compare two elements in the table
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

-- get model by path (path is the relative path to the checkpoint file)
function get_model_by_path(path)
	local checkpoint = torch.load(path)
	return checkpoint.model
end

