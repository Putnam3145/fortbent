
function permute(tab)
 -- Randomly permutes a given table. Returns permuted table
 n = #tab
 for i = 1, n do
  local j = math.random(i, n)
  tab[i], tab[j] = tab[j], tab[i]
 end
 return tab
end

function changeCounter(counter,amount,extra)
 local persistTable = require 'persist-table'
 local roses = persistTable.GlobalTable.roses
 if not roses then return end

 local utils = require 'utils'
 local split = utils.split_string

 counterTable = roses.CounterTable
 counters = split(counter,':')

 for i,x in pairs(counters) do
  if not counterTable[x] then
   if i ~= 1 then
    if tonumber(counterTable) then
     print('Higher level counter already set')
     print('Counter = '..counters[i-1],'Sub-counter = '..counters[i])
     print('Can not set a value to a sub-counter with an already set counter')
     return
    end
   end
   if i ~= #counters then
    counterTable[x] = {}
   else
    counterTable[x] = '0'
    break
   end
  else
   if tonumber(counterTable[x]) and i == #counters then
    break
   elseif i == #counters then
    print('Sub-counter already set')
    print('Counter = '..counters[i],'Sub-counter = '..counterTable[x]._children[1])
    print('Can not set a value of a counter with already set sub-counters')
    return
   end
  end
  counterTable = counterTable[x]
  if (x == 'UNIT' or x == 'BUILDING' or x == 'ITEM') and i == 1 then
   if not counterTable[tostring(extra)] then
    counterTable[tostring(extra)] = {}
   end
   counterTable = counterTable[tostring(extra)]
  end
 end

 if not tonumber(counterTable[counters[#counters]]) then
  counterTable[counters[#counters]] = '0'
 end

 counterTable[counters[#counters]] = tostring(counterTable[counters[#counters]] + amount)

 return counterTable[counters[#counters]]
end

function getCounter(counter,extra)
 local persistTable = require 'persist-table'
 local roses = persistTable.GlobalTable.roses
 if not roses then return end

 local utils = require 'utils'
 local split = utils.split_string

 counterTable = roses.CounterTable
 counters = split(counter,':')

 for i,x in pairs(counters) do
  if not counterTable[x] then
   if i ~= 1 then
    if tonumber(counterTable) then
     print('Higher level counter already set')
     print('Counter = '..counters[i-1],'Sub-counter = '..counters[i])
     print('Can not get a value to a sub-counter with an already set counter')
     return
    end
   end
   if i ~= #counters then
    counterTable[x] = {}
   else
    counterTable[x] = '0'
    break
   end
  else
   if tonumber(counterTable[x]) and i == #counters then
    break
   elseif i == #counters then
    print('Sub-counter already set')
    print('Counter = '..counters[i],'Sub-counter = '..counterTable[x]._children[1])
    print('Can not get a value of a counter with already set sub-counters')
    return
   end
  end
  counterTable = counterTable[x]
  if (x == 'UNIT' or x == 'BUILDING' or x == 'ITEM') and i == 1 then
   if not counterTable[tostring(extra)] then
    counterTable[tostring(extra)] = {}
   end
   counterTable = counterTable[tostring(extra)]
  end
 end

 if not tonumber(counterTable[counters[#counters]]) then
  counterTable[counters[#counters]] = '0'
 end

 return counterTable[counters[#counters]]
end
