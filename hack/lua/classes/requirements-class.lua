
local split = require('split')
local utils = require 'utils'

function getAttrValue(unit,attr,mental)
 if unit.curse.attr_change then
  if mental then
   return (unit.status.current_soul.mental_attrs[attr].value+unit.curse.attr_change.ment_att_add[attr])*unit.curse.attr_change.ment_att_perc[attr]/100
  else
   return (unit.body.physical_attrs[attr].value+unit.curse.attr_change.phys_att_add[attr])*unit.curse.attr_change.phys_att_perc[attr]/100
  end
 else
  if mental then
   return unit.status.current_soul[attr].value
  else
   return unit.body.physical_attrs[attr].value
  end
 end
end

function checkrequirements(unit,change,classes)
 key = tostring(unit.id)
 yes = true
-- Check if the unit meets the class and attribute requirements 
 for i,x in pairs(classes[change]['R_CLASS']) do
  pers,status = dfhack.persistent.get(key..'_'..i)
  if pers.ints[2] < tonumber(x) then
   print('Class requirements not met. '..i..' level '..x..' needed. Current level is '..tostring(pers.ints[2]))
   yes = false
  end
 end
 for i,x in pairs(classes[change]['F_CLASS']) do
  pers,status = dfhack.persistent.get(key..'_'..i)
  if pers.ints[2] >= tonumber(x) and tonumber(x) ~= 0 then
   print('Already a member of a forbidden class. '..i)
   yes = false
  elseif tonumber(x) == 0 and pers.ints[1] > 0 then
   print('Already a member of a forbidden class. '..i)
   yes = false   
  end
 end
 for i,x in pairs(classes[change]['R_COUNTER']) do
  yes = dfhack.run_script('special\\counters',table.unpack({unit,i,0,'minimum',tonumber(x)}))
 end
 for i,x in pairs(classes[change]['R_PHYS']) do
  curstat = getAttrValue(unit,i,false)
  if curstat < tonumber(x) then
   print('Stat requirements not met. '..x..' '..i..' needed. Current amount is '..tostring(curstat))
   yes = false
  end
 end
 for i,x in pairs(classes[change]['R_SKILL']) do
  curstat = dfhack.units.getEffectiveSkill(unit,i)
  if curstat < tonumber(x) then
   print('Skill requirements not met. '..x..' '..i..' needed. Current amount is '..tostring(curstat))
   yes = false
  end
 end
 for i,x in pairs(classes[change]['R_TRAIT']) do
  curstat = dfhack.units.getMiscTrait(unit,i)
  if curstat < tonumber(x) then
   print('Trait requirements not met. '..x..' '..i..' needed. Current amount is '..tostring(curstat))
   yes = false
  end
 end
 for i,x in pairs(classes[change]['R_MENT']) do
  curstat = getAttrValue(unit,i,true)
  if curstat < tonumber(x) then
   print('Stat requirements not met. '..x..' '..i..' needed. Current amount is '..tostring(curstat))
   yes = false
  end
 end
 return yes
end

return checkrequirements