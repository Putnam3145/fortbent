
local split = require('split')
local utils = require 'utils'
local persistTable = require 'persist-table'

function establishclass(unit)
 key = tostring(unit.id)
-- Check if the persistent variabls are present for the unit
 persistTable.GlobalTable.roses.UnitTable[key] = persistTable.GlobalTable.roses.UnitTable[key] or {}
 persistTable.GlobalTable.roses.UnitTable[key]['Classes'] = persistTable.GlobalTable.roses.UnitTable[key]['Classes'] or {}
 if not persistTable.GlobalTable.roses.UnitTable[key]['Classes']['Current'] then
   persistTable.GlobalTable.roses.UnitTable[key]['Classes']['Current'] = {}
   persistTable.GlobalTable.roses.UnitTable[key]['Classes']['Current']['Name'] = 'None'
   persistTable.GlobalTable.roses.UnitTable[key]['Classes']['Current']['CurrentExp'] = '0'
   persistTable.GlobalTable.roses.UnitTable[key]['Classes']['Current']['TotalExp'] = '0'
   persistTable.GlobalTable.roses.UnitTable[key]['Classes']['Current']['SkillExp'] = '0'
 end
 for i,x in pairs(persistTable.GlobalTable.roses.ClassTable._children) do
  if not persistTable.GlobalTable.roses.UnitTable[key]['Classes'][x] then
   persistTable.GlobalTable.roses.UnitTable[key]['Classes'][x] = {}
   persistTable.GlobalTable.roses.UnitTable[key]['Classes'][x]['Experience'] = '0'
   persistTable.GlobalTable.roses.UnitTable[key]['Classes'][x]['Level'] = '0'
  end
 end
end

return establishclass