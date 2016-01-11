local utils = require 'utils'

validArgs = validArgs or utils.invert({
 'help',
 'civ',
 'unit',
 'amount',
 'verbose'
})
local args = utils.processArgs({...}, validArgs)

if args.unit then
 args.civ = df.unit.find(tonumber(args.unit)).civ_id
end
civid = tonumber(args.civ)
if args.amount then
 amount = tonumber(args.amount)
else
 amount = 1
end

dfhack.script_environment('functions/civilization').changeLevel(civid,amount,args.verbose)

