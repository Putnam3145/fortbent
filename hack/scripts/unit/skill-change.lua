--unit/skill-change.lua v1.0

local split = require('split')
local utils = require 'utils'

function createcallback(etype,unitTarget,ctype,strength,save)
 return function(reseteffect)
  effect(etype,unitTarget,ctype,strength,save,-1)
 end
end
function effect(skill,unit,ctype,strength,save,dir)
 local skills = unit.status.current_soul.skills
 local skillid = df.job_skill[skill]
 local value = 0
 local found = false

 if skills ~= nil then
  for i,x in ipairs(skills) do
   if x.id == skillid then
    if dir == 1 then save = x.rating end
    found = true
    if ctype == 'fixed' then
     value = x.rating + strength
    end
    if ctype == 'percent' then
     percent = (100 + strength)/100
     value = x.rating*percent
    end
    if ctype == 'set' then
     value = strength
    end
    if dir == -1 then value = save end
    if value > 20 then value = 20 end
    if value < 0 then value = 0 end
    x.rating = value
   end
  end
 end

 if not found then
  utils = require 'utils'
  utils.insert_or_update(unit.status.current_soul.skills,{new = true, id = skillid, rating = 1},'id')
  skills = unit.status.current_soul.skills
  for i,x in ipairs(skills) do
   if x.id == skillid then
    if dir == 1 then save = x.rating end
    found = true
    if etype == 'fixed' then
     value = x.rating + strength
    end
    if etype == 'percent' then
     percent = (100 + strength)/100
     value = x.rating*percent
    end
    if etype == 'set' then
     value = strength
    end
    if dir == -1 then value = save end
    if value > 20 then value = 20 end
    if value < 0 then value = 0 end
    x.rating = value
   end
  end
 end
 return save
end

validArgs = validArgs or utils.invert({
 'help',
 'skill',
 'fixed',
 'percent',
 'set',
 'dur',
 'unit',
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
 print([[skill-change.lua
  Change the skill(s) of a unit
  arguments:
   -help
     print this help message
   -unit id
     REQUIRED
     id of the target unit
   -skill SKILL_TOKEN
     REQUIRED
     skill to be changed
   -dur #
     length of time, in in-game ticks, for the change to last
     0 means the change is permanent
     DEFAULT: 0
   -fixed #                            \
     change skill by fixed amount      |
   -percent #                          |
     change skill by percentage amount | Must have one and only one of these arguments
   -set #                              |
     set skill to this value           /
  examples:
   unit-skill-change -unit \\UNIT_ID -fixed 1 -skill ALCHEMY
   unit-skill-change -unit \\UNIT_ID -set [0,0,0] -skill [GRASP_STRIKE,STANCE_STRIKE,DODGER]
 ]])
 return
end

if args.unit and tonumber(args.unit) then -- Check for unit declaration !REQUIRED
 unit = df.unit.find(tonumber(args.unit))
else
 print('No unit selected')
 return
end
if args.skill then -- Check which skills to change !REQUIRED
 if type(args.skill) == 'table' then
  token = args.skill
 else
  token = {args.skill}
 end
else
 print('No skill to change set')
 return
end
if args.fixed then -- Check for type of change to make (fixed, percent, or set) !REQUIRED
 mode = 'fixed'
 if type(args.fixed) == 'table' then
  value = args.fixed
 else
  value = {args.fixed}
 end
elseif args.percent then
 mode = 'percent'
 if type(args.percent) == 'table' then
  value = args.percent
 else
  value = {args.percent}
 end
elseif args.set then
 mode = 'set'
 if type(args.set) == 'table' then
  value = args.set
 else
  value = {args.set}
 end
else
 mode = 'fixed'
 if type(args.fixed) == 'table' then
  value = args.fixed
 else
  value = {args.fixed}
 end
end
dur = tonumber(args.dur) or 0 -- Check if there is a duration (default 0)

for i,etype in ipairs(token) do -- !!RUN EFFECT!!
 save = effect(etype,unit,mode,tonumber(value[i]),0,1)
 if dur > 0 then
  dfhack.timeout(dur,'ticks',createcallback(etype,unit,mode,tonumber(value[i]),save))
 end
end
