--unit/trait-change.lua v2.0

local utils = require 'utils'

validArgs = validArgs or utils.invert({
 'help',
 'trait',
 'fixed',
 'percent',
 'set',
 'dur',
 'unit',
 'announcement',
 'track',
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
 print([[unit/trait-change.lua
  Change the trait(s) of a unit
  arguments:
   -help
     print this help message
   -unit id
     REQUIRED
     id of the target unit
   -trait TRAIT_TOKEN
     REQUIRED
     trait to be changed
   -fixed #                            \
     change trat by fixed amount       |
   -percent #                          |
     change trait by percentage amount | Must have one and only one of these arguments
   -set #                              |
     set trait to this value           /
   -dur #
     length of time, in in-game ticks, for the change to last
     0 means the change is permanent
     DEFAULT: 0
  examples:
   unit/trait-change -unit \\UNIT_ID -fixed \-10 -trait ANGER
   unit/trait-change -unit \\UNIT_ID -set 100 -trait DEPRESSION
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
if type(args.trait) == 'string' then args.trait = {args.trait} end
if #value ~= #args.trait then
 print('Mismatch between number of skills declared and number of changes declared')
 return
end

track = nil
if args.track then track = 'track' end

for i,trait in ipairs(args.trait) do
 current = unit.status.current_soul.personality.traits[trait]

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
 dfhack.script_environment('functions/unit').changeTrait(unit,trait,change,dur,track)
end
if args.announcement then
--add announcement information
end