--base/classes.lua v1.0
--MUST BE LOADED IN DFHACK.INIT

radius = -1

split = require('split')
events = require "plugins.eventful"
events.enableEvent(events.eventType.UNIT_DEATH,100)
filename = dfhack.getDFPath().."/raw/objects/classes.txt"
local establishclass = require('classes.establish-class')
local read_file = require('classes.read-file')
local checkclass = require('classes.requirements-class')
local checkspell = require('classes.requirements-spell')

function check(unit,unitTarget,radius)
 if radius == -1 and unit.id == unitTarget.id then
  return true
 elseif radius == -1 and unit.id ~= unitTarget.id then
  return false
 end
	
 local xmin = unitTarget.pos.x - radius
 local xmax = unitTarget.pos.x + radius
 local ymin = unitTarget.pos.y - radius
 local ymax = unitTarget.pos.y + radius
 local zmin = unitTarget.pos.z - radius
 local zmax = unitTarget.pos.z + radius

 if (unit.pos.x >= xmin and unit.pos.x <= xmax and unit.pos.y >= ymin and unit.pos.y <= ymax and unit.pos.z >= zmin and unit.pos.z <= zmax) then 
  if unit.civ_id == unitTarget.civ_id then return true end
 end
	
 return false
end

events.onUnitDeath.teleport=function(unit_id)
 unit = df.unit.find(unit_id)
 killer_id = tonumber(unit.relations.last_attacker_id)
 local unitList = df.global.world.units.active
 if killer_id >=0 then
  for i = 0, #unitList-1,1 do
   local unit = unitList[i]
   if check(unit,unitKiller,radius) then
    kill_id = unit.id
   --name = dfhack.unit.getVisibleName(unit)
   --kill_name = dfhack.unit.getVisibleName(df.unit.find(tonumber(kill_id)))
    local unitraws = df.creature_raw.find(unit.race)
    local casteraws = unitraws.caste[unit.caste]
    local unitracename = unitraws.creature_id
    local castename = casteraws.caste_id
    local unitclasses = casteraws.creature_class
    exps = 1
    for _,unitclass in ipairs(unitclasses) do
     if split(unitclass.value,'_')[1] == 'EXPERIENCE' then
      exps = tonumber(split(unitclass.value,'_')[2])
     end
    end
    classes = read_file(filename)
    establishclass(df.unit.find(tonumber(kill_id)),classes)
    pers,status = dfhack.persistent.get(tostring(kill_id)..'_current_class')
    pers.ints[1] = pers.ints[1] + exps
    pers.ints[2] = pers.ints[2] + exps
    dfhack.persistent.save({key=tostring(kill_id)..'_current_class',value=pers.value,ints=pers.ints})
    --print(kill_name..' '..tostring(kill_id)..' killed '..name..' '..tostring(unit_id)..' and earned '..tostring(exps)..' experience. Total experience is '..tostring(pers.ints[2]))
    if pers.value ~= 'NONE' then
     cpers,status = dfhack.persistent.get(tostring(kill_id)..'_'..pers.value)
     clevel = cpers.ints[2]
     if clevel < classes[pers.value]['LEVELS'] then
      cexp = tonumber(split(classes[pers.value]['EXP'][clevel+1],']')[1])
      if pers.ints[1] > cexp then
       cpers.ints[2] = cpers.ints[2] + 1
        print('LEVEL UP!! '..pers.value..' LEVEL '..tostring(cpers.ints[2]))
        if classes[pers.value]['B_PHYS'] then
         for i,x in pairs(classes[pers.value]['B_PHYS']) do
          dfhack.run_script('unit/attribute-change',table.unpack({'-unit',tostring(kill_id),'-physical',i,'-fixed','\\'..tostring(tonumber(split(x[cpers.ints[2]+1],']')[1])-tonumber(split(x[cpers.ints[2]],']')[1]))}))
         end
        end
        if classes[pers.value]['B_MENT'] then
         for i,x in pairs(classes[pers.value]['B_MENT']) do
          dfhack.run_script('unit/attribute-change',table.unpack({'-unit',tostring(kill_id),'-mental',i,'-fixed','\\'..tostring(tonumber(split(x[cpers.ints[2]+1],']')[1])-tonumber(split(x[cpers.ints[2]],']')[1]))}))
         end
        end
        if classes[pers.value]['B_SKILL'] then
         for i,x in pairs(classes[pers.value]['B_SKILL']) do
          dfhack.run_script('unit/skill-change',table.unpack({'-unit',tostring(kill_id),'-skill',i,'-fixed','\\'..tostring(tonumber(split(x[cpers.ints[2]+1],']')[1])-tonumber(split(x[cpers.ints[2]],']')[1]))}))
         end
        end
        if classes[pers.value]['B_TRAIT'] then
         for i,x in pairs(classes[pers.value]['B_TRAIT']) do
          dfhack.run_script('unit/trait-change',table.unpack({'-unit',tostring(kill_id),'-trait',i,'-fixed','\\'..tostring(tonumber(split(x[cpers.ints[2]+1],']')[1])-tonumber(split(x[cpers.ints[2]],']')[1]))}))
         end
        end
	    if cpers.ints[2] == classes[pers.value]['LEVELS'] then 
	     print('REACHED MAX LEVEL FOR CLASS '..pers.value)
	     if classes[pers.value]['A_UPGRADE'] then dfhack.run_script('classes/change-class',table.unpack({'-unit',tostring(kill_id),'-class',classes[pers.value]['A_UPGRADE']})) end
	    end
       end
      end
     dfhack.persistent.save({key=tostring(kill_id)..'_'..cpers.value,value=cpers.value,ints=cpers.ints})
    end
   end
  end
 end
end
