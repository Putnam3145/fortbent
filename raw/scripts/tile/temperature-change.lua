--temperature-change.lua v1.0

local utils = require 'utils'

validArgs = validArgs or utils.invert({
 'help',
 'plan',
 'location',
 'temperature',
 'dur',
 'unit',
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
 print([[tile/temperature-change.lua
  Changes a tiles temperature
  arguments:
   -help
     print this help message
   -unit id
     id of the unit to center on
     required if using -plan
   -plan filename                           \
     filename of plan to use (without .txt) |
   -location [# # #]                        | Must have at least one of these
     x,y,z coordinates to use for position  /
   -temperature #
     temperature to set tile to
   -dur #
     length of time for tile change to last
     0 means the change is natural and will revert back to normal temperature
     DEFAULT 0
  examples:
   tile/temperature-change -unit \\UNIT_ID -plan 5x5_X -temperature 15000 -dur 1000
   tile/temperature-change -location [ \\LOCATION ] -temperature 8000
 ]])
 return
end

dur = tonumber(args.dur) or 0 -- Check if there is a duration (default 0)

if args.plan then
 if args.unit and tonumber(args.unit) then
  pos = df.unit.find(tonumber(args.unit)).pos
 elseif args.location then
  pos = args.location
 else
  print('No center decleration, need -unit or -location')
  return
 end
 locations,n = dfhack.script_environment('functions/map').getPositionPlan(file,pos)
 for i,loc in ipairs(locations) do
  dfhack.script_environment('functions/map').changeTemperature(loc,nil,nil,args.temperature,dur)
 end
end
if args.location then
 dfhack.script_environment('functions/map').changeTemperature(args.location[1],args.location[2],args.location[3],args.temperature,dur)
end