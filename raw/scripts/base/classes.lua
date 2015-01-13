--base/classes.lua v1.0
--MUST BE LOADED IN DFHACK.INIT

radius = -1

local persistTable = require 'persist-table'
persistTable.GlobalTable.roses = persistTable.GlobalTable.roses or {}
persistTable.GlobalTable.roses.UnitTable = persistTable.GlobalTable.roses.UnitTable or {}

local split = require('split')
local events = require "plugins.eventful"
events.enableEvent(events.eventType.UNIT_DEATH,10)
local establishclass = require('classes.establish-class')
local read_file = require('classes.read-file')
local checkclass = require('classes.requirements-class')
local checkspell = require('classes.requirements-spell')

local dir = dfhack.getDFPath().."/raw/objects/"
for _,fname in pairs(dfhack.internal.getDir(dir)) do
 if split(fname,'_')[1] == 'classes' or fname == 'classes.txt' then
  read_file(dir..fname)
 end
end

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
  unitKiller = df.unit.find(killer_id)
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
    establishclass(df.unit.find(tonumber(kill_id)))
	local unitClasses = persistTable.GlobalTable.roses.UnitTable[tostring(kill_id)]['Classes']
	local currentClass = persistTable.GlobalTable.roses.UnitTable[tostring(kill_id)]['Classes']['Current']
	local classes = persistTable.GlobalTable.roses.ClassTable
    currentClass['CurrentExp'] = tostring(tonumber(currentClass['CurrentExp'])+exps)
    currentClass['TotalExp'] = tostring(tonumber(currentClass['TotalExp'])+exps)
    currentClass['SkillExp'] = tostring(tonumber(currentClass['SkillExp'])+exps)
    --print(kill_name..' '..tostring(kill_id)..' killed '..name..' '..tostring(unit_id)..' and earned '..tostring(exps)..' experience. Total experience is '..persistTable.GlobalTable.roses.UnitTable[tostring(kill_id)]['Classes']['Current']['TotalExp']))
    if currentClass['Name'] ~= 'None' then
	 local currentClassName = currentClass['Name']
     local currentClassLevel = tonumber(unitClasses[currentClassName]['Level'])
     if currentClassLevel < tonumber(classes[currentClassName]['Levels']) then
	  classExpLevel = tonumber(split(classes[currentClassName]['Experience'][currentClassLevel+1],']')[1])
      if tonumber(currentClass['CurrentExp']) > classExpLevel then
       print('LEVEL UP!! '..currentClassName..' LEVEL '..tostring(tonumber(currentClassLevel)+1))
	   dfhack.run_script('classes/level-up',table.unpack({'-unit',tostring(kill_id)}))
	  end
	 end
	end
   end
  end
 end
end