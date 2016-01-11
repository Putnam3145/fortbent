function changeLevel(entity,amount,verbose)
 if tonumber(entity) then
  civid = tonumber(entity)
  civ = df.global.world.entities.all[civid]
 else
  civ = entity
  civid = entity.id
 end
 key = tostring(civid)

 local persistTable = require 'persist-table'
 entityTable = persistTable.GlobalTable.roses.EntityTable
 if not entityTable[key] then
  dfhack.script_environment('functions/tables').makeEntityTable(key)
 end
 entityTable = persistTable.GlobalTable.roses.EntityTable[key]
 entity = df.global.world.entities.all[civid].entity_raw.code
 civilizationTable = persistTable.GlobalTable.roses.CivilizationTable[entity]
 if civilizationTable then
  if civilizationTable.Level then
   currentLevel = tonumber(entityTable.Civilization.Level)
   nextLevel = currentLevel + amount
   if nextLevel > tonumber(civilizationTable.Levels) then nextLevel = tonumber(civilizationTable.Levels) end
   if nextLevel < 0 then nextLevel = 0 end
   if amount > 0 then
    for i = currentLevel+1,nextLevel,1 do
     if civilizationTable.Level[tostring(i)] then
      for _,mtype in pairs(civilizationTable.Level[tostring(i)].Remove._children) do
       depth1 = civilizationTable.Level[tostring(i)].Remove[mtype]
       for _,stype in pairs(depth1._children) do
        depth2 = depth1[stype]
        for _,mobj in pairs(depth2._children) do
         sobj = depth2[mobj]
         dfhack.script_environment('functions/entity').changeResources(key,mtype,stype,mobj,sobj,-1,verbose)
        end
       end
      end
      for _,mtype in pairs(civilizationTable.Level[tostring(i)].Add._children) do
       depth1 = civilizationTable.Level[tostring(i)].Add[mtype]
       for _,stype in pairs(depth1._children) do
        depth2 = depth1[stype]
        for _,mobj in pairs(depth2._children) do
         sobj = depth2[mobj]
         dfhack.script_environment('functions/entity').changeResources(key,mtype,stype,mobj,sobj,1,verbose)
        end
       end
      end
      for _,position in pairs(civilizationTable.Level[tostring(i)].RemovePosition._children) do
       dfhack.script_environment('functions/entity').changeNoble(key,position,-1,verbose)
      end
      for _,position in pairs(civilizationTable.Level[tostring(i)].AddPosition._children) do
       dfhack.script_environment('functions/entity').changeNoble(key,position,1,verbose)
      end
      if civilizationTable.Level[tostring(i)].LevelMethod then
       entityTable.Civilization.CurrentMethod = civilizationTable.Level[tostring(i)].LevelMethod
       entityTable.Civilization.CurrentPercent = civilizationTable.Level[tostring(i)].Levelchance
      end
     end
    end
   elseif amount <0 then
    for i = currentLevel,nextLevel,-1 do
     if civilizationTable.Level[tostring(i)] then
      for _,mtype in pairs(civilizationTable.Level[tostring(i)].Remove._children) do
       depth1 = civilizationTable.Level[tostring(i)].Remove[mtype]
       for _,stype in pairs(depth1._children) do
        depth2 = depth1[stype]
        for _,mobj in pairs(depth2._children) do
         sobj = depth2[mobj]
         dfhack.script_environment('functions/entity').changeResources(key,mtype,stype,mobj,sobj,1,verbose)
        end
       end
      end
      for _,mtype in pairs(civilizationTable.Level[tostring(i)].Add._children) do
       depth1 = civilizationTable.Level[tostring(i)].Add[mtype]
       for _,stype in pairs(depth1._children) do
        depth2 = depth1[stype]
        for _,mobj in pairs(depth2._children) do
         sobj = depth2[mobj]
         dfhack.script_environment('functions/entity').changeResources(key,mtype,stype,mobj,sobj,-1,verbose)
        end
       end
      end
      for _,position in pairs(civilizationTable.Level[tostring(i)].RemovePosition._children) do
       dfhack.script_environment('functions/entity').changeNoble(key,position,1,verbose)
      end
      for _,position in pairs(civilizationTable.Level[tostring(i)].AddPosition._children) do
       dfhack.script_environment('functions/entity').changeNoble(key,position,-1,verbose)
      end
      if civilizationTable.Level[tostring(i)].LevelMethod then
       entityTable.Civilization.CurrentMethod = civilizationTable.Level[tostring(i)].LevelMethod
       entityTable.Civilization.CurrentPercent = civilizationTable.Level[tostring(i)].Levelchance
      end
     end
    end
   end
  end
 end
end

function checkEntity(id,method,verbose)
 local persistTable = require 'persist-table'
 civilizationTable = persistTable.GlobalTable.roses.EntityTable[id].Civilization

 leveled = false

 -- check for non-time based checks
 if method ~= civilizationTable.CurrentMethod then
  entityTable = persistTable.GlobalTable.roses.EntityTable[id]
  method = civilizationTable.CurrentMethod
  chance = tonumber(civilizationTable.CurrentPercent)
  if method == 'KILLs' then
   number = tonumber(entityTable.Kills.Total)
  elseif method == 'DEATHS' then
   number = tonumber(entityTable.Deaths.Total)
  elseif method == 'SIEGES' then
   number = tonumber(entityTable.Sieges.Total)
  elseif method == 'TRADES' then
   number = tonumber(entityTable.Trades.Total)
  end
  if number >= chance then leveled = true end
 else
  chance = civilizationTable.CurrentPercent
  local rand = dfhack.random.new()
  rnum = rand:random(100)+1
  if rnum <= chance then leveled = true end
 end

 if leveled then
  changeLevel(id,1,verbose)
  if verbose then print('Civilization leveled up') end
  method = civilizationTable.CurrentMethod
 end

 queueCheck(id,method,verbose)
end

function queueCheck(id,method,verbose)

 if method == 'YEARLY' then
  curtick = df.global.cur_year_tick
  ticks = 1200*28*3*4-curtick
  if ticks <= 0 then ticks = 1200*28*3*4 end
  checkEntity(id,'YEARLY',verbose)
 elseif method == 'SEASON' then
  curtick = df.global.cur_season_tick*10
  ticks = 1200*28*3-curtick
  if ticks <= 0 then ticks = 1200*28*3 end
  checkEntity(id,'SEASON',verbose)
 elseif method == 'MONTHLY' then
  curtick = df.global.cur_year_tick
  moy = curtick/(1200*28)
  ticks = math.ceil(moy)*1200*28 - curtick
  checkEntity(id,'MONTHLY',verbose)
 elseif method == 'WEEKLY' then
  curtick = df.global.cur_year_tick
  woy = curtick/(1200*7)
  ticks = math.ceil(woy)*1200*7 - curtick
  dcheckEntity(id,'WEEKLY',verbose)
 elseif method == 'DAILY' then
  curtick = df.global.cur_year_tick
  doy = curtick/1200
  ticks = math.ceil(doy)*1200 - curtick
  checkEntity(id,'DAILY',verbose)
 else
  curtick = df.global.cur_season_tick*10
  ticks = 1200*28*3-curtick
  if ticks <= 0 then ticks = 1200*28*3 end
  checkEntity(id,'SEASON',verbose)
 end

end