function trackAttribute(unitID,attribute,current,change,value,dur,alter)
 local persistTable = require 'persist-table'
 if not persistTable.GlobalTable.roses then
  return "base/roses-init not loaded"
 end
 
 if not tonumber(unitID) then
  unitID = unitID.id
 end

 local unitTable = persistTable.GlobalTable.roses.UnitTable
 if not unitTable[tostring(unitID)] then
  dfhack.script_environment('functions/tables').makeUnitTable(unitID)
 end
 
 local attributeTable = unitTable[tostring(unitID)].Attributes[attribute]
 if alter == 'track' then
  if dur > 0 then
   attributeTable.Change = tostring(attributeTable.Change + change)
   local statusTable = attributeTable.StatusEffects
   local number = #statusTable._children
   statusTable[tostring(number+1)] = {}
   statusTable[tostring(number+1)].End = 1200*28*3*4*df.global.cur_year + df.global.cur_year_tick + dur
   statusTable[tostring(number+1)].Change = tostring(change)
  else
   attributeTable.Base = tostring(value)
  end
 elseif alter == 'end' then
  attributeTable.Change = tostring(attributeTable.Change - change)
  local statusTable = attributeTable.StatusEffects
  for i = #statusTable._children,1,-1 do
   if statusTable[i] then
    if statusTable[i].End <= 1200*28*3*4*df.global.cur_year + df.global.cur_year_tick then
     statusTable[i] = nil
    end
   end
  end
 elseif alter == 'class' then
  attributeTable.Class = tostring(change + attributeTable.Class)
 elseif alter == 'item' then
  attributeTable.Item = tostring(change + attributeTable.Item)
 elseif alter == 'get' then
  local unit = df.unit.find(unitID)
  local base = tonumber(attributeTable.Base)
  local change = tonumber(attributeTable.Change)
  local class = tonumber(attributeTable.Class)
  local item = tonumber(attributeTable.Item)
  local total = 0
  local syndrome = 0
  if df.physical_attribute_type[attribute] then
   if unit.curse.attr_change then
    total = (unit.body.physical_attrs[attribute].value+unit.curse.attr_change.phys_att_add[attribute])*unit.curse.attr_change.phys_att_perc[attribute]/100
    syndrome = total - unit.body.physical_attrs[attribute].value
   else
    total = unit.body.physical_attrs[attribute].value
   end
  elseif df.mental_attribute_type[attribute] then
   if unit.curse.attr_change then
    total = (unit.status.current_soul.mental_attrs[attribute].value+unit.curse.attr_change.ment_att_add[attribute])*unit.curse.attr_change.ment_att_perc[attribute]/100
    syndrome = total - unit.status.current_soul.mental_attrs[attribute].value
   else
    total = unit.status.current_soul.mental_attrs[attribute].value
   end
  end
  return total,base,change,class,item,syndrome
 end
end

function trackSkill(unitID,skill,current,change,value,dur,alter)
 local persistTable = require 'persist-table'
 if not persistTable.GlobalTable.roses then
  return
 end
 
 if not tonumber(unitID) then
  unitID = unitID.id
 end
 
 local unitTable = persistTable.GlobalTable.roses.UnitTable
 if not unitTable[tostring(unitID)] then
  dfhack.script_environment('functions/tables').makeUnitTable(unitID)
 end

 local skillTable = unitTable[tostring(unitID)].Skills[skill]
 if alter == 'track' then
  if dur > 0 then
   skillTable.Change = tostring(skillTable.Change + change)
   local statusTable = skillTable.StatusEffects
   local number = #statusTable._children
   statusTable[tostring(number+1)] = {}
   statusTable[tostring(number+1)].End = 1200*28*3*4*df.global.cur_year + df.global.cur_year_tick + dur
   statusTable[tostring(number+1)].Change = change
  else
   skillTable.Base = tostring(value)
  end
 elseif alter == 'end' then
  skillTable.Change = tostring(skillTable.Change - change)
  local statusTable = skillTable.StatusEffects
  for i = #statusTable._children,1,-1 do
   if statusTable[i] then
    if statusTable[i].End <= 1200*28*3*4*df.global.cur_year + df.global.cur_year_tick then
     statusTable[i] = nil
    end
   end
  end
 elseif alter == 'class' then
  skillTable.Class = tostring(change + skillTable.Class)
 elseif alter == 'item' then
  skillTable.Item = tostring(change + skillTable.Item)
 elseif alter == 'get' then
  local unit = df.unit.find(unitID)
  local base = tonumber(skillTable.Base)
  local change = tonumber(skillTable.Change)
  local class = tonumber(skillTable.Class)
  local item = tonumber(skillTable.Item)
  local total = dfhack.units.getNominalSkill(unit,df.job_skill[skill])
  local syndrome = 0
  return total,base,change,class,item,syndrome
 end
