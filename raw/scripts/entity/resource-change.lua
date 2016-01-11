local utils = require 'utils'
local split = utils.split_string

validArgs = validArgs or utils.invert({
 'help',
 'civ',
 'type',
 'obj',
 'remove',
 'add',
 'verbose'
})
local args = utils.processArgs({...}, validArgs)

civid = tonumber(args.civ)
civ = df.global.world.entities.all[civid]
resources = civ.resources
mtype = string.upper(split(args.type,':')[1])
stype = string.upper(split(args.type,':')[2])
mobj = string.upper(split(args.obj,':')[1])
sobj = string.upper(split(args.obj,':')[2])
direction = 0
if args.remove then direction == -1 end
if args.add then directino == 1 end
if args.add and args.removes then return end
if direction == 0 then
 print('No valid command, use -remove or -add')
 return
end

dfhack.script_environment('functions/entity').changeResources(civ,mtype,stype,mobj,sobj,direction,args.verbose)