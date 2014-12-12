
local split = require('split')
local utils = require 'utils'
local persistTable = require 'persist-table'
persistTable.GlobalTable.roses.ClassTable = persistTable.GlobalTable.roses.ClassTable or {}

function read_file(path)
 local iofile = io.open(path,"r")
 local totdat = {}
 local count = 1
 while true do
  local line = iofile:read("*line")
  if line == nil then break end
  totdat[count] = line
  count = count + 1
 end
 iofile:close()

 d = {}
 classes = persistTable.GlobalTable.roses.ClassTable
 count = 1
 for i,x in ipairs(totdat) do
  if split(x,':')[1] == '[CLASS' then
   d[count] = {split(split(x,':')[2],']')[1],i,0}
   count = count + 1
  end
 end
 for i,x in ipairs(d) do
  if i == #d then
   x[3] = #totdat
  else
   x[3] = d[i+1][2]-1
  end
  classes[x[1]]={}
 end
 for i,x in ipairs(d) do
 for j = x[2],x[3],1 do
   test = totdat[j]:gsub("%s+","")
   if split(test,':')[1] == '[NAME' then 
    classes[x[1]]['Name'] = split(split(totdat[j],':')[2],']')[1]
   elseif split(test,':')[1] == '[LEVELS' then 
    classes[x[1]]['Levels'] = split(split(totdat[j],':')[2],']')[1]
   end
  end   
  classes[x[1]]['Experience'] = {}
  classes[x[1]]['RequiredClass'] = {}
  classes[x[1]]['RequiredPhysical'] = {}
  classes[x[1]]['RequiredCounter'] = {}
  classes[x[1]]['RequiredMental'] = {}
  classes[x[1]]['RequiredCreature'] = {}
  classes[x[1]]['BonusPhysical'] = {}
  classes[x[1]]['BonusMental'] = {}
  classes[x[1]]['RequiredSkill'] = {}
  classes[x[1]]['RequiredTrait'] = {}
  classes[x[1]]['ForbiddenClass'] = {}
  classes[x[1]]['BonusSkill'] = {}
  classes[x[1]]['BonusTrait'] = {}
  classes[x[1]]['Spells'] = {}
  for j = x[2],x[3],1 do
   test = totdat[j]:gsub("%s+","")
   if split(test,':')[1] == '[AUTO_UPGRADE' then 
    classes[x[1]]['AutoUpgrade'] = split(split(totdat[j],':')[2],']')[1]
   elseif split(test,':')[1] == '[EXP' then
    local temptable = {select(2,table.unpack(split(totdat[j],':')))}
	strint = '1'
	for _,v in pairs(temptable) do
	 classes[x[1]]['Experience'][strint] = split(v,']')[1]
	 strint = tostring(strint+1)
	end
--	if tonumber(strint)-1 < tonumber(classes[x[1]]['Levels']) then
--	 print('Incorrect amount of experience numbers, must be equal to number of levels. Assuming linear progression for next experience level')
	 while (tonumber(strint)-1) < tonumber(classes[x[1]]['Levels']) do
	  print('Incorrect amount of experience numbers, must be equal to number of levels. Assuming linear progression for next experience level')
	  classes[x[1]]['Experience'][strint] = tostring(2*tonumber(classes[x[1]]['Experience'][tostring(strint-1)])-tonumber(classes[x[1]]['Experience'][tostring(strint-2)]))
	  strint = tostring(tonumber(strint)+1)
	 end
