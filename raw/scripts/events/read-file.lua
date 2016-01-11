function tchelper(first, rest)
  return first:upper()..rest:lower()
end

function readFile(path)
 local utils = require 'utils'
 local split = utils.split_string
 local persistTable = require 'persist-table'
 persistTable.GlobalTable.roses.EventTable = persistTable.GlobalTable.roses.EventTable or {}
 local iofile = io.open(path,"r")
 local totdat = {}
 local count = 1
 while true do
  local line = iofile:read("*line")
  if line == nil then break end
  totdat[count] = line
  count = count + 1
 end
 iofile:close()
 
 d = {}
 events = persistTable.GlobalTable.roses.EventTable
 count = 1
 for i,x in ipairs(totdat) do
  if split(x,':')[1] == '[EVENT' then
   d[count] = {split(split(x,':')[2],']')[1],i,0}
   count = count + 1
  end
 end
 for i,x in ipairs(d) do
  eventToken = x[1]
  startLine = x[2]+1
  if i == #d then
   endLine = #totdat
  else
   endLine = d[i+1][2]-1
  end
  events[eventToken]={}
  events[eventToken]['Effect'] = {}
  events[eventToken]['Required'] = {}
  events[eventToken]['Delay'] = {}
  numberOfEffects = 0
  for j = startLine,endLine,1 do
   splits = split(totdat[j],':')
   for k = 1, #splits, 1 do
    splits[k] = split(splits[k],']')[1]
   end
   test = splits[1]:gsub("%s+","")
   if test == '[NAME' then   
    events[eventToken]['Name'] = splits[2]
   elseif test == '[CHECK' then 
    events[eventToken]['Check'] = splits[2]
   elseif test == '[CHANCE' then
	events[eventToken]['Chance'] = splits[2]
   elseif test == '[DELAY' then
	events[eventToken]['Delay'][splits[2]] = splits[3]
   elseif test == '[REQUIREMENT' then
    if splits[2] == 'COUNTER' then
	 events[eventToken]['Required']['Counter'] = events[eventToken]['Required']['Counter'] or {}
	 events[eventToken]['Required']['Counter'][splits[3]] = splits[4]
	elseif splits[2] == 'TIME' then
	 events[eventToken]['Required']['Time'] = {}
	 events[eventToken]['Required']['Time']['1'] = splits[3]
	elseif splits[2] == 'POPULATION' then
	 events[eventToken]['Required']['Population'] = {}
	 events[eventToken]['Required']['Population']['1'] = splits[3]
	elseif splits[2] == 'WEALTH' then
	 events[eventToken]['Required']['Wealth'] = events[eventToken]['Required']['Wealth'] or {}
	 events[eventToken]['Required']['Wealth'][splits[3]] = splits[4]
	elseif splits[2] == 'BUILDING' then
	 events[eventToken]['Required']['Building'] = events[eventToken]['Required']['Building'] or {}
	 events[eventToken]['Required']['Building'][splits[3]] = splits[4]
	elseif splits[2] == 'SKILL' then
	 events[eventToken]['Required']['Skill'] = events[eventToken]['Required']['Skill'] or {}
	 events[eventToken]['Required']['Skill'][splits[3]] = splits[4]
	elseif splits[2] == 'CLASS' then
	 events[eventToken]['Required']['Class'] = events[eventToken]['Required']['Class'] or {}
	 events[eventToken]['Required']['Class'][splits[3]] = splits[4]
	elseif splits[2] == 'KILLS' then
	 events[eventToken]['Required']['Kills'] = events[eventToken]['Required']['Kills'] or {}
	 events[eventToken]['Required']['Kills'][splits[3]] = splits[4]
	elseif splits[2] == 'DEATHS' then
	 events[eventToken]['Required']['Deaths'] = events[eventToken]['Required']['Deaths'] or {}
	 events[eventToken]['Required']['Deaths'][splits[3]] = splits[4]
	elseif splits[2] == 'TRADES' then
	 events[eventToken]['Required']['Trades'] = events[eventToken]['Required']['Trades'] or {}
	 events[eventToken]['Required']['Trades'][splits[3]] = splits[4]
	elseif splits[2] == 'SIEGES' then
	 events[eventToken]['Required']['Sieges'] = events[eventToken]['Required']['Sieges'] or {}
	 events[eventToken]['Required']['Sieges'][splits[3]] = splits[4]
	end
   elseif test == '[EFFECT' then 
	number = splits[2]
	numberOfEffects = numberOfEffects + 1
    events[eventToken]['Effect'][number] = {}
	effect = events[eventToken]['Effect'][number]
	effect['Arguments'] = '0'
	effect['Argument'] = {}
	effect['Required'] = {}
	effect['Script'] = {}
	effect['Delay'] = {}
	effect['Scripts'] = '0'
   elseif test == '[EFFECT_NAME' then
    effect['Name'] = splits[2]
   elseif test == '[EFFECT_CHANCE' then
    effect['Chance'] = splits[2]
   elseif test == '[EFFECT_CONTINGENT_ON' then
    effect['Contingent'] = splits[2]
   elseif test == '[EFFECT_DELAY' then
    effect['Delay'][splits[2]] = splits[3]
   elseif test == '[EFFECT_REQUIREMENT' then 
    if splits[2] == 'COUNTER' then
	 effect['Required']['Counter'] = effect['Required']['Counter'] or {}
	 effect['Required']['Counter'][splits[3]] = splits[4]
	elseif splits[2] == 'TIME' then
	 effect['Required']['Time'] = {}
	 effect['Required']['Time']['1'] = splits[3]
	elseif splits[2] == 'POPULATION' then
	 effect['Required']['Population'] = {}
	 effect['Required']['Population']['1'] = splits[3]
	elseif splits[2] == 'WEALTH' then
	 effect['Required']['Wealth'] = effect['Required']['Wealth'] or {}
	 effect['Required']['Wealth'][splits[3]] = splits[4]
	elseif splits[2] == 'BUILDING' then
	 effect['Required']['Building'] = effect['Required']['Building'] or {}
	 effect['Required']['Building'][splits[3]] = splits[4]
	elseif splits[2] == 'SKILL' then
	 effect['Required']['Skill'] = effect['Required']['Skill'] or {}
	 effect['Required']['Skill'][splits[3]] = splits[4]
	elseif splits[2] == 'CLASS' then
	 effect['Required']['Class'] = effect['Required']['Class'] or {}
	 effect['Required']['Class'][splits[3]] = splits[4]
	elseif splits[2] == 'KILLS' then
	 effect['Required']['Kills'] = effect['Required']['Kills'] or {}
	 effect['Required']['Kills'][splits[3]] = splits[4]
	elseif splits[2] == 'DEATHS' then
	 effect['Required']['Deaths'] = effect['Required']['Deaths'] or {}
	 effect['Required']['Deaths'][splits[3]] = splits[4]
	elseif splits[2] == 'TRADES' then
	 effect['Required']['Trades'] = effect['Required']['Trades'] or {}
	 effect['Required']['Trades'][splits[3]] = splits[4]
	elseif splits[2] == 'SIEGES' then
	 effect['Required']['Sieges'] = effect['Required']['Sieges'] or {}
	 effect['Required']['Sieges'][splits[3]] = splits[4]
	end    
   elseif test == '[EFFECT_UNIT' then
    effect['Unit'] = {}
    local temptable = {select(2,table.unpack(splits))}
	strint = '1'
	for _,v in pairs(temptable) do
	 effect['Unit'][strint] = v
	 strint = tostring(strint+1)
	end
   elseif test == '[EFFECT_LOCATION' then
	effect['Location'] = {}
    local temptable = {select(2,table.unpack(splits))}
	strint = '1'
	for _,v in pairs(temptable) do
	 effect['Location'][strint] = v
	 strint = tostring(strint+1)
	end
   elseif test == '[EFFECT_BUILDING' then
	effect['Building'] = {}
    local temptable = {select(2,table.unpack(splits))}
	strint = '1'
	for _,v in pairs(temptable) do
	 effect['Building'][strint] = v
	 strint = tostring(strint+1)
	end
   elseif test == '[EFFECT_ITEM' then
	effect['Item'] = {}
    local temptable = {select(2,table.unpack(splits))}
	strint = '1'
	for _,v in pairs(temptable) do
	 effect['Item'][strint] = v
	 strint = tostring(strint+1)
	end
   elseif test == '[EFFECT_ARGUMENT' then 
	argnumber = splits[2]
	effect['Arguments'] = tostring(effect['Arguments'] + 1)
    effect['Argument'][argnumber] = {}
	argument = effect['Argument'][argnumber]
   elseif test == '[ARGUMENT_WEIGHTING' then
    argument['Weighting'] = splits[2]
   elseif test == '[ARGUMENT_EQUATION' then
    argument['Equation'] = splits[2]
   elseif test == '[ARGUMENT_VARIABLE' then
    argument['Variable'] = splits[2]
   elseif test == '[EFFECT_SCRIPT' then
	effect['Scripts'] = tostring(effect['Scripts'] + 1)
    effect['Script'][effect['Scripts']] = splits[2]
   end
  end
  events[eventToken]['Effects'] = tostring(numberOfEffects)
 end
 return events
end