
local split = require('split')
local utils = require 'utils'

function establishclass(unit,classes)
 key = tostring(unit.id)
-- Check if the persistent variabls are present for the unit
 curpers,status = dfhack.persistent.get(key..'_current_class')
 if not curpers then
  dfhack.persistent.save({key=key..'_current_class',value='NONE',ints={0,0,0,0,0,0,0}})
 end
 for i,x in pairs(classes) do
  pers,status = dfhack.persistent.get(key..'_'..i)
  if not pers then
   dfhack.persistent.save({key=key..'_'..i,value=i,ints={0,0,0,0,0,0,0}})
  end
 end
end

return establishclass