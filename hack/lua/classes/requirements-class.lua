
local split = require('split')
local utils = require 'utils'
local persistTable = require 'persist-table'

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

function checkrequirements(unit,change)
 local key = tostring(unit.id)
 local yes = true
 local unitClasses = persistTable.GlobalTable.roses.UnitTable[key]['Classes']
 local unitCounters = persistTable.GlobalTable.roses.UnitTable[key]['Counters']
 local currentClass = unitClasses['Current']
 local classes = persistTable.GlobalTable.roses.ClassTable
-- Check if the unit meets the class and attribute requirements 
 for _,x in pairs(classes[change]['RequiredClass']._children) do
  local classCheck = unitClasses[x]
  local i = classes[change]['RequiredClass'][x]
  if tonumber(classCheck['Level']) < tonumber(i) then
   print('Class requirements not met. '..x..' level '..i..' needed. Current level is '..tostring(classCheck['Level']))
   yes = false
  end
 end
 for _,x in pairs(classes[change]['ForbiddenClass']._children) do
  local classCheck = unitClasses[x]
  local i = classes[change]['ForbiddenClass'][x]
  if tonumber(classCheck['Level']) >= tonumber(i) and tonumber(i) ~= 0 then
   print('Already a member of a forbidden class. '..x)
   yes = false
  elseif tonumber(i) == 0 and tonumber(classCheck['Experience']) > 0 then
   print('Already a member of a forbidden class. '..x)
   yes = false   
  end
 end
 for _,x in pairs(classes[change]['RequiredCounter']._children) do
  local i = classes[change]['RequiredCounter'][x]
  if unitCounters[x] then
   if tonumber(unitCounters[x]['Value']) < tonumber(x) then
    print('Counter requirements not met. '..i..x..' needed. Current amount is '..unitCounters[i]['Value'])
    yes = false
   end
  else
   print('Counter requirements not met. '..i..x..' needed. No current counter on the unit')
   yes = false
  end
 end
 for _,x in pairs(classes[change]['RequiredPhysical']._children) do
  local currentStat = getAttrValue(unit,x,false)
  local i = classes[change]['RequiredPhysical'][x]
  if currentStat < tonumber(i) then
   print('Stat requirements not met. '..i..' '..x..' needed. Current amount is '..tostring(currentStat))
   yes = false
  end
 end
 for _,x in pairs(classes[change]['RequiredMental']._children) do
  local currentStat = getAttrValue(unit,x,true)
  local i = classes[change]['RequiredMental'][x]
  if currentStat < tonumber(i) then
   print('Stat requirements not met. '..i..' '..x..' needed. Current amount is '..tostring(currentStat))
   yes = false
  end
 end
 for _,x in pairs(classes[change]['RequiredSkill']._children) do
  local currentSkill = dfhack.units.getEffectiveSkill(unit,x)
  local i = classes[change]['RequiredSkill'][x]
  if currentSkill < tonumber(i) then
   print('Skill requirements not met. '..i..' '..x..' needed. Current amount is '..tostring(currentSkill))
   yes = false
  end
 end
 for _,x in pairs(classes[change]['RequiredTrait']._children) do
  local currentTrait = dfhack.units.getMiscTrait(unit,x)
  local i = classes[change]['RequiredTrait'][x]
  if currentTrait < tonumber(i) then
   print('Trait requirements not met. '..i..' '..x..' needed. Current amount is '..tostring(currentTrait))
   yes = false
  end
 end
 return yes
end

return checkrequirements