
local split = require('split')
local utils = require 'utils'
local establishclass = require('classes.establish-class')
local checkclass = require('classes.requirements-class')
local persistTable = require 'persist-table'

function changeclass(unit,change)
 local key = tostring(unit.id)
-- Change the units class
 local currentClass = persistTable.GlobalTable.roses.UnitTable[key]['Classes']['Current']
 local nextClass = persistTable.GlobalTable.roses.UnitTable[key]['Classes'][change]
 local classes = persistTable.GlobalTable.roses.ClassTable
 if currentClass['Name'] == change then
  print('Already this class')
  return false
 end
 local currentClassExp = tonumber(currentClass['CurrentExp'])
 if currentClass['Name'] ~= 'None' then
  local storeClass = persistTable.GlobalTable.roses.UnitTable[key]['Classes'][currentClass['Name']]
  storeClass['Experience'] = tostring(tonumber(storeClass['Experience']) + currentClassExp)
  local currentClassLevel = storeClass['Level']
  dfhack.run_script("modtools/add-syndrome",table.unpack({"-target",key,"-syndrome",currentClass['Name'],"-eraseAll"}))
--  if classes[currentClass['Name']]['BonusPhysical'] then
   for _,x in pairs(classes[currentClass['Name']]['BonusPhysical']._children) do
    local i = classes[currentClass['Name']]['BonusPhysical'][x]
    dfhack.run_script('unit/attribute-change',table.unpack({'-unit',key,'-physical',x,'-fixed','\\'..tostring(-tonumber(split(i[currentClassLevel+1],']')[1]))}))
   end
--  end
--  if classes[currentClass['Name']]['BonusMental'] then
   for _,x in pairs(classes[currentClass['Name']]['BonusMental']._children) do
    local i = classes[currentClass['Name']]['BonusMental'][x]
    dfhack.run_script('unit/attribute-change',table.unpack({'-unit',key,'-mental',x,'-fixed','\\'..tostring(-tonumber(split(i[currentClassLevel+1],']')[1]))}))
   end
--  end
--  if classes[currentClass['Name']]['BonusSkill'] then
   for _,x in pairs(classes[currentClass['Name']]['BonusSkill']._children) do
    local i = classes[currentClass['Name']]['BonusSkill'][x]
    dfhack.run_script('unit/skill-change',table.unpack({'-unit',key,'-skill',x,'-fixed','\\'..tostring(-tonumber(split(i[currentClassLevel+1],']')[1]))}))
   end
--  end
--  if classes[currentClass['Name']]['BonusTrait'] then
   for i,x in pairs(classes[currentClass['Name']]['BonusTrait']._children) do
    local i = classes[currentClass['Name']]['BonusTrait'][x]
    dfhack.run_script('unit/trait-change',table.unpack({'-unit',key,'-trait',x,'-fixed','\\'..tostring(-tonumber(split(i[currentClassLevel+1],']')[1]))}))
   end
--  end
 end
 currentClass['Name'] = change
 currentClass['CurrentExp'] = nextClass['Experience']
 currentClassLevel = nextClass['Level']
-- curlevel = nexpers.ints[2]
 dfhack.run_script("modtools/add-syndrome",table.unpack({"-target",key,"-syndrome",change}))
--  if classes[currentClass['Name']]['BonusPhysical'] then
   for _,x in pairs(classes[currentClass['Name']]['BonusPhysical']._children) do
    local i = classes[currentClass['Name']]['BonusPhysical'][x]
    dfhack.run_script('unit/attribute-change',table.unpack({'-unit',key,'-physical',x,'-fixed','\\'..tostring(tonumber(split(i[currentClassLevel+1],']')[1]))}))
   end
--  end
--  if classes[currentClass['Name']]['BonusMental'] then
   for _,x in pairs(classes[currentClass['Name']]['BonusMental']._children) do
    local i = classes[currentClass['Name']]['BonusMental'][x]
    dfhack.run_script('unit/attribute-change',table.unpack({'-unit',key,'-mental',x,'-fixed','\\'..tostring(tonumber(split(i[currentClassLevel+1],']')[1]))}))
   end
--  end
--  if classes[currentClass['Name']]['BonusSkill'] then
   for _,x in pairs(classes[currentClass['Name']]['BonusSkill']._children) do
    local i = classes[currentClass['Name']]['BonusSkill'][x]
    dfhack.run_script('unit/skill-change',table.unpack({'-unit',key,'-skill',x,'-fixed','\\'..tostring(tonumber(split(i[currentClassLevel+1],']')[1]))}))
   end
--  end
--  if classes[currentClass['Name']]['BonusTrait'] then
   for i,x in pairs(classes[currentClass['Name']]['BonusTrait']._children) do
    local i = classes[currentClass['Name']]['BonusTrait'][x]
    dfhack.run_script('unit/trait-change',table.unpack({'-unit',key,'-trait',x,'-fixed','\\'..tostring(tonumber(split(i[currentClassLevel+1],']')[1]))}))
   end
--  end
-- if classes[change]['Spells'] then
  for _,x in pairs(classes[change]['Spells']._children) do
   local i = classes[change]['Spells'][x]
   if i['RequiredLevel'] <= nextClass['Level'] and i['AutoLearn'] then
    dfhack.run_script('classes/learn-skill',table.unpack({'-unit',tostring(key),'-spell',x}))
   end
  end
-- end
 print('Class change successful. Changed to '..change..'.')
 return true
end

validArgs = validArgs or utils.invert({
 'help',
 'unit',
 'class',
})
local args = utils.processArgs({...}, validArgs)

unit = df.unit.find(tonumber(args.unit))
establishclass(unit)
yes = checkclass(unit,args.class)
if yes then 
 success = changeclass(unit,args.class)
 if success then
 -- Erase items used for reaction
 end
else
 print('Failed to change class')
end