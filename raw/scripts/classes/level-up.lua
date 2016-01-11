local utils = require 'utils'

validArgs = validArgs or utils.invert({
 'help',
 'unit',
 'verbose',
 'amount',
})
local args = utils.processArgs({...}, validArgs)

if args.unit and tonumber(args.unit) then
 unit = df.unit.find(tonumber(args.unit))
else
 print('No unit declared')
 return
end

if args.amount then
 amount = tonumber(args.amount)
else
 amount = 1
end

verbose = false
if args.verbose then verbose = true end

dfhack.script_environment('functions/class').changeLevel(unit,amount,verbose)