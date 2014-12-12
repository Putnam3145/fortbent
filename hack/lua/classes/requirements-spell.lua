
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

function findUnitSyndrome(unit,syn_id)
 for index,syndrome in ipairs(unit.syndromes.active) do
  if syndrome['type'] == syn_id then
   return syndrome
  end
 end
 return nil
end

function checkrequirements(unit,spell)
 key = tostring(unit.id)
 yes = true
 local unitClasses = persistTable.GlobalTable.roses.UnitTable[tostring(key)]['Classes']
 local unitCounters = persistTable.GlobalTable.roses.UnitTable[tostring(key)]['Counters']
 local currentClass = unitClasses['Current']
 local classes = persistTable.GlobalTable.roses.ClassTable
 local currentClassName = currentClass['Name']
 local currentClassLevel = tonumber(unitClasses[currentClassName]['Level'])
 local found = false
 local upgrade = false
-- if classes[currentClassName]['Spell'] then
  for _,j in pairs(classes[currentClassName]['Spells']._children) do
   local y = classes[currentClassName]['Spells'][j]
   if spell == j then
    found = true
    if currentClassLevel < tonumber(y['RequiredLevel']) then
     print('Class requirements not met. '..currentClassName..' level '..y['RequiredLevel']..' needed. Current level is '..tostring(currentClassLevel))
     yes = false    
    end
--    if y['RequiredPhysical'] and yes then
     for _,i in pairs(y['RequiredPhysical']._children) do
	  local x = y['RequiredPhysical'][i]
      currentStat = getAttrValue(unit,i,false)
      if currentStat < tonumber(x) then
       print('Stat requirements not met. '..x..' '..i..' needed. Current amount is '..tostring(currentStat))
       yes = false
      end
     end
--    end
--    if y['RequiredMental'] and yes then
     for _,i in pairs(y['RequiredMental']._children) do
	  local x = y['RequiredMental'][i]
      currentStat = getAttrValue(unit,i,true)
      if currentStat < tonumber(x) then
       print('Stat requirements not met. '..x..' '..i..' needed. Current amount is '..tostring(currentStat))
       yes = false
      end
     end
--    end
--    if y['ForbiddenSpell'] and yes then
     for _,i in pairs(y['ForbiddenSpell']._children) do
      for _,syn in ipairs(df.global.world.raws.syndromes.all) do      
	   local x = y['ForbiddenSpell'][i]
       if syn.syn_name == x then
        oldsyndrome = findUnitSyndrome(unit,syn.id)
        if oldsyndrome then
         print('Knows a forbidden spell. '..x)
         yes = false
        end
       end
      end
     end
--    end 
--    if y['ForbiddenClass'] and yes then
     for _,i in pairs(y['ForbiddenClass']._children) do
	  local x = y['ForbiddenClass'][i]
      local classCheck = unitClasses[i]
      if tonumber(classCheck['Level']) >= tonumber(x) and tonumber(x) ~= 0 then
       print('Member of a forbidden class. '..i)
       yes = false
      elseif tonumber(x) == 0 and tonumber(classCheck['Experience']) > 0 then
       print('Member of a forbidden class. '..i)
       yes = false   
      end
     end
--	end
    if y['Cost'] and yes then
     if tonumber(currentClass['SkillExp']) >= tonumber(y['Cost']) then
      currentClass['SkillExp'] = tostring(tonumber(currentClass['SkillExp']) - tonumber(y['Cost']))
     else
      print('Not enough points to learn spell. Needed '..y['Cost']..' currently have '..currentClass['SkillExp'])
      yes = false
     end
    end
    if y['Upgrade'] then upgrade = y['Upgrade'] end
    break
   end
  end
-- end
 if not found then
  print(spell..' not learnable by '..currentClassName)
  return false, false
 else
  return yes, upgrade
 end
end

return checkrequirements