--base/civilizations.lua v1.0

local persistTable = require 'persist-table'

roses = persistTable.GlobalTable.roses
if not roses then
 return
end

yearly = {}
season = {}
monthly = {}
weekly = {}
daily = {}

-- CivilizationTable Checks
if roses.CivilizationTable and roses.EntityTable then
 for _,id in pairs(roses.EntityTable._children) do
  entityTable = roses.EntityTable[id]
  if entityTable.Civilization then
   method = entityTable.Civilization.CurrentMethod
   if method == 'YEARLY' then
    yearly[id] = 'CIVILZATION'
   elseif method == 'SEASON' then
    season[id] = 'CIVILZATION'
   elseif method == 'MONTHLY' then
    monthly[id] = 'CIVILZATION'
   elseif method == 'WEEKLY' then
    weekly[id] = 'CIVILZATION'
   elseif method == 'DAILY' then
    daily[id] = 'CIVILZATION'
   else
    season[id] = id
   end
  end
 end
end

-- EventTable Checks
if roses.EventTable then
 for _,id in pairs(roses.EventTable._children) do
  event = roses.EventTable[id]
  method = event.Check
  if method == 'YEARLY' then
   yearly[id] = 'EVENT'
  elseif method == 'SEASON' then
   season[id] = 'EVENT'
  elseif method == 'MONTHLY' then
   monthly[id] = 'EVENT'
  elseif method == 'WEEKLY' then
   weekly[id] = 'EVENT'
  elseif method == 'DAILY' then
   daily[id] = 'EVENT'
  else
   season[id] = id
  end
 end
end

for id,Type in pairs(yearly) do
 curtick = df.global.cur_year_tick
 ticks = 1200*28*3*4-curtick
 if ticks <= 0 then ticks = 1200*28*3*4 end
 if Type == 'CIVILIZATION' then
  dfhack.timeout(ticks+1,'ticks',dfhack.script_environment('functions/civilization').checkEntity(id,'YEARLY',true))
 elseif TYPE == 'EVENT' then
  dfhack.timeout(ticks+1,'ticks',dfhack.script_environment('functions/event').checkEvent(id,'YEARLY',true))
 end
end

for id,Type in pairs(season) do
 curtick = df.global.cur_season_tick*10
 ticks = 1200*28*3-curtick
 if ticks <= 0 then ticks = 1200*28*3 end
 if Type == 'CIVILIZATION' then
  dfhack.timeout(ticks+1,'ticks',dfhack.script_environment('functions/civilization').checkEntity(id,'SEASON',true))
 elseif TYPE == 'EVENT' then
  dfhack.timeout(ticks+1,'ticks',dfhack.script_environment('functions/event').checkEvent(id,'SEASON',true))
 end
end

for id,Type in pairs(monthly) do
 curtick = df.global.cur_year_tick
 moy = curtick/(1200*28)
 ticks = math.ceil(moy)*1200*28 - curtick
 if Type == 'CIVILIZATION' then
  dfhack.timeout(ticks+1,'ticks',dfhack.script_environment('functions/civilization').checkEntity(id,'MONTHLY',true))
 elseif TYPE == 'EVENT' then
  dfhack.timeout(ticks+1,'ticks',dfhack.script_environment('functions/event').checkEvent(id,'MONTHLY',true))
 end
end

for id,Type in pairs(weekly) do
 curtick = df.global.cur_year_tick
 woy = curtick/(1200*7)
 ticks = math.ceil(woy)*1200*7 - curtick
 if Type == 'CIVILIZATION' then
  dfhack.timeout(ticks+1,'ticks',dfhack.script_environment('functions/civilization').checkEntity(id,'WEEKLY',true))
 elseif TYPE == 'EVENT' then
  dfhack.timeout(ticks+1,'ticks',dfhack.script_environment('functions/event').checkEvent(id,'WEEKLY',true))
 end
end

for id,Type in pairs(daily) do
 curtick = df.global.cur_year_tick
 doy = curtick/1200
 ticks = math.ceil(doy)*1200 - curtick
 if Type == 'CIVILIZATION' then
  dfhack.timeout(ticks+1,'ticks',dfhack.script_environment('functions/civilization').checkEntity(id,'DAILY',true))
 elseif TYPE == 'EVENT' then
  dfhack.timeout(ticks+1,'ticks',dfhack.script_environment('functions/event').checkEvent(id,'DAILY',true))
 end
end