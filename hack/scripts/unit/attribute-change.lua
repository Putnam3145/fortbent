--unit/attribute-change.lua v1.0

local split = require('split')
local utils = require 'utils'

function createcallback(etype,mental,unitTarget,ctype,strength,save)
 return function(reseteffect)
  effect(etype,mental,unitTarget,ctype,strength,save,-1)
 end
end
function effect(etype,mental,unitTarget,ctype,strength,save,dir)
 local value = 0
 local int16 = 30000
 local int32 = 200000000

 if mental == 'physical' then
  if dir == 1 then save = unitTarget.body.physical_attrs[etype].value end
  value = unitTarget.body.physical_attrs[etype].value
  if ctype == 'fixed' then
   value = value + strength
  elseif ctype == 'percent' then
   local percent = (100+strength)/100
   value = value*percent
  elseif ctype == 'set' then
   value = strength
  end
  if value > int16 then value = int16 end
  if value < 0 then value = 0 end
  if dir == -1 then value = save end
  unitTarget.body.physical_attrs[etype].value = value
 elseif mental == 'mental' then
  if dir == 1 then save = unitTarget.status.current_soul.mental_attrs[etype].value end
  value = unitTarget.status.current_soul.mental_attrs[etype].value
  if ctype == 'fixed' then
   value = value + strength
  elseif ctype == 'percent' then
   local percent = (100+strength)/100
   value = value*percent
  elseif ctype == 'set' then
   value = strength
  end
  if value > int16 then value = int16 end
  if value < 0 then value = 0 end
  if dir == -1 then value = save end
  unitTarget.status.current_soul.mental_attrs[etype].value = value
 end
 return save
end

validArgs = validArgs or utils.invert({
 'help',
 'mental',
 'physical',
 'fixed',
 'percent',
 'set',
 'dur',
 'unit',
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
 print([[attribute-change.lua
  Change the attribute(s) of a unit
  arguments:
   -help
     print this help message
   -unit id
     REQUIRED
     id of the target unit
   -dur #
     length of time, in in-game ticks, for the change to last
     0 means the change is permanent
     DEFAULT: 0
   -fixed #                                \
     change attribute by fixed amount      |
   -percent #                              |
     change attribute by percentage amount | Must have one and only one of these arguments
   -set #                                  |
     set attribute to this value           /
   -mental ATTRIBUTE_ID    \
     mental attribute id   |
   -physical ATTRIBUTE_ID  | Must have one and only one of these arguments
     physical attribute id /
  examples:
   unit-attribute-change -unit \\UNIT_ID -fixed 100 -physical STRENGTH
   unit-attribute-change -unit \\UNIT_ID -percent [10,10,10] -physical [ENDURANCE,TOUGHNESS,RECUPERATION] -dur 3600
   unit-attribute-change -unit \\UNIT_ID -set 5000 -mental WILLPOWER -dur 1000
 ]])
 return
end
printall(args)
if args.unit and tonumber(args.unit) then -- Check for unit declaration !REQUIRED
 unit = df.unit.find(tonumber(args.unit))
else
 print('No unit selected')
 return
end
if args.fixed then -- Check for type of change to make, fixed, percent, or set (default fixed)
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

if args.mental then -- Check if you are changing mental attributes. !!RUN EFFECT!! !REQUIRED
 mental = 'mental'
 if type(args.mental) == 'table' then
  token = args.mental
 else
  token = {args.mental}
 end
 for i,etype in ipairs(token) do
  save = effect(etype,mental,unit,mode,tonumber(value[i]),0,1)
  if dur > 0 then
   dfhack.timeout(dur,'ticks',createcallback(etype,mental,unit,mode,tonumber(value[i]),save))
  end
 end
elseif args.physical then -- Check if you are changing physical attributes. !!RUN EFFECT!!
 mental = 'physical'
 if type(args.physical) == 'table' then
  token = args.physical
 else
  token = {args.physical}
 end 
 for i,etype in ipairs(token) do
  save = effect(etype,mental,unit,mode,tonumber(value[i]),0,1)
  if dur > 0 then
   dfhack.timeout(dur,'ticks',createcallback(etype,mental,unit,mode,tonumber(value[i]),save))
  end
 end
end

return "test"