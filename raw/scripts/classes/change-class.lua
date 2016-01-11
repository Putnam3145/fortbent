local utils = require 'utils'

validArgs = validArgs or utils.invert({
 'help',
 'unit',
 'class',
 'override',
 'verbose'
})
local args = utils.processArgs({...}, validArgs)

if args.unit and tonumber(args.unit) then
 unit = df.unit.find(tonumber(args.unit))
else
 print('No unit declared')
 return
end

if args.class then
 class = args.class
else
 print('No class declared')
 return
end

verbose = false
if args.verbose then verbose = true end

if args.override then
 yes = true
else
 yes = dfhack.script_environment('functions/class').checkRequirementsClass(unit,class,verbose)
end
if yes then
 success = dfhack.script_environment('functions/class').changeClass(unit,class,verbose)
 if success then
 -- Erase items used for reaction
 end
end