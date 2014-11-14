--special-counters.lua v1.0
   
local split = require('split')
local utils = require 'utils'

function counters(unit,types,ints,style,n)
 if unit == 'GLOBAL' then
  keys = 'GLOBAL'
 else
  keys = tostring(unit.id)
 end
 ints = tonumber(ints)
 n = tonumber(n)
 v = 0
 skey = ''
 si = 0
 pers,status = dfhack.persistent.get(keys..'_counters_1')
 num = 1
 match = false
 if not pers then
  dfhack.persistent.save({key=keys..'_counters_1',value=types,ints={ints,0,0,0,0,0,1}})
  v = ints
  skey = keys..'_counters_1'
  si=1
 else
  if pers.ints[7] <= 6 then
   local valuea = split(pers.value,'_')
   for i,x in ipairs(valuea) do
    if x == types then 
     pers.ints[i] = pers.ints[i] + ints
     v = pers.ints[i]
     skey = keys..'_counters_1'
     si = i
     match = true
    end
   end
   if not match then
    if pers.ints[7] < 6 then
     pers.value = pers.value .. '_' .. types
     pers.ints[7] = pers.ints[7] + 1
     pers.ints[pers.ints[7]] = ints
     v = ints
     skey = keys..'_counters_1'
     si = pers.ints[7]
     dfhack.persistent.save({key=pers.key,value=pers.value,ints=pers.ints})
    elseif pers.ints[7] == 6 then
     pers.ints[7] = 7
     dfhack.persistent.save({key=keys .. '_counters_2', value=types,ints={ints,0,0,0,0,0,0}})
     v = ints
     skey = keys..'_counters_2'
     si = 1
    end
   end
  else
   num = math.floor(pers.ints[7]/7)+1
   local valuea = split(pers.value,'_')
   for i,x in ipairs(valuea) do
    if x == types then
     pers.ints[i] = pers.ints[i] + ints
     v = pers.ints[i]
     skey = keys..'_counters_1'
     si = i
     match = true
    end
   end
   if not match then
    for j = 2, num, 1 do
     keysa = keys .. '_counters_' .. tostring(j)
     persa,status = dfhack.persistent.get(keysa)
     local valuea = split(persa.value,'_')
     for i,x in ipairs(valuea) do
      if x == types then
       persa.ints[i] = persa.ints[i] + ints
       v = persa.ints[i]
       skey = keysa
       si = i
       dfhack.persistent.save({key=persa.key,value=persa.value,ints=persa.ints})
       match = true
      end
     end
    end
   end
   if not match then
    pers.ints[7] = pers.ints[7] + 1
    if math.floor(pers.ints[7]/7) == pers.ints[7]/7 then
     keysa = keys..'_counters_'..tostring(num+1)
     dfhack.persistent.save({key=keysa, value=types,ints={ints,0,0,0,0,0,0}})
     v = ints
     skey = keysa
     si = 1
    else
     persa.value = persa.value..'_'..types
     persa.ints[pers.ints[7]-(num-1)*7+1] = persa.ints[pers.ints[7]-(num-1)*7+1] + ints
     v = persa.ints[pers.ints[7]-(num-1)*7+1]
     skey = keysa
     si = pers.ints[7]-(num-1)*7+1
     dfhack.persistent.save({key=persa.key,value=persa.value,ints=persa.ints})
    end
   end
  end
  dfhack.persistent.save({key=pers.key,value=pers.value,ints=pers.ints})
 end


 if style == 'minimum' then
  if tonumber(v) >= n and n >= 0 then
   pers,status=dfhack.persistent.get(skey)
   pers.ints[si] = 0
   dfhack.persistent.save({key=skey,value=pers.value,ints=pers.ints})
   return true
  end
 elseif style == 'percent' then
  rando = dfhack.random.new()
  roll = rando:drandom()
  if roll <= v/n and n >= 0 then
   pers,status=dfhack.persistent.get(skey)
   pers.ints[si] = 0
   dfhack.persistent.save({key=skey,value=pers.value,ints=pers.ints})
   return true
  end
 end

 return false
end

validArgs = validArgs or utils.invert({
 'help',
 'unit',
 'style',
 'counter',
 'increment',
 'cap',
 'script',
})
style = style or utils.invert({
 'minimum',
 'percent',
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
 print([[special-counters.lua
  Allows for creation, examination, and ultimately triggering based on counters
  arguments:
   -help
     print this help message
   -unit id
     id of the target unit to associate the counter with
     DEFAULT 'GLOBAL'
   -style minimum or percent
     minimum - once the value of the counter has surpassed a certain amount, the counter will trigger the script. the counter is then reset to zero
     percent - the script has a chance of triggering each time the counter is increased, with a 100% chance once it reaches a certain amount. the counter is reset to zero on triggering
     DEFAULT minimum
   -counter ANY_STRING
     REQUIRED
     any string value, the counter will be saved as this type
     examples:
      FIRE
      BURN
      POISON
   -increment #
     amount for the counter to change
     DEFAULT 0
   -cap #
     level of triggering for the counter
     once it hits the cap (or is triggered earlier by percentage) the counter will reset to 0
     DEFAULT 1000000
   -script [script and arguments]
     REQUIRED
     the script to trigger when the counter is reached
     example:
      [item-upgrade -unit \\UNIT_ID -weapon ALL -equipped -upgrade -dur 1000]  
  example:
   special-counters -unit \\UNIT_ID -style minimum -counter BERSERK -increment 1 -cap 10 -script [unit-attributes-change -unit \\UNIT_ID -physical [STRENGTH,AGILITY] -fixed [1000,\-200] ]
 ]])
 return
end

if args.counter == nil then -- Check for counter declaration !REQUIRED
 print('No counter selected')
 return
end
unit = df.unit.find(tonumber(args.unit)) or 'GLOBAL' -- Check for unit declaration
args.style = style[args.style or 'minimum'] -- Set style
if args.increment == nil then args.increment = 0 end -- Specify increment (default 0)
if args.cap == nil then args.cap = 1000000 end -- Specify cap (default 1000000)

trigger = counters(unit,args.counter,args.increment,args.style,args.cap)
if trigger then
 dfhack.run_script(args.script[1],select(2,table.unpack(args.script)))
end
