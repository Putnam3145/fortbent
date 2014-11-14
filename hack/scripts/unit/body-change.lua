--unit/body-change.lua v1.0

local split = require('split')
local utils = require 'utils'

function checkbodycategory(unit,bp)
 local parts = {}
 local body = unit.body.body_plan.body_parts
 for i,x in ipairs(bp) do
  local a = 1
  for j,y in ipairs(body) do
   if y.category == x and not unit.body.components.body_part_status[j].missing then 
    parts[a] = j
    a = a + 1
   end
  end
 end
 return parts
end
function checkbodytoken(unit,bp)
 local parts = {}
 local body = unit.body.body_plan.body_parts
 for i,x in ipairs(bp) do
  local a = 1
  for j,y in ipairs(body) do
   if y.token == x and not unit.body.components.body_part_status[j].missing then 
    parts[a] = j
    a = a + 1
   end
  end
 end
 return parts
end
function checkbodyflag(unit,bp)
 local parts = {}
 local body = unit.body.body_plan.body_parts
 for i,x in ipairs(bp) do
  local a = 1
  for j,y in ipairs(body) do
   if y.flags[x] and not unit.body.components.body_part_status[j].missing then 
    parts[a] = j
    a = a + 1
   end
  end
 end
 return parts
end

function createcallback(etype,parts,unitTarget,strength,save)
 return function(reseteffect)
  effect(etype,parts,unitTarget,strength,save,-1)
 end
end
function effect(etype,parts,unit,strength,save,dir)
 if etype=="temperature" then
  for k,z in ipairs(parts) do
   if strength == 'fire' then
    if dir == 1 then
     unit.body.components.body_part_status[z].on_fire=true
     unit.flags3.body_temp_in_range=false
    elseif dir == -1 then
     unit.body.components.body_part_status[z].on_fire=false
     unit.flags3.body_temp_in_range=true
    end
   else
    if dir == 1 then 
     save[z] = unit.status2.body_part_temperature[z].whole
     strength = tonumber(strength)
     unit.status2.body_part_temperature[z].whole=strength
    elseif dir == -1 then
     unit.status2.body_part_temperature[z].whole=save[z]
    end
   end
  end
 end
 return save
end

validArgs = validArgs or utils.invert({
 'help',
 'temperature',
 'category',
 'token',
 'flag',
 'all',
 'dur',
 'unit',
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
 print([[body-change.lua
  Change the body parts of a unit (currently only supports changing temperature or setting on fire)
  arguments:
   -help
     print this help message
   -unit id
     REQUIRED
     id of the target unit
   -dur #
     length of time, in in-game ticks, for the change to last
     0 means the change is permanent
     DEFAULT: 0
   -all                                     \
     change all units body parts            |
   -category TYPE                           |
     change body parts of specific category |
     examples:                              |
      TENTACLE                              |
      HOOF_REAR                             |
      HEAD                                  |
   -token TYPE                              |
     change body parts by specific token    | Must at least one of these arguments
     examples:                              |
      UB                                    |
      LB                                    |
      REYE                                  |
   -flag FLAG                               |
     change body parts by specific flag     |
     examples:                              |
      SIGHT                                 |
      LIMB                                  |
      SMALL                                 /
   -temperature #
     temperature to set body parts to
     special token:
      fire - sets the body part on fire
  examples:
   unit-body-change -unit \\UNIT_ID -flag GRASP -temperature fire -dur 1000
   unit-body-change -unit \\UNIT_ID -category LEG_LOWER -temperature 8000
 ]])
 return
end

if args.unit and tonumber(args.unit) then -- Check for unit declaration !REQUIRED
 unit = df.unit.find(tonumber(args.unit))
else
 print('No unit selected')
 return
end
if args.temperature then -- Check for temperature value to set body parts to !REQUIRED
 strength = args.temperature
else
 return
end
dur = tonumber(args.dur) or 0 -- Check if there is a duration (default 0)

if args.all then -- Check for the all body parts flag. !!RUN EFFECT!!
 parts = {}
 body = unit.body.body_plan.body_parts
 for k,v in ipairs(body) do
  parts[k] = k
 end
 save = effect(etype,parts,unit,strength,0,1)
 if dur > 0 then
  dfhack.timeout(dur,'ticks',createcallback(etype,parts,unit,strength,save))
 end
end
if args.category then -- Check for category body parts. !!RUN CHECKBODYCATEGORY!!. !!RUN EFFECT!!
 if type(args.category) == 'table' then
  bp = args.category
 else
  bp = {args.category}
 end
 parts = checkbodycategory(unit,bp)
 save = effect(etype,parts,unit,strength,0,1)
 if dur > 0 then
  dfhack.timeout(dur,'ticks',createcallback(etype,parts,unit,strength,save))
 end
end
if args.token then -- Check for token body parts. !!RUN CHECKBODYTOKEN!!. !!RUN EFFECT!!
 if type(args.token) == 'table' then
  bp = args.token
 else
  bp = {args.token}
 end
 parts = checkbodytoken(unit,bp)
 save = effect(etype,parts,unit,strength,0,1)
 if dur > 0 then
  dfhack.timeout(dur,'ticks',createcallback(etype,parts,unit,strength,save))
 end
end
if args.flag then -- Check for flag body parts. !!RUN CHECKBODYFLAG!!. !!RUN EFFECT!!
 if type(args.flag) == 'table' then
  bp = args.flag
 else
  bp = {args.flag}
 end
 parts = checkbodyflag(unit,bp)
 save = effect(etype,parts,unit,strength,0,1)
 if dur > 0 then
  dfhack.timeout(dur,'ticks',createcallback(etype,parts,unit,strength,save))
 end
end