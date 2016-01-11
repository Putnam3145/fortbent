local utils = require 'utils'

validArgs = validArgs or utils.invert({
 'help',
 'civ',
 'position',
 'remove',
 'add',
 'verbose'
})
local args = utils.processArgs({...}, validArgs)

civid = tonumber(args.civ)
position = args.position
direction = 0
if args.remove then direction = -1 end
if args.add then direction = 1 end
if args.add and args.removes then return end
if direction == 0 then
 print('No valid command, use -remove or -add')
 return
end

dfhack.script_environment('functions/entity').changeNoble(civid,position,direction,args.verbose)