end

function trackResistance(unitID,resistance,current,change,value,dur,alter)
 local utils = require 'utils'
 local split = utils.split_string
 local persistTable = require 'persist-table'
 if not persistTable.GlobalTable.roses then
  return
 end
 
 if not tonumber(unitID) then
  unitID = unitID.id
 end
 
 local unitTable = persistTable.GlobalTable.roses.UnitTable
 if not unitTable[tostring(unitID)] then
  dfhack.script_environment('functions/tables').makeUnitTable(unitID)
 end
 unitTable = persistTable.GlobalTable.roses.UnitTable[tostring(unitID)]
 
 resistance = resistance:gsub('%.',':')
 array = split(resistance,':')
 resistanceTable = unitTable
 for i,entry in pairs(array) do
  array[i] = string.lower(entry):gsub("^%l",string.upper)
  if array[i] == 'Resistance' then array[i] = "Resistances" end
  if array[#array] ~= 'All' and tonumber(i) == #array then
   allTable = resistanceTable.All
  end
  if resistanceTable[array[i]] then resistanceTable = resistanceTable[array[i]] end
 end
 
 if alter == 'track' then
  if dur > 0 then
   resistanceTable.Change = tostring(resistanceTable.Change + change)
   local statusTable = resistanceTable.StatusEffects
   local number = #statusTable._children
   statusTable[tostring(number+1)] = {}
   statusTable[tostring(number+1)].End = 1200*28*3*4*df.global.cur_year + df.global.cur_year_tick + dur
   statusTable[tostring(number+1)].Change = change
  else
   resistanceTable.Base = tostring(value)
  end
 elseif alter == 'end' then
  resistanceTable.Change = tostring(resistanceTable.Change - change)
  local statusTable = resistanceTable.StatusEffects
  for i = #statusTable._children,1,-1 do
   if statusTable[i] then
    if statusTable[i].End <= 1200*28*3*4*df.global.cur_year + df.global.cur_year_tick then
     statusTable[i] = nil
    end
   end
  end
 elseif alter == 'class' then
  resistanceTable.Class = tostring(change + resistanceTable.Class)
 elseif alter == 'item' then
  resistanceTable.Item = tostring(change + resistanceTable.Item)
 elseif alter == 'get' then
  if allTable then
   base = tonumber(resistanceTable.Base)+allTable.Base
   change = tonumber(resistanceTable.Change)+allTable.Change
   class = tonumber(resistanceTable.Class)+allTable.Class
   item = tonumber(resistanceTable.Item)+allTable.Item
   total = base+change+class+item
   syndrome = 0
  else
   base = tonumber(resistanceTable.Base)
   change = tonumber(resistanceTable.Change)
   class = tonumber(resistanceTable.Class)
   item = tonumber(resistanceTable.Item)
   total = base+change+class+item
   syndrome = 0
  end
  return total,base,change,class,item,syndrome
 end 
end

function trackTrait(unitID,trait,current,change,value,dur,alter)
 local persistTable = require 'persist-table'
 if not persistTable.GlobalTable.roses then
  return
 end

 if not tonumber(unitID) then
  unitID = unitID.id
 end
 
 local unitTable = persistTable.GlobalTable.roses.UnitTable
 if not unitTable[tostring(unitID)] then
  dfhack.script_environment('functions/tables').makeUnitTable(unitID)
 end

 local traitTable = unitTable[tostring(unitID)].Traits[trait]
 if alter == 'track' then
  if dur > 0 then
   traitTable.Change = tostring(traitTable.Change + change)
   local statusTable = traitTable.StatusEffects
   local number = #statusTable._children
   statusTable[tostring(number+1)] = {}
   statusTable[tostring(number+1)].End = 1200*28*3*4*df.global.cur_year + df.global.cur_year_tick + dur
   statusTable[tostring(number+1)].Change = change
  else
   traitTable.Base = tostring(value)
  end
 elseif alter == 'end' then
  traitTable.Change = tostring(skillTable.Change - change)
  local statusTable = traitTable.StatusEffects
  for i = #statusTable._children,1,-1 do
   if statusTable[i] then
    if statusTable[i].End <= 1200*28*3*4*df.global.cur_year + df.global.cur_year_tick then
     statusTable[i] = nil
    end
   end
  end
 elseif alter == 'class' then
  traitTable.Class = tostring(change + traitTable.Class)
 elseif alter == 'item' then
  traitTable.Item = tostring(change + traitTable.Item)
 elseif alter == 'get' then
  local unit = df.unit.find(unitID)
  local base = tonumber(traitTable.Base)
  local change = tonumber(traitTable.Change)
  local class = tonumber(traitTable.Class)
  local item = tonumber(traitTable.Item)
  local total = unit.status.current_soul.personality.traits[trait]
  local syndrome = 0
  return total,base,change,class,item,syndrome
 end
end

function getCounter(unitID,counter)
 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end

 if (counter == 'webbed' or counter == 'stunned' or counter == 'winded' or counter == 'unconscious'
     or counter == 'pain' or counter == 'nausea' or counter == 'dizziness') then
  location = unit.counters
 elseif (counter == 'paralysis' or counter == 'numbness' or counter == 'fever' or counter == 'exhaustion'
         or counter == 'hunger' or counter == 'thirst' or counter == 'sleepiness' or oounter == 'hunger_timer'
         or counter == 'thirst_timer' or counter == 'sleepiness_timer') then
  if (counter == 'hunger' or counter == 'thirst' or counter == 'sleepiness') then counter = counter .. '_timer' end
  location = unit.counters2
 elseif counter == 'blood' or counter == 'infection' then
  location = unit.body
 else
  return 0
 end
 
 return location[counter] 
end

function changeAttribute(unit,attribute,change,dur,track)
 -- Add/Subtract given amount from declared attribute of a unit.

 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end

 local int16 = 30000000
 local current = 0
 local value = 0

 if df.physical_attribute_type[attribute] then
  current = unit.body.physical_attrs[attribute].value
  value = math.floor(current + change)
 if value > int16 then
  change = int16 - current
  value = int16
 end
 if value < 0 then
  change = current
  value = 0
 end
  unit.body.physical_attrs[attribute].value = value
  current = unit.body.physical_attrs[attribute].value
 elseif df.mental_attribute_type[attribute] then
  current = unit.status.current_soul.mental_attrs[attribute].value
  value = math.floor(current+change)
 if value > int16 then
  change = int16 - current
  value = int16
 end
 if value < 0 then
  change = current
  value = 0
 end
  unit.status.current_soul.mental_attrs[attribute].value = value
  current = unit.status.current_soul.mental_attrs[attribute].value
 else
  print('Invalid attribute id')
  return
 end

 if dur > 0 then
  dfhack.script_environment('persist-delay').environmentDelay(dur,'functions/unit','changeAttribute',{unit.id,attribute,-change,0,'end'})
 end

 if track then
  trackAttribute(unit.id,attribute,current,change,value,dur,track)
 end
end

function changeBody(unit,part,changeType,strength,dur)

 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end

 if changeType == "temperature" then
  if strength == 'fire' then
   unit.body.components.body_part_status[part].on_fire = not unit.body.components.body_part_status[part].on_fire
   unit.flags3.body_temp_in_range = not unit.flags3.body_temp_in_range
   change = 'fire'
  else
   change = tostring(-strength)
   unit.status2.body_part_temperature[part].whole=unit.status2.body_part_temperature[part].whole+strength
  end
 end

 if dur > 0 then
  dfhack.script_environment('persist-delay').environmentDelay(dur,'functions/unit','changeBody',{unit.id,part,changeType,change})
 end
end

function changeCounter(unit,counter,change,dur)
 -- Add/Subtract given amount from declared counter of a unit.

 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end

 local value = 0
 local int16 = 3000000
 local current = 0

 if (counter == 'webbed' or counter == 'stunned' or counter == 'winded' or counter == 'unconscious'
     or counter == 'pain' or counter == 'nausea' or counter == 'dizziness') then
  location = unit.counters
 elseif (counter == 'paralysis' or counter == 'numbness' or counter == 'fever' or counter == 'exhaustion'
         or counter == 'hunger' or counter == 'thirst' or counter == 'sleepiness' or oounter == 'hunger_timer'
         or counter == 'thirst_timer' or counter == 'sleepiness_timer') then
  if (counter == 'hunger' or counter == 'thirst' or counter == 'sleepiness') then counter = counter .. '_timer' end
  location = unit.counters2
 elseif counter == 'blood' or counter == 'infection' then
  location = unit.body
 else
  print('Invalid counter token declared')
  return
 end
 current = location[counter]

 value = math.floor(current + change)
 if value > int16 then
  change = int16 - current
  value = int16
 end
 if value < 0 then
  change = current
  value = 0
 end
 location[counter] = value

 if dur > 0 then
  dfhack.script_environment('persist-delay').environmentDelay(dur,'functions/unit','changeCounter',{unit.id,counter,-change})
 end
end

function changeFlag(unit,flag,clear) -- from modtools/create-unit

 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end

 for _,k in ipairs(df.unit_flags1) do
  if flag == k then
   if clear then
    unit.flags1[k] = false
   else
    unit.flags1[k] = true
   end
  end
 end
 for _,k in ipairs(df.unit_flags2) do
  if flag == k then
   if clear then
    unit.flags2[k] = false
   else
    unit.flags2[k] = true
   end
  end
 end
 for _,k in ipairs(df.unit_flags3) do
  if flag == k then
   if clear then
    unit.flags3[k] = false
   else
    unit.flags3[k] = true
   end
  end
 end

end

function changeSkill(unit,skill,change,dur,track)
 -- Add/Subtract given amount from declared skill of a unit.

 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end

 local skills = unit.status.current_soul.skills
 local skillid = df.job_skill[skill]
 local value = 0
 local found = false
 local current = 0

 for i,x in ipairs(skills) do
  if x.id == skillid then
   found = true
   token = x
   current = token.rating
   break
  end
 end
 if not found then
  utils.insert_or_update(unit.status.current_soul.skills,{new = true, id = skillid, rating = 0},'id')
  skills = unit.status.current_soul.skills
  for i,x in ipairs(skills) do
   if x.id == skillid then
    found = true
    token = x
    current = token.rating
    break
   end
  end
 end

 value = math.floor(current+change)
 if value > 20 then
  change = 20 - current
  value = 20
 end
 if value < 0 then
  change = current
  value = 0
 end
 token.rating = value

 if dur > 0 then
  dfhack.script_environment('persist-delay').environmentDelay(dur,'functions/unit','changeSkill',{unit.id,skill,-change,0,'end'})
 end

 if track then
  trackSkill(unit.id,skill,current,change,value,dur,track)
 end
end

function changeResistance(unit,resistance,change,dur,track)
 -- Add/Subtract given amount from declared attribute of a unit.

 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end

-- For if Toady ever implements actual in game resistances 
 
 if dur > 0 then
  dfhack.script_environment('persist-delay').environmentDelay(dur,'functions/unit','changeAttribute',{unit.id,attribute,-change,0,'end'})
 end

 if track then
  trackAttribute(unit.id,attribute,current,change,value,dur,track)
 end
end

function changeTrait(unit,trait,change,dur,track)
 -- Add/Subtract given amount from declared trait of a unit.

 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end

 local value = 0
 local current = 0

 current = unit.status.current_soul.personality.traits[trait]

 value = math.floor(current + change)
 if value > 100 then
  change = 100 - current
  value = 100
 end
 if value < 0 then
  change = current
  value = 0
 end
 unit.status.current_soul.personality.traits[trait] = value

 if dur > 0 then
  dfhack.script_environment('persist-delay').environmentDelay(dur,'functions/unit','changeTrait',{unit.id,trait,-change,0,'end'})
 end

 if track then
  trackTrait(unit.id,trait,current,change,value,dur,track)
 end
end

function checkBodyCategory(unit,category)
 -- Check a unit for body parts that match a given category(s). Returns a list of body part numbers.

 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end
 if type(category) == 'string' then category = {category} end

 local parts = {}
 local body = unit.body.body_plan.body_parts
 local a = 1
 for j,y in ipairs(body) do
  for _,x in ipairs(category) do
   if y.category == x and not unit.body.components.body_part_status[j].missing then
    parts[a] = j
    a = a + 1
   end
  end
 end
 return parts
end

function checkBodyToken(unit,token)
 -- Check a unit for body parts that match a given token(s). Returns a list of body part numbers.

 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end
 if type(token) == 'string' then token = {token} end

 local parts = {}
 local body = unit.body.body_plan.body_parts
 local a = 1
 for j,y in ipairs(body) do
  for _,x in ipairs(token) do
   if y.token == x and not unit.body.components.body_part_status[j].missing then
    parts[a] = j
    a = a + 1
   end
  end
 end
 return parts
end

function checkBodyFlag(unit,flag)
 -- Check a unit for body parts that match a given flag(s). Returns a list of body part numbers.

 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end
 if type(flag) == 'string' then flag = {flag} end

 local parts = {}
 local body = unit.body.body_plan.body_parts
 local a = 1
 for j,y in ipairs(body) do
  for _,x in ipairs(flag) do
   if y.flags[x] and not unit.body.components.body_part_status[j].missing then
    parts[a] = j
    a = a + 1
   end
  end
 end
 return parts
end

function checkClass(unit,class)
 check, x = checkCreatureClass(unit,class)
 if check then return true,x end
 check, x = checkCreatureSyndrome(unit,class)
 if check then return true,x end
 return false,''
end

function checkCreatureClass(unit,class)

 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end
 if type(class) ~= 'table' then class = {class} end

 local unitraws = df.creature_raw.find(unit.race)
 local casteraws = unitraws.caste[unit.caste]
 local unitracename = unitraws.creature_id
 local castename = casteraws.caste_id
 local unitclasses = casteraws.creature_class
 for _,unitclass in ipairs(unitclasses) do
  for _,x in ipairs(class) do
   if x == unitclass.value then
    return  true, x
   end
  end
 end
 return false, ''
end

function checkCreatureRace(unit,creature)
 local utils = require 'utils'
 local split = utils.split_string

 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end
 if type(creature) ~= 'table' then creature = {creature} end

 local unitraws = df.creature_raw.find(unit.race)
 local casteraws = unitraws.caste[unit.caste]
 local unitracename = unitraws.creature_id
 local castename = casteraws.caste_id
 for _,x in ipairs(creature) do
  local xsplit = split(x,':')
  if xsplit[1] == unitracename and (xsplit[2] == castename or xsplit[2] == 'ANY') then
   return true
  end
 end
 return false
end

function checkCreatureSyndrome(unit,class)

 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end
 if type(class) ~= 'table' then class = {class} end

 local actives = unit.syndromes.active
 for _,x in ipairs(actives) do
  local synclass=syndromes[x.type].syn_class
  for _,y in ipairs(synclass) do
   for _,z in ipairs(class) do
    if z == y.value then
     return  true, z
    end
   end
  end
 end
 return false, ''
end

function checkCreatureToken(unit,token)

 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end
 if type(token) ~= 'table' then token = {token} end

 local unitraws = df.creature_raw.find(unit.race)
 local casteraws = unitraws.caste[unit.caste]
 local flags1 = unitraws.flags
 local flags2 = casteraws.flags
 local tokens = {}
 for k,v in pairs(flags1) do
  tokens[k] = v
 end
 for k,v in pairs(flags2) do
  tokens[k] = v
 end

 for _,x in ipairs(token) do
  if tokens[x] then
   return true
  end
 end
 return false
end

function checkDistance(unit,location,distance)

 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end
 if tonumber(distance) then
  distance = {distance, distance, distance}
 end

 local mapx, mapy, mapz = dfhack.maps.getTileSize()
 local x = location[1]
 local y = location[2]
 local z = location[3]
 local rx = distance[1]
 local ry = distance[2]
 local rz = distance[3]

 local xmin = x - rx
 local xmax = x + rx
 local ymin = y - ry
 local ymax = y + ry
 local zmin = z - rz
 local zmax = z + rz
 if xmin < 1 then xmin = 1 end
 if ymin < 1 then ymin = 1 end
 if zmin < 1 then zmin = 1 end
 if xmax > mapx then xmax = mapx-1 end
 if ymax > mapy then ymax = mapy-1 end
 if zmax > mapz then zmax = mapz-1 end
 if (unit.pos.x >= xmin and unit.pos.x <= xmax and unit.pos.y >= ymin and unit.pos.y <= ymax and unit.pos.z >= zmin and unit.pos.z <= zmax) then
  return true
 end
 return false
end

function checkInventoryType(unit,item_type)
 -- Check a unit for any inventory items of a given type(s). Returns a list of item id numbers.

 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end
 if type(item_type) == 'string' then item_type = {item_type} end

 local items = {}
 local inventory = unit.inventory
 local a = 1
 for _,x in ipairs(inventory) do
  for _,y in ipairs(item_type) do
   if df.item_type[x.item:getType()] == y then
    items[a] = x.item.id
    a = a + 1
   end
  end
 end
 return items
end

function create(race,caste,options) --from modtools/create-unit

 local function  allocateNewChunk(hist_entity)
  hist_entity.save_file_id=df.global.unit_chunk_next_id
  df.global.unit_chunk_next_id=df.global.unit_chunk_next_id+1
  hist_entity.next_member_idx=0
  print("allocating chunk:",hist_entity.save_file_id)
 end

 local function allocateIds(nemesis_record,hist_entity)
  if hist_entity.next_member_idx==100 then
   allocateNewChunk(hist_entity)
  end
  nemesis_record.save_file_id=hist_entity.save_file_id
  nemesis_record.member_idx=hist_entity.next_member_idx
  hist_entity.next_member_idx=hist_entity.next_member_idx+1
 end

 local function createFigure(trgunit,he,he_group)
  local hf=df.historical_figure:new()
  hf.id=df.global.hist_figure_next_id
  hf.race=trgunit.race
  hf.caste=trgunit.caste
  hf.profession = trgunit.profession
  hf.sex = trgunit.sex
  df.global.hist_figure_next_id=df.global.hist_figure_next_id+1
  hf.appeared_year = df.global.cur_year

  hf.born_year = trgunit.relations.birth_year
  hf.born_seconds = trgunit.relations.birth_time
  hf.curse_year = trgunit.relations.curse_year
  hf.curse_seconds = trgunit.relations.curse_time
  hf.birth_year_bias = trgunit.relations.birth_year_bias
  hf.birth_time_bias = trgunit.relations.birth_time_bias
  hf.old_year = trgunit.relations.old_year
  hf.old_seconds = trgunit.relations.old_time
  hf.died_year = -1
  hf.died_seconds = -1
  hf.name:assign(trgunit.name)
  hf.civ_id = trgunit.civ_id
  hf.population_id = trgunit.population_id
  hf.breed_id = -1
  hf.unit_id = trgunit.id

  df.global.world.history.figures:insert("#",hf)

  hf.info = df.historical_figure_info:new()
  hf.info.unk_14 = df.historical_figure_info.T_unk_14:new() -- hf state?
  --unk_14.region_id = -1; unk_14.beast_id = -1; unk_14.unk_14 = 0
  hf.info.unk_14.unk_18 = -1; hf.info.unk_14.unk_1c = -1
  -- set values that seem related to state and do event
  --change_state(hf, dfg.ui.site_id, region_pos)


  --lets skip skills for now
  --local skills = df.historical_figure_info.T_skills:new() -- skills snap shot
  -- ...
  hf.info.skills = {new=true}


  he.histfig_ids:insert('#', hf.id)
  he.hist_figures:insert('#', hf)
  if he_group then
   he_group.histfig_ids:insert('#', hf.id)
   he_group.hist_figures:insert('#', hf)
   hf.entity_links:insert("#",{new=df.histfig_entity_link_memberst,entity_id=he_group.id,link_strength=100})
  end
  trgunit.flags1.important_historical_figure = true
  trgunit.flags2.important_historical_figure = true
  trgunit.hist_figure_id = hf.id
  trgunit.hist_figure_id2 = hf.id

  hf.entity_links:insert("#",{new=df.histfig_entity_link_memberst,entity_id=trgunit.civ_id,link_strength=100})

  --add entity event
  local hf_event_id=df.global.hist_event_next_id
  df.global.hist_event_next_id=df.global.hist_event_next_id+1
  df.global.world.history.events:insert("#",{new=df.history_event_add_hf_entity_linkst,year=trgunit.relations.birth_year,
  seconds=trgunit.relations.birth_time,id=hf_event_id,civ=hf.civ_id,histfig=hf.id,link_type=0})
  return hf
 end

 if options then
  dur = options.dur or 0
  civ_id = options.civ_id or -1
  group_id = options.group_id or -1
 end

 local curViewscreen = dfhack.gui.getCurViewscreen()
 local dwarfmodeScreen = df.viewscreen_dwarfmodest:new()
 curViewscreen.child = dwarfmodeScreen
 dwarfmodeScreen.parent = curViewscreen
 local oldMode = df.global.ui.main.mode
 df.global.ui.main.mode = df.ui_sidebar_mode.LookAround

 local gui = require 'gui'

 df.global.world.arena_spawn.race:resize(0)
 df.global.world.arena_spawn.race:insert(0,race) --df.global.ui.race_id)

 df.global.world.arena_spawn.caste:resize(0)
 df.global.world.arena_spawn.caste:insert(0,caste)

 df.global.world.arena_spawn.creature_cnt:resize(0)
 df.global.world.arena_spawn.creature_cnt:insert(0,0)

 df.global.gametype = 4

 gui.simulateInput(dfhack.gui.getCurViewscreen(), 'D_LOOK_ARENA_CREATURE')
 gui.simulateInput(dfhack.gui.getCurViewscreen(), 'SELECT')

 df.global.gametype = 0

 curViewscreen.child = nil
 dwarfmodeScreen:delete()
 df.global.ui.main.mode = oldMode

 local unitId = df.global.unit_next_id-1

 if civ_id >= 0 then
  trgunit = df.unit.find(unitId)
  local id=df.global.nemesis_next_id
  local nem=df.nemesis_record:new()

  nem.id=id
  nem.unit_id=trgunit.id
  nem.unit=trgunit
  nem.flags:resize(4)
    --not sure about these flags...
    -- [[
  nem.flags[4]=true
  nem.flags[5]=true
  nem.flags[6]=true
  nem.flags[7]=true
  nem.flags[8]=true
  nem.flags[9]=true
    --]]
    --[[for k=4,8 do
        nem.flags[k]=true
    end]]
  nem.unk10=-1
  nem.unk11=-1
  nem.unk12=-1
  df.global.world.nemesis.all:insert("#",nem)
  df.global.nemesis_next_id=id+1
  trgunit.general_refs:insert("#",{new=df.general_ref_is_nemesisst,nemesis_id=id})
  trgunit.flags1.important_historical_figure=true

  nem.save_file_id=-1

  local he=df.historical_entity.find(civ_id)
  he.nemesis_ids:insert("#",id)
  he.nemesis:insert("#",nem)
  local he_group
  if group_id and group_id~=-1 then
   he_group=df.historical_entity.find(group_id)
  end
  if he_group then
   he_group.nemesis_ids:insert("#",id)
   he_group.nemesis:insert("#",nem)
  end
   allocateIds(nem,he)
   nem.figure=createFigure(trgunit,he,he_group)
 end
 return unitId
