--unit/trait-change.lua v1.0

local split = require('split')
local utils = require 'utils'

function createcallback(etype,unitTarget,ctype,strength,save)
 return function(reseteffect)
  save = effect(etype,unitTarget,ctype,strength,save,-1)
 end
end
function effect(etype,unitTarget,ctype,strength,save,dir)
 local value = 0
 local int16 = 30000
 local int32 = 200000000
 if dir == 1 then save = unitTarget.status.current_soul.traits[etype] end

 if ctype == 'fixed' then
  value = unitTarget.status.current_soul.traits[etype] + strength
 elseif ctype == 'percent' then
  percent = (100+strength)/100
  value = unitTarget.status.current_soul.traits[etype]*strength
 elseif ctype == 'set' then
  value = strength
 end
 if dir == -1 then value = save end
 if value > 100 then value = 100 end
 if value < 0 then value = 0 end
 unitTarget.status.current_soul.traits[etype] = value

 return save
end

validArgs = validArgs or utils.invert({
 'help',
 'trait',
 'fixed',
 'percent',
 'set',
 'dur',
 'unit',
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
 print([[trait-change.lua
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
   -dur #
     length of time, in in-game ticks, for the change to last
     0 means the change is permanent
     DEFAULT: 0
   -fixed #                            \
     change trat by fixed amount       |
   -percent #                          |
     change trait by percentage amount | Must have one and only one of these arguments
   -set #                              |
     set trait to this value           /
  examples:
   unit-trait-change -unit \\UNIT_ID -fixed \-10 -trait ANGER
   unit-trait-change -unit \\UNIT_ID -set 100 -trait DEPRESSION
 ]])
 return
end

if args.unit and tonumber(args.unit) then -- Check for unit declaration !REQUIRED
 unit = df.unit.find(tonumber(args.unit))
else
 print('No unit selected')
 return
end
if args.trait then -- Check which traits to change !REQUIRED
 if type(args.trait) == 'table' then
  token = args.trait
 else
  token = {args.trait}
 end
else
 print('No traits to change set')
 return
end
if args.fixed then -- Check for type of change to make (fixed, percent, or set) !REQUIRED
 mode = 'fixed'
 if type(args.fixed) == 'table' then
  value = args.fixed
 else
  value = {args.fixed}
 end
elseif args.percent then
 mode = 'percent'
 if type(args.percent) == 'table' then
  value = args.percent
 else
  value = {args.percent}
 end
elseif args.set then
 mode = 'set'
 if type(args.set) == 'table' then
  value = args.set
 else
  value = {args.set}
 end
else
 mode = 'fixed'
 if type(args.fixed) == 'table' then
  value = args.fixed
 else
  value = {args.fixed}
 end
end
dur = tonumber(args.dur) or 0 -- Check if there is a duration (default 0)

for i,etype in ipairs(token) do -- !!RUN EFFECT!!
 save = effect(etype,unit,mode,tonumber(value[i]),0,1)
 if dur > 0 then
  dfhack.timeout(dur,'ticks',createcallback(etype,unit,mode,tonumber(value[i]),save))
 end
end