--	end
   elseif split(test,':')[1] == '[REQUIREMENT_CLASS' then 
    classes[x[1]]['RequiredClass'][split(totdat[j],':')[2]] = split(split(totdat[j],':')[3],']')[1]
   elseif split(test,':')[1] == '[FORBIDDEN_CLASS' then 
    classes[x[1]]['ForbiddenClass'][split(totdat[j],':')[2]] = split(split(totdat[j],':')[3],']')[1]
   elseif split(test,':')[1] == '[REQUIREMENT_SKILL' then 
    classes[x[1]]['RequiredSkill'][split(totdat[j],':')[2]] = split(split(totdat[j],':')[3],']')[1]
   elseif split(test,':')[1] == '[REQUIREMENT_TRAIT' then 
    classes[x[1]]['RequiredTrait'][split(totdat[j],':')[2]] = split(split(totdat[j],':')[3],']')[1]
   elseif split(test,':')[1] == '[REQUIREMENT_COUNTER' then 
    classes[x[1]]['RequiredCounter'][split(totdat[j],':')[2]] = split(split(totdat[j],':')[3],']')[1]
   elseif split(test,':')[1] == '[REQUIREMENT_PHYS' then 
    classes[x[1]]['RequiredPhysical'][split(totdat[j],':')[2]] = split(split(totdat[j],':')[3],']')[1]
   elseif split(test,':')[1] == '[REQUIREMENT_MENT' then 
    classes[x[1]]['RequiredMental'][split(totdat[j],':')[2]] = split(split(totdat[j],':')[3],']')[1]
   elseif split(test,':')[1] == '[REQUIREMENT_CREATURE' then
    classes[x[1]]['RequiredCreature'][split(totdat[j],':')[2]] = split(split(totdat[j],':')[3],']')[1]
   elseif split(test,':')[1] == '[BONUS_PHYS' then 
    local temptable = {select(3,table.unpack(split(totdat[j],':')))}
	local strint = '1'
	classes[x[1]]['BonusPhysical'][split(totdat[j],':')[2]] = {}
	for _,v in pairs(temptable) do
     classes[x[1]]['BonusPhysical'][split(totdat[j],':')[2]][strint] = split(v,']')[1]
	 strint = tostring(strint+1)
	end
	if tonumber(strint)-1 < tonumber(classes[x[1]]['Levels'])+1 then
	 print('Incorrect amount of physical bonus numbers, must be equal to number of levels + 1. Assuming previous physical bonus')
	 while tonumber(strint)-1 < tonumber(classes[x[1]]['Levels'])+1 do
	  classes[x[1]]['BonusPhysical'][split(totdat[j],':')[2]][strint] = classes[x[1]]['BonusPhysical'][split(totdat[j],':')[2]][tostring(strint-1)]
	  strint = tostring(strint+1)
	 end
	end
   elseif split(test,':')[1] == '[BONUS_TRAIT' then
    local temptable = {select(3,table.unpack(split(totdat[j],':')))}
	local strint = '1'
	classes[x[1]]['BonusTrait'][split(totdat[j],':')[2]] = {}
	for _,v in pairs(temptable) do
     classes[x[1]]['BonusTrait'][split(totdat[j],':')[2]][strint] = split(v,']')[1]
	 strint = tostring(strint+1)
	end
	if tonumber(strint)-1 < tonumber(classes[x[1]]['Levels'])+1 then
	 print('Incorrect amount of trait bonus numbers, must be equal to number of levels + 1. Assuming previous trait bonus')
	 while tonumber(strint)-1 < tonumber(classes[x[1]]['Levels'])+1 do
	  classes[x[1]]['BonusTrait'][split(totdat[j],':')[2]][strint] = classes[x[1]]['BonusTrait'][split(totdat[j],':')[2]][tostring(strint-1)]
	  strint = tostring(strint+1)
	 end
	end
   elseif split(test,':')[1] == '[BONUS_SKILL' then
    local temptable = {select(3,table.unpack(split(totdat[j],':')))}
	local strint = '1'
	classes[x[1]]['BonusSkill'][split(totdat[j],':')[2]] = {}
	for _,v in pairs(temptable) do
     classes[x[1]]['BonusSkill'][split(totdat[j],':')[2]][strint] = split(v,']')[1]
	 strint = tostring(strint+1)
	end
	if tonumber(strint)-1 < tonumber(classes[x[1]]['Levels'])+1 then
	 print('Incorrect amount of skill bonus numbers, must be equal to number of levels + 1. Assuming previous skill bonus')
	 while tonumber(strint)-1 < tonumber(classes[x[1]]['Levels'])+1 do
	  classes[x[1]]['BonusSkill'][split(totdat[j],':')[2]][strint] = classes[x[1]]['BonusSkill'][split(totdat[j],':')[2]][tostring(strint-1)]
	  strint = tostring(strint+1)
	 end
	end
   elseif split(test,':')[1] == '[BONUS_MENT' then
    local temptable = {select(3,table.unpack(split(totdat[j],':')))}
	local strint = '1'
	classes[x[1]]['BonusMental'][split(totdat[j],':')[2]] = {}
	for _,v in pairs(temptable) do
     classes[x[1]]['BonusMental'][split(totdat[j],':')[2]][strint] = split(v,']')[1]
	 strint = tostring(strint+1)
	end
	if tonumber(strint)-1 < tonumber(classes[x[1]]['Levels'])+1 then
	 print('Incorrect amount of mental bonus numbers, must be equal to number of levels + 1. Assuming previous mental bonus')
	 while tonumber(strint)-1 < tonumber(classes[x[1]]['Levels'])+1 do
	  classes[x[1]]['BonusMental'][split(totdat[j],':')[2]][strint] = classes[x[1]]['BonusMental'][split(totdat[j],':')[2]][tostring(strint-1)]
	  strint = tostring(strint+1)
	 end
	end
   elseif split(test,':')[1] == '[SPELL' then 
    spell = split(totdat[j],':')[2]
    classes[x[1]]['Spells'][spell] = {}
	classes[x[1]]['Spells'][spell]['RequiredLevel'] = split(split(totdat[j],':')[3],']')[1]
