function checkRequirements(event,effect)
 local persistTable = require 'persist-table'
 yes = true
 if effect == 0 then
  check = event['Required']
 else
  check = event['Effect'][tostring(effect)]['Required']
 end
-- check counters
 if check['Counter'] and yes then
  for _,i in pairs(check['Counter']._children) do
   local x = check['Counter'][i]
   if persistTable.GlobalTable.roses.GlobalTable.Counters[i] then
    if tonumber(persistTable.GlobalTable.roses.GlobalTable.Counters[i]) >= tonumber(x) then
	 yes = true
	else
	 yes = false
	 break
	end
   else
	yes = false
	break
   end
  end
 end
-- check time
 if check['Time'] and yes then
  local x = check['Time']['1']
  local time_played = df.global.ui.fortress_age
  if time_played >= tonumber(x) then
   yes = true
  else
   yes = false
  end
 end
-- check wealth
 if check['Wealth'] and yes then
  for _,i in pairs(check['Wealth']._children) do
   local x = check['Wealth'][i]
   if df.global.ui.tasks.wealth[string.lower(i)] then
    if df.global.ui.tasks.wealth[string.lower(i)] >= tonumber(x) then
	 yes = true
	else
	 yes = false
	 break
	end
   end
  end
 end
-- check population
 if check['Population'] and yes then
  local x = check['Population']['1']
  local population = df.global.ui.tasks.population
  if population >= tonumber(x) then
   yes = true
  else
   yes = false
  end
 end
-- check building
 if check['Building'] and yes then
  for _,i in pairs(check['Building']._children) do
   local x = check['Building'][i]
   local n = 0
   for _,y in ipairs(df.global.world.buildings.all) do
    if df.building_furnacest:is_instance(y) or df.building_workshopst:is_instance(y) then
     local ctype = x.custom_type
     if ctype >= 0 then
      if df.global.world.raws.buildings.all[ctype].code == i then 
       n = n+1
      end
     end
    end
   end   
   if n >= tonumber(x) then
	yes = true
   else
	yes = false
	break
   end
  end
 end
-- check class
 if check['Class'] and yes then
  local unitTable = persistTable.GlobalTable.roses.UnitTable
  for _,i in pairs(check['Class']._children) do
   local x = check['Class'][i]
   local n = 0
   for _,y in ipairs(df.global.world.units.active) do
    if dfhack.units.isCitizen(y) then
	 if unitTable[tostring(y.id)] then
	  if unitTable[tostring(y.id)]['Classes']['Current']['Name'] == i then
	   n = n + 1
	  end
	 end
	end
   end
   if n >= tonumber(x) then
	yes = true
   else
	yes = false
	break
   end
  end
 end
-- check skill
 if check['Skill'] and yes then
  for _,i in pairs(check['Skill']._children) do
   local x = check['Skill'][i]
   local n = 0
   for _,y in ipairs(df.global.world.units.active) do
    if dfhack.units.isCitizen(y) then
	 local currentSkill = dfhack.units.getEffectiveSkill(y,i)
	 if currentSkill >= tonumber(x) then
	  n = 1
	  break
	 end
	end
   end
   if n == 1 then
	yes = true
   else
	yes = false
	break
   end
  end
 end
-- check kills
 if check['Kills'] and yes then
  local kills = persistTable.GlobalTable.roses.GlobalTable.Kills
  for _,i in pairs(check['Kills']._children) do
   local x = check['Kills'][i]
   if kills[i] then
    if kills[i] >= tonumber(x) then
	 yes = true
	else
	 yes = false
	 break
	end
   end
  end
 end
-- check deaths
 if check['Deaths'] and yes then
  local deaths = persistTable.GlobalTable.roses.GlobalTable.Deaths
  for _,i in pairs(check['Deaths']._children) do
   local x = check['Deaths'][i]
   if deaths[i]['All'] then
    if deaths[i]['All'] >= tonumber(x) then
	 yes = true
	else
	 yes = false
	 break
	end
   end
  end
 end
-- check trades
 if check['Trades'] and yes then
  local trades = persistTable.GlobalTable.roses.GlobalTable.Trades
  for _,i in pairs(check['Trades']._children) do
   local x = check['Trades'][i]
   if trades[i] then
    if trades[i] >= tonumber(x) then
	 yes = true
	else
	 yes = false
	 break
	end
   end
  end
 end
-- check sieges
 if check['Sieges'] and yes then
  local sieges = persistTable.GlobalTable.roses.GlobalTable.Sieges
  for _,i in pairs(check['Sieges']._children) do
   local x = check['Sieges'][i]
   if sieges[i] then
    if sieges[i] >= tonumber(x) then
	 yes = true
	else
	 yes = false
	 break
	end
   end
  end
 end
 return yes
end