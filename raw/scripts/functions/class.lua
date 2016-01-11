function addExperience(unit,amount,verbose)
 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end
 local unitID = unit.id

 local persistTable = require 'persist-table'
 local unitTable = persistTable.GlobalTable.roses.UnitTable
 if not unitTable[tostring(unitID)] then
  dfhack.script_environment('functions/tables').makeUnitTable(unitID)
 end
 unitTable = persistTable.GlobalTable.roses.UnitTable[tostring(unitID)]
 local unitClasses = unitTable.Classes
 local currentClass = unitClasses.Current
 local classTable = persistTable.GlobalTable.roses.ClassTable
 currentClass.TotalExp = tostring(tonumber(currentClass.TotalExp)+amount)
 currentClass.SkillExp = tostring(tonumber(currentClass.SkillExp)+amount)
 if currentClass.Name ~= 'NONE' then
  local currentClassName = currentClass.Name
  unitClasses[currentClassName].Experience = tostring(unitClasses[currentClassName].Experience + amount)
  local currentClassLevel = tonumber(unitClasses[currentClassName].Level)
  if currentClassLevel < tonumber(classTable[currentClassName].Levels) then
   classExpLevel = tonumber(classTable[currentClassName].Experience[tostring(currentClassLevel+1)])
   if tonumber(unitClasses[currentClassName].Experience) >= classExpLevel then
    if verbose then
     print('LEVEL UP! '..currentClassName..' LEVEL '..tostring(currentClassLevel+1))
     changeLevel(unitID,1,true)
    else
     changeLevel(unitID,1,false)
    end
   end
  end
 end
end

function changeClass(unit,change,verbose)
 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end
 local key = tostring(unit.id)

 local persistTable = require 'persist-table'
 local unitTable = persistTable.GlobalTable.roses.UnitTable
 if not unitTable[key] then
  dfhack.script_environment('functions/tables').makeUnitTable(unit)
 end
 local unitTable = persistTable.GlobalTable.roses.UnitTable[key]
-- Change the units class
 local currentClass = unitTable.Classes.Current
 local nextClass = unitTable.Classes[change]
 if not nextClass then
  print('No such class to change into')
  return false
 end
 local classes = persistTable.GlobalTable.roses.ClassTable
 if currentClass.Name == change then
  print('Already this class')
  return false
 end
 local storeName = 'NONE'
 if currentClass.Name ~= 'NONE' then
  local storeClass = unitTable.Classes[currentClass.Name]
  storeName = currentClass.Name
  local currentClassLevel = storeClass.Level
  -- Remove Class Name From Unit
  changeName(unit,currentClass.Name,'remove')
  -- Remove Physical Attribute Bonuses
  for _,attr in pairs(classes[currentClass.Name].BonusPhysical._children) do
   local attrTable = classes[currentClass.Name].BonusPhysical[attr]
   dfhack.script_environment('functions/unit').changeAttribute(unit,attr,-tonumber(attrTable[currentClassLevel+1]),0,'class')
  end
  -- Remove Mental Attribute Bonuses
  for _,attr in pairs(classes[currentClass.Name].BonusMental._children) do
   local attrTable = classes[currentClass.Name].BonusMental[attr]
   dfhack.script_environment('functions/unit').changeAttribute(unit,attr,-tonumber(attrTable[currentClassLevel+1]),0,'class')
  end
  -- Remove Skill Bonuses
  for _,attr in pairs(classes[currentClass.Name].BonusSkill._children) do
   local attrTable = classes[currentClass.Name].BonusSkill[attr]
   dfhack.script_environment('functions/unit').changeSkill(unit,attr,-tonumber(attrTable[currentClassLevel+1]),0,'class')
  end
  -- Remove Trait Bonuses
  for _,attr in pairs(classes[currentClass.Name].BonusTrait._children) do
   local attrTable = classes[currentClass.Name].BonusTrait[attr]
   dfhack.script_environment('functions/unit').changeTrait(unit,attr,-tonumber(attrTable[currentClassLevel+1]),0,'class')
  end
  -- Remove Spells and Abilities
  for _,spell in pairs(classes[currentClass.Name].Spells._children) do
   changeSpell(unit,spell,'remove',verbose)
  end
 end
 -- Change Current Class Table
 currentClass.Name = change
 currentClassLevel = nextClass.Level
 -- Add Class Name to Unit
 changeName(unit,currentClass.Name,'add')
 -- Add Physical Attribute Bonuses
 for _,attr in pairs(classes[currentClass.Name].BonusPhysical._children) do
  local attrTable = classes[currentClass.Name].BonusPhysical[attr]
  dfhack.script_environment('functions/unit').changeAttribute(unit,attr,tonumber(attrTable[currentClassLevel+1]),0,'class')
 end
 -- Add Mental Attribute Bonuses
 for _,attr in pairs(classes[currentClass.Name].BonusMental._children) do
  local attrTable = classes[currentClass.Name].BonusMental[attr]
  dfhack.script_environment('functions/unit').changeAttribute(unit,attr,tonumber(attrTable[currentClassLevel+1]),0,'class')
 end
 -- Add Skill Bonuses
 for _,attr in pairs(classes[currentClass.Name].BonusSkill._children) do
  local attrTable = classes[currentClass.Name].BonusSkill[attr]
  dfhack.script_environment('functions/unit').changeSkill(unit,attr,tonumber(attrTable[currentClassLevel+1]),0,'class')
 end
 -- Add Trait Bonuses
 for _,attr in pairs(classes[currentClass.Name].BonusTrait._children) do
  local attrTable = classes[currentClass.Name].BonusTrait[attr]
  dfhack.script_environment('functions/unit').changeTrait(unit,attr,tonumber(attrTable[currentClassLevel+1]),0,'class')
 end
 -- Add Spells and Abilities
 for _,spell in ipairs(classes[currentClass.Name].Spells._children) do
  local spellTable = classes[currentClass.Name].Spells[spell]
  if (tonumber(spellTable.RequiredLevel) <= tonumber(currentClassLevel)) and spellTable.AutoLearn then
   unitTable.Spells[spell] = '1'
  end
  if unitTable.Spells[spell] == '1' then
   changeSpell(unit,spell,'add',verbose)
  end
 end
 if verbose then print('Class change successful! '..storeName..' -> '..currentClass.Name) end
 return true