--	classes[x[1]]['Spells'][spell]['AutoLearn'] = 'false'
	classes[x[1]]['Spells'][spell]['Cost'] = '0'
	classes[x[1]]['Spells'][spell]['RequiredPhysical'] = {}
	classes[x[1]]['Spells'][spell]['RequiredMental'] = {}
	classes[x[1]]['Spells'][spell]['ForbiddenSpell'] = {}
	classes[x[1]]['Spells'][spell]['ForbiddenClass'] = {}
	if classes[x[1]]['Spells'][spell]['RequiredLevel'] == 'AUTO' then
	 classes[x[1]]['Spells'][spell]['RequiredLevel'] = '0'
	 classes[x[1]]['Spells'][spell]['AutoLearn'] = 'true'
	end
   elseif split(test,':')[1] == '[SPELL_REQUIRE_PHYS' then
    classes[x[1]]['Spells'][spell]['RequiredPhysical'][split(totdat[j],':')[2]] = split(split(totdat[j],':')[3],']')[1]
   elseif split(test,':')[1] == '[SPELL_REQUIRE_MENT' then
    classes[x[1]]['Spells'][spell]['RequiredMental'][split(totdat[j],':')[2]] = split(split(totdat[j],':')[3],']')[1]
   elseif split(test,':')[1] == '[SPELL_FORBIDDEN_SPELL' then
    classes[x[1]]['Spells'][spell]['ForbiddenSpell'][split(totdat[j],':')[2]] = split(split(totdat[j],':')[2],']')[1]
   elseif split(test,':')[1] == '[SPELL_FORBIDDEN_CLASS' then
    classes[x[1]]['Spells'][spell]['ForbiddenClass'][split(totdat[j],':')[2]] = split(split(totdat[j],':')[3],']')[1]
   elseif split(test,':')[1] == '[SPELL_UPGRADE' then
    classes[x[1]]['Spells'][spell]['Upgrade'] = split(split(totdat[j],':')[2],']')[1]
   elseif split(test,':')[1] == '[SPELL_COST' then
    classes[x[1]]['Spells'][spell]['Cost'] = split(split(totdat[j],':')[2],']')[1]
   elseif split(test,':')[1] == '[SPELL_EXP_GAIN' then
    classes[x[1]]['Spells'][spell]['ExperienceGain'] = split(split(totdat[j],':')[2],']')[1]
   elseif split(test,':')[1] == '[SPELL_AUTO_LEARN' then
    classes[x[1]]['Spells'][spell]['AutoLearn'] = 'true'
--   else
--    print('Unrecognized token in classes.txt '..totdat[j]..' line '..tostring(j))
   end
  end
 end
 return classes
end

return read_file