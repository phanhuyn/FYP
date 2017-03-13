require 'gap/utils'
require 'gap/singlegap'
require 'gap/multigap'

local lapis = require 'lapis'
local app = lapis.Application()
app:enable("etlua")

app:get("/", function(self)

  self.my_favorite_things = {
    "Cats",
    "Horses",
    "Skateboards"
  }

  return { render = "index" }

  -- CHECKPOINT_PATH = '../models/cv/checkpoint_17000.t7'
  -- local model = get_model_by_path(CHECKPOINT_PATH)
  -- local gap_char = find_char_to_represent_gap(model)
  --
  -- -- local string_with_gap = "Indeed i" .. gap_char .. gap_char .. gap_char .. "as submerge" .. gap_char .. gap_char .. gap_char .. "y the water"
  -- --local string_with_gap = "Nearly ten years had pass" .. gap_char .. gap_char .. " since the Dursleys " .. gap_char .. gap_char .. "d woken" .. gap_char .. gap_char .. "p to find the" .. gap_char ..gap_char .. " nephew on the f" .. gap_char .. gap_char .. "nt step" .. gap_char .. " but Privet Drive had hardly c" .. gap_char .. gap_char .."nged at a" .. gap_char .. gap_char
  -- local string_with_gap = "Nearly ten years had passed since the Dursleys had woken up to find the" .. gap_char ..gap_char .. " nephew on the f" .. gap_char .. gap_char .. "nt step" .. gap_char .. " but Privet Drive had hardly c" .. gap_char .. gap_char .."nged at a" .. gap_char .. gap_char
  --
  -- local filled_string = model:fillMultiGap(string_with_gap, gap_char)
  -- print (filled_string[2])
  --
  -- return "Welcome to Lapis " .. require("lapis.version") .. filled_string[2]
end)

return app
