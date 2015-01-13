--unit/value-change.lua v1.0

local split = require('split')
local utils = require 'utils'

function createcallback(etype,unitTarget,ctype,strength,save)
 return function(reseteffect)
  effect(etype,unitTarget,ctype,strength,save,-1)
 end
end
function effect(e,unitTarget,ctype,strength,save,dir)
 local value = 0
 local t = 0
 local int16 = 30000
 local int32 = 200000000
 if (e == 'webbed' or e == 'stunned' or e == 'winded' or e == 'unconscious' or e == 'pain'
 or e == 'nausea' or e == 'dizziness') then
  value = unitTarget.counters[e]
  if dir == 1 then save = value end
  if ctype == 'fixed' then
   value = value + strength
  elseif ctype == 'percent' then
   local percent = (100+strength)/100
   value = math.floor(value*percent)
  elseif ctype == 'set' then
   value = strength
  end
  if value > int16 then value = int16 end
  if value < 0 then value = 0 end
  if dir == -1 then value = save end
  unitTarget.counters[e] = value
 elseif (e == 'paralysis' or e == 'numbness' or e == 'fever' or e == 'exhaustion' 
 or e == 'hunger' or e == 'thirst' or e == 'sleepiness') then
  if (e == 'hunger' or e == 'thirst' or e == 'sleepiness') then e = e .. '_timer' end
  value = unitTarget.counters2[e]
  if dir == 1 then save = value end
  if ctype == 'fixed' then
   value = value + strength
  elseif ctype == 'percent' then
   local percent = (100+strength)/100
   value = math.floor(value*percent)
  elseif ctype == 'set' then
   value = strength
  end
  if value > int16 then value = int16 end
  if value < 0 then value = 0 end
  if dir == -1 then value = save end
  unitTarget.counters2[e] = value
 elseif e == 'blood' then
  if dir == 1 then save = value end
  if ctype == 'fixed' then
   value = value + strength
  elseif ctype == 'percent' then
   local percent = (100+strength)/100
   value = math.floor(value*percent)
  elseif ctype == 'set' then
   value = strength
  end
  if value > unitTarget.body.blood_max then value = unitTarget.body.blood_max end
  if value < 0 then value = 0 end
  unitTarget.body.blood_count = value
 elseif e == 'infection' then
  value = unitTarget.body.infection_level
  if dir == 1 then save = value end
  if ctype == 'fixed' then
   value = value + strength
  elseif ctype == 'percent' then
   local percent = (100+strength)/100
   value = math.floor(value*percent)
  elseif ctype == 'set' then
   value = strength
  end
  if value > int16 then value = int16 end
  if value < 0 then value = 0 end
  unitTarget.body.infection_level = value
 end
end

validArgs = validArgs or utils.invert({
 'help',
 'token',
 'fixed',
 'percent',
 'set',
 'dur',
 'unit',
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
 print([[value-change.lua
  Change the value(s) of a unit
  arguments:
   -help
     print this help message
   -unit id
     REQUIRED
     id of the target unit
   -token TYPE
     REQUIRED
     token to be changed
     valid types:
      webbed
      stunned
      winded
      unconscious
      pain
      nausea
      dizziness
      paralysis
      numbness
      fever
      exhaustion
      hunger
      thirst
      sleepiness
      blood
      infection    
   -dur #
     length of time, in in-game ticks, for the change to last
     0 means the change is permanent
     DEFAULT: 0
   -fixed #                                  \
     change token value by fixed amount      |
   -percent #                                |
     change token value by percentage amount | Must have one and only one of these arguments
   -set #                                    |
     set token value to this value           /
  examples:
   unit-value-change -unit \\UNIT_ID -fixed 10000 -token stunned -dur 10
   unit-value-change -unit \\UNIT_ID -set [0,0,0,0] -token [nausea,dizziness,numbness,fever]
   unit-value-change -unit \\UNIT_ID -percent \-100 -token blood
 ]])
 return
end

if args.unit and tonumber(args.unit) then -- Check for unit declaration !REQUIRED
 unit = df.unit.find(tonumber(args.unit))
else
 print('No unit selected')
 return
end
if args.token then -- Check which tokens to change !REQUIRED
 if type(args.token) == 'table' then
  token = args.token
 else
  token = {args.token}
 end
else
 print('No token to change set')
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
 print('No method of changing token set')
 return
end
dur = tonumber(args.dur) or 0 -- Check if there is a duration (default 0)
printall(args)
for i,etype in ipairs(token) do -- !!RUN EFFECT!!
 save = effect(etype,unit,mode,tonumber(value[i]),0,1)
 if dur > 0 then
  dfhack.timeout(dur,'ticks',createcallback(etype,unit,mode,tonumber(value[i]),save))
 end
end


