--unit/body-change.lua v2.0

local utils = require 'utils'

validArgs = validArgs or utils.invert({
 'help',
 'temperature',
 'category',
 'token',
 'flag',
 'all',
 'dur',
 'unit',
 'announcement',
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
   -dur #
     length of time, in in-game ticks, for the change to last
     0 means the change is permanent
     DEFAULT: 0
  examples:
   unit/body-change -unit \\UNIT_ID -flag GRASP -temperature fire -dur 1000
   unit/body-change -unit \\UNIT_ID -category LEG_LOWER -temperature 8000
 ]])
 return
end

if args.unit and tonumber(args.unit) then
 unit = df.unit.find(tonumber(args.unit))
else
 print('No unit selected')
 return
end

if args.temperature then
 strength = args.temperature
 changeType = 'temperature'
else
 print('No temperature declared')
 return
end

parts = {}
if args.all then
 body = unit.body.body_plan.body_parts
 for k,v in ipairs(body) do
  parts[k] = k
 end
elseif args.category then
 parts = dfhack.script_environment('functions/unit').checkBodyCategory(unit,args.category)
elseif args.token then
 parts = dfhack.script_environment('functions/unit').checkBodyToken(unit,args.token)
elseif args.flag then
 parts = dfhack.script_environment('functions/unit').checkBodyFlag(unit,args.flag)
else
 print('No body parts declared')
 return
end

dur = tonumber(args.dur) or 0

for _,part in ipairs(parts) do
 dfhack.script_environment('functions/unit').changeBody(unit,part,changeType,strength,dur)
end