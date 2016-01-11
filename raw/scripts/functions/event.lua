function checkRequirements(event,effect,verbose)
 local persistTable = require 'persist-table'
 event = persistTable.GlobalTable.roses.EventTable[event]
 if not event then
  return false
 end
 yes = true
 if effect == 0 or effect = nil then
  check = event.Required
 else
  check = event.Effect[tostring(effect)].Required
 end

-- Check for chance occurance
 local chance = check.Chance
 local rand = dfhack.random.new()
 local rnum = rand:random(100)+1
 if rnum > chance then
  return false
 end

-- Check for amount of time passed
 if check.Time then
  local x = check.Time
  local time_played = df.global.ui.fortress_age
  if time_played < tonumber(x) then
   return false
  end
 end

-- Check for fortress wealth
 if check.Wealth then
  for _,wtype in pairs(check.Wealth._children) do
   local amount = check.Wealth[wtype]
   if df.global.ui.tasks.wealth[string.lower(wtype)] then
    if df.global.ui.tasks.wealth[string.lower(wtype)] < tonumber(amount) then
     return false
    end
   end
  end
 end

-- Check for fortress population
 if check.Population then
  local x = check.Population
  local population = df.global.ui.tasks.population
  if population < tonumber(x) then
   return false
  end
 end


end

function triggerEvent(event,effect,verbose)
 local persistTable = require 'persist-table'
 eventTable = persistTable.GlobalTable.roses.EventTable[event]


end

function checkEvent(id,method,verbose)
 local persistTable = require 'persist-table'
 local eventTable = persistTable.GlobalTable.roses.EventTable[id]
 local triggered = {}

 if checkRequirements(id,0,verbose) then
  triggered[0] = true
  for _,i in pairs(eventTable.Effect._children) do
   if checkRequirements(event,tonumber(i),verbose) then
    contingency = tonumber(eventTable.Effect[i].Contingent) or 0
    if triggered[contingency] then
     triggered[tonumber(i)] = true
     triggerEvent(event,tonumber(i),verbose)
     if verbose then print('Event effect triggered '..id) end
    end
   end
  end
 end

 queueCheck(id,method,verbose)
end

function queueCheck(id,method,verbose)

 if method == 'YEARLY' then
  curtick = df.global.cur_year_tick
  ticks = 1200*28*3*4-curtick
  if ticks <= 0 then ticks = 1200*28*3*4 end
  checkEvent(id,'YEARLY',verbose)
 elseif method == 'SEASON' then
  curtick = df.global.cur_season_tick*10
  ticks = 1200*28*3-curtick
  if ticks <= 0 then ticks = 1200*28*3 end
  checkEvent(id,'SEASON',verbose)
 elseif method == 'MONTHLY' then
  curtick = df.global.cur_year_tick
  moy = curtick/(1200*28)
  ticks = math.ceil(moy)*1200*28 - curtick
  checkEvent(id,'MONTHLY',verbose)
 elseif method == 'WEEKLY' then
  curtick = df.global.cur_year_tick
  woy = curtick/(1200*7)
  ticks = math.ceil(woy)*1200*7 - curtick
  dcheckEvent(id,'WEEKLY',verbose)
 elseif method == 'DAILY' then
  curtick = df.global.cur_year_tick
  doy = curtick/1200
  ticks = math.ceil(doy)*1200 - curtick
  checkEvent(id,'DAILY',verbose)
 else
  curtick = df.global.cur_season_tick*10
  ticks = 1200*28*3-curtick
  if ticks <= 0 then ticks = 1200*28*3 end
  checkEnvent(id,'SEASON',verbose)
 end
end