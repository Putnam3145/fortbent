local utils = require 'utils'

validArgs = validArgs or utils.invert({
 'help',
 'unit',
 'amount',
 'verbose'
})
local args = utils.processArgs({...}, validArgs)

if args.unit and tonumber(args.unit) then
 unit = df.unit.find(tonumber(args.unit))
else
 print('No unit declared')
 return
end

if args.amount and tonumber(args.amount) then
 amount = tonumber(args.amount)
else
 amount = 0
end

verbose = false
if args.verbose then verbose = true end

dfhack.script_environment('functions/class').addExperience(unit,amount,verbose)