end

function changeLevel(unit,amount,verbose)
 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end
 local key = tostring(unit.id)

 local persistTable = require 'persist-table'
 local unitTable = persistTable.GlobalTable.roses.UnitTable
 if not unitTable[key] then
  dfhack.script_environment('functions/tables').makeUnitTable(unit)
 end
 local unitTable = persistTable.GlobalTable.roses.UnitTable[key]
 local currentClass = unitTable.Classes.Current
 if currentClass.Name == 'NONE' then
  if verbose then print('Unit does not have a current class assigned. Can not change level') end
  return
 end
 local name = currentClass.Name
 local level = tonumber(unitTable.Classes[name].Level)
 local class = persistTable.GlobalTable.roses.ClassTable[name]
 local maxLevel = false

 if amount > 0 then
  if level + amount >= tonumber(class.Levels) then
   unitTable.Classes[name].Level = class.Levels
   newLevel = tonumber(class.Levels)
   maxLevel = true
  else
   unitTable.Classes[name].Level = tostring(level+amount)
   newLevel = level + amount
  end
 elseif amount < 0 then
  if level + amount <= 0 then
   unitTable.Classes[name].Level = '0'
   newLevel = 0
  else
   unitTable.Classes[name].Level = tostring(level+amount)
   newLevel = level + amount
  end
 end

 --Add/Subtract temporary level bonuses
 for _,attr in pairs(class.BonusPhysical._children) do
  local bonus = class.BonusPhysical[attr]
  dfhack.script_environment('functions/unit').changeAttribute(unit,attr,bonus[newLevel+1]-bonus[level+1],0,'class')
 end
 for _,attr in pairs(class.BonusMental._children) do
  local bonus = class.BonusMental[attr]
  dfhack.script_environment('functions/unit').changeAttribute(unit,attr,bonus[newLevel+1]-bonus[level+1],0,'class')
 end
 for _,skill in pairs(class.BonusSkill._children) do
  local bonus = class.BonusSkill[skill]
  dfhack.script_environment('functions/unit').changeSkill(unit,skill,bonus[newLevel+1]-bonus[level+1],0,'class')
 end
 for _,trait in pairs(class.BonusTrait._children) do
  local bonus = class.BonusTrait[trait]
  dfhack.script_environment('functions/unit').changeTrait(unit,trait,bonus[newLevel+1]-bonus[level+1],0,'class')
 end

 --Add/Subtract permanent level bonuses
 for _,attr in pairs(class.LevelBonus.Physical._children) do
  local amount = class.LevelBonus.Physical[attr]
  dfhack.script_environment('functions/unit').changeAttribute(unit,attr,amount,0,'track')
 end
 for _,attr in pairs(class.LevelBonus.Mental._children) do
  local amount = class.LevelBonus.Mental[attr]
  dfhack.script_environment('functions/unit').changeAttribute(unit,attr,amount,0,'track')
 end
 for _,skill in pairs(class.LevelBonus.Skill._children) do
  local amount = class.LevelBonus.Skill[skill]
  dfhack.script_environment('functions/unit').changeSkill(unit,skill,amount,0,'track')
 end
 for _,trait in pairs(class.LevelBonus.Trait._children) do
  local amount = class.LevelBonus.Trait[trait]
  dfhack.script_environment('functions/unit').changeTrait(unit,trait,amount,0,'track')
 end

 --Learn/Unlearn Skills
 for _,spell in pairs(class.Spells._children) do
  local spellTable = class.Spells[spell]
  if amount > 0 and tonumber(spellTable.RequiredLevel) <= newLevel then
   if spellTable.AutoLearn then
    changeSpell(unit,spell,'learn',verbose)
   end
  elseif amount < 0 and tonumber(spellTable.RequiredLevel) > newLevel then
   changeSpell(unit,spell,'unlearn',verbose)
  end
 end

 if maxLevel then
  if verbose then print('Maximum level for class '..name..' reached!') end
  if class.AutoUpgrade then
   if verbose then print('Auto upgrading class to '..class.AutoUpgrade) end
   changeClass(unit,class.AutoUpgrade,verbose)
  end
 end