end

function domesticate(unit,group_id) --from modtools/create-unit

 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end

 group_id = group_id or df.global.ui.group_id
 -- If a friendly animal, make it domesticated.  From Boltgun & Dirst
 local caste=df.creature_raw.find(unit.race).caste[unit.caste]
 if not(caste.flags.CAN_SPEAK and caste.flags.CAN_LEARN) then
 -- Fix friendly animals (from Boltgun)
  unit.flags2.resident = false;
  unit.flags3.body_temp_in_range = true;
  unit.population_id = -1
  unit.status.current_soul.unit_id = unit.id

  unit.animal.population.region_x = -1
  unit.animal.population.region_y = -1
  unit.animal.population.unk_28 = -1
  unit.animal.population.population_idx = -1
  unit.animal.population.depth = -1

  unit.counters.soldier_mood_countdown = -1
  unit.counters.death_cause = -1

  unit.enemy.anon_4 = -1
  unit.enemy.anon_5 = -1
  unit.enemy.anon_6 = -1

 -- And make them tame (from Dirst)
  unit.flags1.tame = true
  unit.training_level = 7
 end
end

function makeProjectile(unit,velocity)

 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end

 local vx = velocity[1]
 local vy = velocity[2]
 local vz = velocity[3]

 local count=0
 local l = df.global.world.proj_list
 local lastlist=l
 l=l.next
 while l do
  count=count+1
  if l.next==nil then
   lastlist=l
  end
  l = l.next
 end

 newlist = df.proj_list_link:new()
 lastlist.next=newlist
 newlist.prev=lastlist
 proj = df.proj_unitst:new()
 newlist.item=proj
 proj.link=newlist
 proj.id=df.global.proj_next_id
 df.global.proj_next_id=df.global.proj_next_id+1
 proj.unit=unit
 proj.origin_pos.x=unit.pos.x
 proj.origin_pos.y=unit.pos.y
 proj.origin_pos.z=unit.pos.z
 proj.prev_pos.x=unit.pos.x
 proj.prev_pos.y=unit.pos.y
 proj.prev_pos.z=unit.pos.z
 proj.cur_pos.x=unit.pos.x
 proj.cur_pos.y=unit.pos.y
 proj.cur_pos.z=unit.pos.z
 proj.flags.no_impact_destroy=true
 proj.flags.piercing=true
 proj.flags.parabolic=true
 proj.flags.unk9=true
 proj.speed_x=vx
 proj.speed_y=vy
 proj.speed_z=vz
 unitoccupancy = dfhack.maps.ensureTileBlock(unit.pos).occupancy[unit.pos.x%16][unit.pos.y%16]
 if not unit.flags1.on_ground then
  unitoccupancy.unit = false
 else
  unitoccupancy.unit_grounded = false
 end
 unit.flags1.projectile=true
 unit.flags1.on_ground=false
