--unit/skill-change.lua v2.0

local utils = require 'utils'

validArgs = validArgs or utils.invert({
 'help',
 'skill',
 'fixed',
 'percent',
 'set',
 'dur',
 'unit',
 'announcment',
 'track',
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
 print([[unit/skill-change.lua
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
   -fixed #                            \
     change skill by fixed amount      |
   -percent #                          |
     change skill by percentage amount | Must have one and only one of these arguments
   -set #                              |
     set skill to this value           /
   -dur #
     length of time, in in-game ticks, for the change to last
     0 means the change is permanent
     DEFAULT: 0
  examples:
   unit/skill-change -unit \\UNIT_ID -fixed 1 -skill ALCHEMY
   unit/skill-change -unit \\UNIT_ID -set [ 0 0 0 ] -skill [ GRASP_STRIKE STANCE_STRIKE DODGER ]
 ]])
 return
end

if args.unit and tonumber(args.unit) then
 unit = df.unit.find(tonumber(args.unit))
else
 print('No unit selected')
 return
end

value = args.fixed or args.percent or args.set

dur = tonumber(args.dur) or 0
if type(value) == 'string' then value = {value} end
if type(args.skill) == 'string' then args.skill = {args.skill} end
if #value ~= #args.skill then
 print('Mismatch between number of skills declared and number of changes declared')
 return
end

track = nil
if args.track then track = 'track' end

for i,skill in ipairs(args.skill) do
 local skills = unit.status.current_soul.skills
 local skillid = df.job_skill[skill]
 local found = false
 for i,x in ipairs(skills) do
  if x.id == skillid then
   found = true
   token = x
   current = token.rating
   break
  end
 end
 if not found then
  utils.insert_or_update(unit.status.current_soul.skills,{new = true, id = skillid, rating = 0},'id')
  skills = unit.status.current_soul.skills
  for i,x in ipairs(skills) do
   if x.id == skillid then
    found = true
    token = x
    current = token.rating
    break
   end
  end
 end

 if args.fixed then
  change = tonumber(value[i])
 elseif args.percent then
  local percent = (100+tonumber(value[i]))/100
  change = current*percent - current
 elseif args.set then
  change = tonumber(value[i]) - current
 else
  print('No method for change declared')
  return
 end
 dfhack.script_environment('functions/unit').changeSkill(unit,skill,change,dur,track)
end
if args.announcement then
--add announcement information
end