end

function changeName(unit,name,direction)
 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end

 local synUtils = require 'syndrome-util'
 if direction == 'add' then
  for _,syn in ipairs(df.global.world.raws.syndromes.all) do
   if syn.syn_name == name then
    syndrome = syn
    break
   end
  end
  if not syndrome then
   print('No valid name syndrome for changing class name')
   return
  end
  synUtils.infectWithSyndrome(unit,syndrome)
 elseif direction == 'remove' then
  for _,syn in ipairs(df.global.world.raws.syndromes.all) do
   if syn.syn_name == name then
    syndrome = syn
    break
   end
  end
  if not syndrome then
   print('No valid name syndrome for changing class name')
   return
  end
  synUtils.eraseSyndromes(unit,syndrome.id)
 elseif direction == 'removeall' then
  synUtils.eraseSyndromeClass(unit,'CLASS_NAME')
 end
end

function changeSpell(unit,spell,direction,verbose)
 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end

 local synUtils = require 'syndrome-util'
 if direction == 'add' then
  for _,syn in ipairs(df.global.world.raws.syndromes.all) do
   if syn.syn_name == spell then
    syndrome = syn
    break
   end
  end
  if not syndrome then
   print('No valid name syndrome for changing spell')
   return
  end
  synUtils.infectWithSyndrome(unit,syndrome)
 elseif direction == 'remove' then
  for _,syn in ipairs(df.global.world.raws.syndromes.all) do
   if syn.syn_name == spell then
    syndrome = syn
    break
   end
  end
  if not syndrome then
   print('No valid name syndrome for changing spell')
   return
  end
  synUtils.eraseSyndromes(unit,syndrome.id)
 elseif direction == 'removeall' then
  synUtils.eraseSyndromeClass(unit,'CLASS_SPELL')
 elseif direction == 'learn' then
  local key = tostring(unit.id)
  local persistTable = require 'persist-table'
  local unitTable = persistTable.GlobalTable.roses.UnitTable
  if not unitTable[key] then
   dfhack.script_environment('functions/tables').makeUnitTable(unit)
  end
  local unitTable = persistTable.GlobalTable.roses.UnitTable[key]
  if unitTable.Spells[spell] == '1' then
   if verbose then print('Spell already known, adding to unit') end
  else
   if verbose then print('Spell learned, adding to unit') end
   unitTable.Spells[spell] = '1'
  end
  changeSpell(unit,spell,'add',verbose)
  if unitTable.Classes.Current.Name ~= 'NONE' then
   unitTable.Classes.Current.SkillExp = tostring(unitTable.Classes.Current.SkillExp - persistTable.GlobalTable.roses.ClassTable[unitTable.Classes.Current.Name].Spells[spell].Cost)
  end
 elseif direction == 'unlearn' then
  local key = tostring(unit.id)
  local persistTable = require 'persist-table'
  local unitTable = persistTable.GlobalTable.roses.UnitTable
  if not unitTable[key] then
   dfhack.script_environment('functions/tables').makeUnitTable(unit)
  end
  local unitTable = persistTable.GlobalTable.roses.UnitTable[key]
  if unitTable.Spells[spell] == '1' then
   if verbose then print('Spell loss, removing from unit') end
   unitTable.Spells[spell] = '0'
  else
   if verbose then print('Spell not known') end
  end
  changeSpell(unit,spell,'remove',verbose)
 end