end

function findUnit(search)
 local persistTable = require 'persist-table'
 local primary = search[1]
 local secondary = search[2] or 'NONE'
 local tertiary = search[3] or 'NONE'
 local quaternary = search[4] or 'NONE'
 local unitList = df.global.world.units.active
 local targetList = {}
 local target = nil
 local n = 0
 if primary == 'RANDOM' then
  if secondary == 'NONE' or secondary == 'ALL' then
   n = 1
   targetList = unitList
  elseif secondary == 'POPULATION' then
   for i,x in pairs(unitList) do
    if dfhack.units.isCitizen(x) then
     n = n + 1
     targetList[n] = x
    end
   end
  elseif secondary == 'CIVILIZATION' then
   for i,x in pairs(unitList) do
    if x.civ_id == df.global.ui.civ_id then
     n = n + 1
     targetList[n] = x
    end
   end
  elseif secondary == 'INVADER' then
   for i,x in pairs(unitList) do
    if x.invasion_id >= 0 then
     n = n + 1
     targetList[n] = x
    end
   end
  elseif secondary == 'MALE' then
   for i,x in pairs(unitList) do
    if x.sex == 0 then
     n = n + 1
     targetList[n] = x
    end
   end
  elseif secondary == 'FEMALE' then
   for i,x in pairs(unitList) do
    if x.sex == 1 then
     n = n + 1
     targetList[n] = x
    end
   end
  elseif secondary == 'PROFESSION' then
   for i,x in pairs(unitList) do
    if tertiary == dfhack.units.getProfessionName(x) then
     n = n + 1
     targetList[n] = x
    end
   end
  elseif secondary == 'CLASS' then
   for i,x in pairs(unitList) do
    if persistTable.GlobalTable.roses.UnitTable[x.id] then
     if persistTable.GlobalTable.roses.UnitTable[x.id].Classes.Current.Name == tertiary then
      n = n + 1
      targetList[n] = x
     end
    end
   end
  elseif secondary == 'SKILL' then
   for i,x in pairs(unitList) do
    if dfhack.units.getEffectiveSkill(x,df.job_skill[tertiary]) >= tonumber(quaternary) then
     n = n + 1
     targetList[n] = x
    end
   end
  else
   for i,x in pairs(unitList) do
    creature = df.global.world.raws.creatures.all[x.race].creature_id
    caste = df.global.world.raws.creatures.all[x.race].caste[x.caste].caste_id
    if secondary == creature then
     if tertiary == caste or tertiary == 'NONE' then
      n = n + 1
      targetList[n] = x
     end
    end
   end
  end
 end
 if n > 0 then
  targetList = dfhack.script_environment('functions/misc').permute(targetList)
  target = targetList[1]
  return target
 else
  print('No valid unit found for event')
  return nil
 end
end