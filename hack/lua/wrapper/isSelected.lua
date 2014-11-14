split = require('split')

local function isSelected(unitSelf,unitCenter,unitTarget,args,count)
 silence = args.silence or 'NONE'
 reflect = args.reflect or 'NONE'
 radius = args.radius or '-1,-1,-1'
 plan = args.plan or 'NONE'
 age = args.age or 'NONE'
 speed = args.speed or 'NONE'
 physical = args.physical or 'NONE'
 mental = args.mental or 'NONE'
 skill = args.skill or 'NONE'
 trait = args.trait or 'NONE'
 noble = args.noble or 'NONE'
 profession = args.profession or 'NONE'
 entity = args.entity or 'NONE'
 iclass = args.iclass or 'NONE'
 icreature = args.icreature or 'NONE'
 isyndrome = args.isyndrome or 'NONE'
 itoken = args.itoken or 'NONE'
 aclass = args.aclass or 'NONE'
 acreature = args.acreature or 'NONE'
 asyndrome = args.asyndrome or 'NONE'
 atoken = args.atoken or 'NONE'
 counters = args.counters or 'NONE'
 
 local output = {
 caster = unitSelf,
 verbose = args.verbose or false,
 }

-- Silence Check
 if silence ~= 'NONE' then
  if type(silence) ~= 'table' then silence = {silence} end
  local syndromes = df.global.world.raws.syndromes.all
  local sactives = unitSelf.syndromes.active
  for _,x in ipairs(sactives) do
   local ssynclass=syndromes[x.type].syn_class
   for _,y in ipairs(ssynclass) do
    for _,z in ipairs(silence) do
     if z == y.value then
      output['selected'] = {false}
      output['targets'] = {'NONE'}
      output['announcement'] = {'Casting failed, ' .. tostring(unitSelf.name.first_name) .. ' is prevented from using the interaction.'}
      return output 
     end
    end
   end
  end
 end

-- Distance Check
 checkDistance = require('wrapper.checkDistance')
 local selected,targetList,announcement = checkDistance(unitTarget,radius,plan) 

-- Unit Checks
 for i = 1, #targetList, 1 do
  local unitCheck = targetList[i]

-- Target Check
  checkTarget = require('wrapper.checkTarget')
  selected[i],announcement[i] = checkTarget(unitCheck,args.target,unitSelf)

-- Reflect Check
  if reflect ~= 'NONE' and selected[i] then
   if type(reflect) ~= 'table' then reflect = {reflect} end
   local syndromes = df.global.world.raws.syndromes.all
   local actives = unitCheck.syndromes.active
   for _,x in ipairs(actives) do
    local rsynclass=syndromes[x.type].syn_class
    for _,y in ipairs(rsynclass) do
     for _,z in ipairs(reflect) do
      if z == y.value then 
       targetList[i] = unitSelf
       announcement[i] = tostring(unitCheck.name.first_name) .. ' reflects the interaction back towards ' .. tostring(unitSelf.name.first_name) .. '.'
       unitCheck = unitSelf
      end
     end
    end
   end
  end

-- Age Check
  if age~= 'NONE' and selected[i] then
   checkAge = require('wrapper.checkAge')
   selected[i],announcement[i] = checkAge(unitCheck,age,unitSelf)
  end

-- Speed Check
  if speed ~= 'NONE' and selected[i] then
   checkSpeed = require('wrapper.checkSpeed')
   selected[i],announcement[i] = checkSpeed(unitCheck,speed,unitSelf)
  end

-- Physical Attributes Check
  if physical ~= 'NONE' and selected[i] then
   checkAttributes = require('wrapper.checkAttributes')
   selected[i],announcement[i] = checkAttributes(unitCheck,physical,false,unitSelf)
  end

-- Mental Attributes Check
  if mental ~= 'NONE' and selected[i] then
   checkAttributes = require('wrapper.checkAttributes')
   selected[i],announcement[i] = checkAttributes(unitCheck,mental,true,unitSelf)
  end

-- Skill Level Check
  if skill ~= 'NONE' and selected[i] then
   checkSkills = require('wrapper.checkSkills')
   selected[i],announcement[i] = checkSkills(unitCheck,skill,unitSelf)
  end

-- Trait Check
  if trait ~= 'NONE' and selected[i] then
   checkTraits = require('wrapper.checkTraits')
   selected[i],announcement[i] = checkTraits(unitCheck,trait,unitSelf)
  end

-- Noble Check
  if noble ~= 'NONE' and selected[i] then
   checkNoble = require('wrapper.checkNoble')
   selected[i],announcement[i] = checkNoble(unitCheck,noble)
  end

-- Profession Check
  if profession ~= 'NONE' and selected[i] then
   checkProfession = require('wrapper.checkProfession')
   selected[i],announcement[i] = checkProfession(unitCheck,profession)
  end

-- Entity Check
  if entity ~= 'NONE' and selected[i] then
   checkEntity = require('wrapper.checkEntity')
   selected[i],announcement[i] = checkEntity(unitCheck,entity)
  end

-- Immune Check
  if (iclass ~= 'NONE' or icreature ~= 'NONE' or isyndrome ~= 'NONE' or itoken ~= 'NONE') and selected[i] then
   checkTypes = require('wrapper.checkTypes')
   selected[i],announcement[i] = checkTypes(unitCheck,iclass,icreature,isyndrome,itoken,true)
  end

-- Required Check 
  if (aclass ~= 'NONE' or acreature ~= 'NONE' or asyndrome ~= 'NONE' or atoken ~= 'NONE') and selected[i] then
   checkTypes = require('wrapper.checkTypes')
   selected[i],announcement[i] = checkTypes(unitCheck,aclass,acreature,asyndrome,atoken,false)
  end

-- Counters Check
  if counters ~= 'NONE' and selected[i] then
   checkCounters = require('wrapper.checkCounters')
   selected[i],announcement[i] = checkCounters(unitCheck,counters)
  end

 end

 return selected,targetList,unitSelf,output['verbose'],announcement
end

return isSelected