end

function checkRequirementsClass(unit,class,verbose)
 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end
 local key = tostring(unit.id)

 local persistTable = require 'persist-table'
 local unitTable = persistTable.GlobalTable.roses.UnitTable
 if not unitTable[key] then
  dfhack.script_environment('functions/tables').makeUnitTable(unit)
 end
 local unitTable = persistTable.GlobalTable.roses.UnitTable[key]

 local unitClasses = unitTable.Classes
 local unitCounters = unitTable.Counters
 local currentClass = unitClasses.Current
 local classTable = persistTable.GlobalTable.roses.ClassTable[class]
 if not classTable then
  if verbose then print ('No specified class to check for requirements') end
  return false
 end
-- local currentClassName = currentClass.Name
-- local currentClassLevel = unitClasses[currentClass.Name].Level
-- Check for Required Class
 for _,class in pairs(classTable.RequiredClass._children) do
  local check = unitClasses[class].Level
  local level = classTable.RequiredClass[class]
  if tonumber(check) < tonumber(level) then
   if verbose then print('Class requirements not met. '..class..' level '..level..' needed. Current level is '..tostring(check)) end
   return false
  end
 end
-- Check for Forbidden Class
 for _,class in pairs(classTable.ForbiddenClass._children) do
  local check = unitClasses[class]
  local level = classTable.ForbiddenClass[class]
  if tonumber(check.Level) >= tonumber(level) and tonumber(level) ~= 0 then
   if verbose then print('Already a member of a forbidden class. '..class) end
   return false
  elseif tonumber(level) == 0 and tonumber(check.Experience) > 0 then
   if verbose then print('Already a member of a forbidden class. '..class) end
   return false
  end
 end
-- Check for Required Counters (not currently working)
 --[[
 for _,x in pairs(classTable.RequiredCounter._children) do
  local i = classes[change]['RequiredCounter'][x]
  if unitCounters[x] then
   if tonumber(unitCounters[x]['Value']) < tonumber(x) then
    if verbose then print('Counter requirements not met. '..i..x..' needed. Current amount is '..unitCounters[i]['Value']) end
    yes = false
   end
  else
   if verbose then print('Counter requirements not met. '..i..x..' needed. No current counter on the unit') end
   yes = false
  end
 end
]]
-- Check for Required Physical Attributes
 for _,attr in pairs(classTable.RequiredPhysical._children) do
  local total,base,change,class,syndrome = dfhack.script_environment('functions/unit').trackAttribute(unit,attr,0,0,0,0,'get')
  local check = total-change-class-syndrome
  local value = classTable.RequiredPhysical[attr]
  if currentStat < tonumber(value) then
   if verbose then print('Stat requirements not met. '..value..' '..attr..' needed. Current amount is '..tostring(check)) end
   return false
  end
 end
-- Check for Required Mental Attributes
 for _,attr in pairs(classTable.RequiredMental._children) do
  local total,base,change,class,syndrome = dfhack.script_environment('functions/unit').trackAttribute(unit,attr,0,0,0,0,'get')
  local check = total-change-class-syndrome
  local value = classTable.RequiredMental[attr]
  if currentStat < tonumber(value) then
   if verbose then print('Stat requirements not met. '..value..' '..attr..' needed. Current amount is '..tostring(check)) end
   return false
  end
 end
-- Check for Required Skills
 for _,skill in pairs(classTable.RequiredSkill._children) do
  local total,base,change,class,syndrome = dfhack.script_environment('functions/unit').trackSkill(unit,skill,0,0,0,0,'get')
  local check = total-change-class-syndrome
  local value = classTable.RequiredSkill[skill]
  if currentSkill < tonumber(value) then
   if verbose then print('Skill requirements not met. '..value..' '..skill..' needed. Current amount is '..tostring(check)) end
   yes = false
  end
 end
