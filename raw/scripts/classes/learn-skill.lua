local utils = require 'utils'

validArgs = validArgs or utils.invert({
 'help',
 'unit',
 'spell',
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

if args.spell then
 spell = args.spell
else
 print('No spell declared')
 return
end

verbose = false
if args.verbose then verbose = true end

if args.override then
 yes = true
else
 yes = dfhack.script_environment('functions/class').checkRequirementsSpell(unit,spell,verbose)
end
if yes then
 success = dfhack.script_environment('functions/class').changeSpell(unit,spell,'add',verbose)
 if success then
 -- Erase items used for reaction
 end
end