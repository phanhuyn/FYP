require 'util/table-save.lua'

local table1 = {}

table1.string = "a string"
table1.anotherTable = {'a', 'b', 'c'}

-- table.save( table1, "test_tbl.lua" )


local table2 = table.load( "test_tbl.lua" )
print (table2)