-- Check for Required Traits
 for _,trait in pairs(classTable.RequiredTrait._children) do
  local total,base,change,class,syndrome = dfhack.script_environment('functions/unit').trackTrait(unit,trait,0,0,0,0,'get')
  local check = total-change-class-syndrome
  local value = classTable.RequiredTrait[trait]
  if currentTrait < tonumber(value) then
   if verbose then print('Trait requirements not met. '..value..' '..trait..' needed. Current amount is '..tostring(check)) end
   return false
  end
 end
 return true
end

function checkRequirementsSpell(unit,spell,verbose)
 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end
 local key = tostring(unit.id)

 local persistTable = require 'persist-table'
 local unitTable = persistTable.GlobalTable.roses.UnitTable
 if not unitTable[key] then
  dfhack.script_environment('functions/tables').makeUnitTable(unit)
 end
 local unitTable = persistTable.GlobalTable.roses.UnitTable[key]


 local unitClasses = unitTable.Classes
 local unitCounters = unitTable.Counters
 local currentClass = unitClasses.Current
 local currentClassName = currentClass.Name
 local currentClassLevel = unitClasses[currentClass.Name].Level
 local classTable = persistTable.GlobalTable.roses.ClassTable[currentClassName]
 if not classTable then
  if verbose then print ('No specified class to check for requirements') end
  return false
 end

 local found = false
 local upgrade = false
 local spellTable = classTable.Spells[spell]
 if spellTable then
-- Check for Required Class
  if currentClassLevel < tonumber(spellTable.RequiredLevel) then
   if verbose then print('Class requirements not met. '..currentClassName..' level '..spellTable.RequiredLevel..' needed. Current level is '..tostring(currentClassLevel)) end
   return false
  end
-- Check for Forbidden Class
  for _,class in pairs(spellTable.ForbiddenClass._children) do
   local check = unitClasses[class]
   local level = spellTable.ForbiddenClass[class]
   if tonumber(check.Level) >= tonumber(level) and tonumber(level) ~= 0 then
    if verbose then print('Already a member of a forbidden class. '..class) end
    return false
   elseif tonumber(level) == 0 and tonumber(check.Experience) > 0 then
    if verbose then print('Already a member of a forbidden class. '..class) end
    return false
   end
  end
-- Check for Forbidden Spell
  local synUtils = require 'syndrome-util'
  for _,i in pairs(spellTable.ForbiddenSpell._children) do
   for _,syn in ipairs(df.global.world.raws.syndromes.all) do
    local x = spellTable.ForbiddenSpell[i]
    if syn.syn_name == x then
     oldsyndrome = synUtils.findUnitSyndrome(unit,syn.id)
     if oldsyndrome then
      if verbose then print('Knows a forbidden spell. '..x) end
      return false
     end
    end
   end
  end
-- Check for Required Physical Attributes
  for _,attr in pairs(spellTable.RequiredPhysical._children) do
   local total,base,change,class,syndrome = dfhack.script_environment('functions/unit').trackAttribute(unit,attr,0,0,0,0,'get')
   local check = total-change-class-syndrome
   local value = spellTable.RequiredPhysical[attr]
   if currentStat < tonumber(value) then
    if verbose then print('Stat requirements not met. '..value..' '..attr..' needed. Current amount is '..tostring(check)) end
    return false
   end
  end
-- Check for Required Mental Attributes
  for _,attr in pairs(spellTable.RequiredMental._children) do
   local total,base,change,class,syndrome = dfhack.script_environment('functions/unit').trackAttribute(unit,attr,0,0,0,0,'get')
   local check = total-change-class-syndrome
   local value = spellTable.RequiredMental[attr]
   if currentStat < tonumber(value) then
    if verbose then print('Stat requirements not met. '..value..' '..attr..' needed. Current amount is '..tostring(check)) end
    return false
   end
  end
-- Check for Cost
  if spellTable.Cost then
   if tonumber(currentClass.SkillExp) < tonumber(spellTable.Cost) then
    if verbose then print('Not enough points to learn spell. Needed '..spellTable.Cost..' currently have '..currentClass.SkillExp) end
    return false
   end
  end
  if spellTable.Upgrade then upgrade = spellTable.Upgrade end
 else
  if verbose then print(spell..' not learnable by '..currentClassName) end
  return false
 end
 return true, upgrade
end
