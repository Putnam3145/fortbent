local M
split = require('split')
local function checkCounters(unit,array) -- CHECK 1
 tempa = split(array,':')
 keys = tostring(unit.id)
 types = tempa[1]
 ints = tempa[2]
 style = tempa[3]
 n = tonumber(tempa[4])
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
  print(v,n,skey,si)
  if tonumber(v) >= n and n >= 0 then
   pers,status=dfhack.persistent.get(skey)
   pers.ints[si] = 0
   dfhack.persistent.save({key=skey,value=pers.value,ints=pers.ints})
   return true,'Counter minimum reached'
  end
 elseif style == 'percent' then
  rando = dfhack.random.new()
  roll = rando:drandom()
  if roll <= v/n and n >= 0 then
   pers,status=dfhack.persistent.get(skey)
   pers.ints[si] = 0
   dfhack.persistent.save({key=skey,value=pers.value,ints=pers.ints})
   return true,'Counter percent triggered'
  end
 end

 print(pers)
 return false, 'Not enough counters on unit'
end
M = checkCounters

return M