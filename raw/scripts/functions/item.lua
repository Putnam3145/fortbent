function trackMaterial(itemID,change,dur,alter)
 local persistTable = require 'persist-table'
 local itemTable = persistTable.GlobalTable.roses.ItemTable
 if not itemTable[tostring(itemID)] then
  dfhack.script_environment('functions/tables').makeItemTable(itemID)
 end
 if alter == 'track' then
  local materialTable = itemTable[tostring(itemID)].Material
  materialTable.Current = change
  if dur >= 0 then
   local statusTable = materialTable.StatusEffects
   local number = #statusTable._children
   statusTable[tostring(number+1)] = {}
   statusTable[tostring(number+1)].End = 1200*28*3*4*df.global.cur_year + df.global.cur_year_tick + dur
   statusTable[tostring(number+1)].Change = change
  else
   materialTable.Base = change
  end
 elseif alter == 'end' then
  local materialTable = itemTable[tostring(itemID)].Material
  materialTable.Current = change
  local statusTable = materialTable.StatusEffects
  for i = #statusTable._children,1,-1 do
   if statusTable[i] then
    if statusTable[i].End <= 1200*28*3*4*df.global.cur_year + df.global.cur_year_tick then
     statusTable[i] = nil
    end
   end
  end
 end
end

function trackQuality(itemID,change,dur,alter)
 local persistTable = require 'persist-table'
 local itemTable = persistTable.GlobalTable.roses.ItemTable
 if not itemTable[tostring(itemID)] then
  dfhack.script_environment('functions/tables').makeItemTable(itemID)
 end
 if alter == 'track' then
  local qualityTable = itemTable[tostring(itemID)].Quality
  qualityTable.Current = tostring(change)
  if dur >= 0 then
   local statusTable = qualityTable.StatusEffects
   local number = #statusTable._children
   statusTable[tostring(number+1)] = {}
   statusTable[tostring(number+1)].End = 1200*28*3*4*df.global.cur_year + df.global.cur_year_tick + dur
   statusTable[tostring(number+1)].Change = tostring(change)
  else
   qualityTable.Base = tostring(change)
  end
 elseif alter == 'end' then
  local qualityTable = itemTable[tostring(itemID)].Quality
  qualityTable.Current = tostring(change)
  local statusTable = qualityTable.StatusEffects
  for i = #statusTable._children,1,-1 do
   if statusTable[i] then
    if statusTable[i].End <= 1200*28*3*4*df.global.cur_year + df.global.cur_year_tick then
     statusTable[i] = nil
    end
   end
  end
 end
end

function trackSubtype(itemID,change,dur,alter)
 local persistTable = require 'persist-table'
 local itemTable = persistTable.GlobalTable.roses.ItemTable
 if not itemTable[tostring(itemID)] then
  dfhack.script_environment('functions/tables').makeItemTable(itemID)
 end
 if alter == 'track' then
  local subtypeTable = itemTable[tostring(itemID)].Quality
  subtypeTable.Current = tostring(change)
  if dur >= 0 then
   local statusTable = subtypeTable.StatusEffects
   local number = #statusTable._children
   statusTable[tostring(number+1)] = {}
   statusTable[tostring(number+1)].End = 1200*28*3*4*df.global.cur_year + df.global.cur_year_tick + dur
   statusTable[tostring(number+1)].Change = tostring(change)
  else
   subtypeTable.Base = tostring(change)
  end
 elseif alter == 'end' then
  local subtypeTable = itemTable[tostring(itemID)].Quality
  subtypeTable.Current = tostring(change)
  local statusTable = subtypeTable.StatusEffects
  for i = #statusTable._children,1,-1 do
   if statusTable[i] then
    if statusTable[i].End <= 1200*28*3*4*df.global.cur_year + df.global.cur_year_tick then
     statusTable[i] = nil
    end
   end
  end
 end
end

function changeMaterial(item,material,dur,track)
 if tonumber(item) then
  item = df.item.find(tonumber(item))
 end

 mat = dfhack.matinfo.find(material)
 save = dfhack.matinfo.getToken(item.mat_type,item.mat_index)
 item.mat_type = mat.type
 item.mat_index = mat.index

 if tonumber(dur) and tonumber(dur) > 0 then
  dfhack.script_environment('persist-delay').environmentDelay(dur,'functions/item','changeMaterial',{item.id,save,0,'end'})
 end

 if track then
  trackMaterial(item.id,material,dur,track)
 end
end

function changeQuality(item,quality,dur,track)
 if tonumber(item) then
  item = df.item.find(tonumber(item))
 end

 save = item.quality
 item:setQuality(quality)

 if tonumber(dur) and tonumber(dur) > 0 then
  dfhack.script_environment('persist-delay').environmentDelay(dur,'functions/item','changeQuality',{item.id,save,0,'end'})
 end

 if track then
  trackQuality(item.id,quality,dur,track)
 end
end

function changeSubtype(item,subtype,dur,track)
 if tonumber(item) then
  item = df.item.find(tonumber(item))
 end

 local itemType = item:getType()
 local itemSubtype = item:getSubtype()
 itemSubtype = dfhack.items.getSubtypeDef(itemType,itemSubtype).id
 local found = false
 for i=0,dfhack.items.getSubtypeCount(itemType)-1,1 do
  local item_sub = dfhack.items.getSubtypeDef(itemType,i)
  if item_sub.id == subtype then
   item:setSubtype(item_sub.subtype)
   found = true
  end
 end

 if tonumber(dur) and tonumber(dur) > 0 and found then
  dfhack.script_environment('persist-delay').environmentDelay(dur,'functions/item','changeSubtype',{item.id,itemSubtype,0,'end'})
 elseif not found then
  print('Incompatable item type and subtype')
 end

 if track and found then
  trackSubtype(item.id,subtype,dur,track)
 end
end

function create(item,material,options) --from modtools/create-item
 options = options or {}
 quality = options.quality or 0
 creatorID = options.creator or -1
 if tonumber(creatorID) and tonumber(creatorID) >= 0then
  creator = df.unit.find(creatorID)
 else
  creator = creatorID
  creatorID = creator.id
 end
 dur = options.dur or 0

 itemType = dfhack.items.findType(item)
 if itemType == -1 then
  error 'Invalid item.'
 end
 local itemSubtype = dfhack.items.findSubtype(item)

 material = dfhack.matinfo.find(material)
 if not material then
  error 'Invalid material.'
 end

 if tonumber(creatorID) >= 0 then
  item = dfhack.items.createItem(itemType, itemSubtype, material.type, material.index, creator)
 else
  item = dfhack.items.createItem(itemType, itemSubtype, material.type, material.index, df.unit.find(0))
  item = df.item.find(item)
  item.maker_race = -1
  item.maker = -1
  item = item.id
 end

 if dur > 0 then
  dfhack.script_environment('persist-delay').environmentDelay(dur,'functions/item','removal',{item})
 end

 return item

end

function equip(item, unit, bodyPart, mode) --from modtools/equip-item
  --it is assumed that the item is on the ground
  --taken from expwnent
  item.flags.on_ground = false
  item.flags.in_inventory = true
  local block = dfhack.maps.getTileBlock(item.pos)
  local occupancy = block.occupancy[item.pos.x%16][item.pos.y%16]
  for k,v in ipairs(block.items) do
    --local blockItem = df.item.find(v)
    if v == item.id then
      block.items:erase(k)
      break
    end
  end
  local foundItem = false
  for k,v in ipairs(block.items) do
    local blockItem = df.item.find(v)
    if blockItem.pos.x == item.pos.x and blockItem.pos.y == item.pos.y then
      foundItem = true
      break
    end
  end
  if not foundItem then
    occupancy.item = false
  end

  local inventoryItem = df.unit_inventory_item:new()
  inventoryItem.item = item
  inventoryItem.mode = mode
  inventoryItem.body_part_id = bodyPart
  unit.inventory:insert(#unit.inventory,inventoryItem)
end

function makeProjectileFall(item,origin,velocity)
 if tonumber(item) then
  item = df.item.find(tonumber(item))
 end

 proj = dfhack.items.makeProjectile(item)
 proj.origin_pos.x=origin[1]
 proj.origin_pos.y=origin[2]
 proj.origin_pos.z=origin[3]
 proj.prev_pos.x=origin[1]
 proj.prev_pos.y=origin[2]
 proj.prev_pos.z=origin[3]
 proj.cur_pos.x=origin[1]
 proj.cur_pos.y=origin[2]
 proj.cur_pos.z=origin[3]
 proj.flags.no_impact_destroy=false
 proj.flags.bouncing=true
 proj.flags.piercing=true
 proj.flags.parabolic=true
 proj.flags.unk9=true
 proj.flags.no_collide=true
 proj.speed_x=velocity[1]
 proj.speed_y=velocity[2]
 proj.speed_z=velocity[3]

end

function makeProjectileShot(item,origin,target,options)
 if tonumber(item) then
  item = df.item.find(tonumber(item))
 end

 velocity = options.velocity or 20
 hit_chance = options.accuracy or 50
 max_range = options.range or 10
 min_range = options.minimum or 1

 proj = dfhack.items.makeProjectile(item)
 proj.origin_pos.x=origin[1]
 proj.origin_pos.y=origin[2]
 proj.origin_pos.z=origin[3]
 proj.prev_pos.x=origin[1]
 proj.prev_pos.y=origin[2]
 proj.prev_pos.z=origin[3]
 proj.cur_pos.x=origin[1]
 proj.cur_pos.y=origin[2]
 proj.cur_pos.z=origin[3]
 proj.target_pos.x=target[1]
 proj.target_pos.y=target[2]
 proj.target_pos.z=target[3]
 proj.flags.no_impact_destroy=false
 proj.flags.bouncing=false
 proj.flags.piercing=false
 proj.flags.parabolic=false
 proj.flags.unk9=false
 proj.flags.no_collide=false
-- Need to figure out these numbers!!!
 proj.distance_flown=0 -- Self explanatory
 proj.fall_threshold=max_range -- Seems to be able to hit units further away with larger numbers
 proj.min_hit_distance=min_range -- Seems to be unable to hit units closer than this value
 proj.min_ground_distance=max_range-1 -- No idea
 proj.fall_counter=0 -- No idea
 proj.fall_delay=0 -- No idea
 proj.hit_rating=hit_chance -- I think this is how likely it is to hit a unit (or to go where it should maybe?)
 proj.unk22 = velocity
 proj.speed_x=0
 proj.speed_y=0
 proj.speed_z=0

end

function removal(item)

 if tonumber(item) then
  item = df.item.find(item)
 end

 dfhack.items.remove(item)

end

function findItem(search)
 local primary = search[1]
 local secondary = search[2] or 'NONE'
 local tertiary = search[3] or 'NONE'
 local quaternary = search[4] or 'NONE'
 local itemList = df.global.world.items.all
 local targetList = {}
 local target = nil
 local n = 0
 if primary == 'RANDOM' then
  if secondary == 'NONE' or secondary == 'ALL' then
   for i,x in pairs(itemList) do
    if dfhack.items.getPosition(x) then
     n = n + 1
     targetList[n] = x
    end
   end
  elseif secondary == 'WEAPON' then
   for i,x in pairs(itemList) do
    if dfhack.items.getPosition(x) and df.item_weaponst:is_instance(x) then
     if x.subtype then
      if tertiary == x.subtype.id or tertiary == 'NONE' then
       n = n + 1
       targetList[n] = x
      end
     end
    end
   end
  elseif secondary == 'ARMOR' then
   for i,x in pairs(itemList) do
    if dfhack.items.getPosition(x) and df.item_armorst:is_instance(x) then
     if x.subtype then
      if tertiary == x.subtype.id or tertiary == 'NONE' then
       n = n + 1
       targetList[n] = x
      end
     end
    end
   end
  elseif secondary == 'HELM' then
   for i,x in pairs(itemList) do
    if dfhack.items.getPosition(x) and df.item_helmst:is_instance(x) then
     if x.subtype then
      if tertiary == x.subtype.id or tertiary == 'NONE' then
       n = n + 1
       targetList[n] = x
      end
     end
    end
   end
  elseif secondary == 'SHIELD' then
   for i,x in pairs(itemList) do
    if dfhack.items.getPosition(x) and df.item_shieldst:is_instance(x) then
     if x.subtype then
      if tertiary == x.subtype.id or tertiary == 'NONE' then
       n = n + 1
       targetList[n] = x
      end
     end
    end
   end
  elseif secondary == 'GLOVE' then
   for i,x in pairs(itemList) do
    if dfhack.items.getPosition(x) and df.item_glovesst:is_instance(x) then
     if x.subtype then
      if tertiary == x.subtype.id or tertiary == 'NONE' then
       n = n + 1
       targetList[n] = x
      end
     end
    end
   end
  elseif secondary == 'SHOE' then
   for i,x in pairs(itemList) do
    if dfhack.items.getPosition(x) and df.item_shoesst:is_instance(x) then
     if x.subtype then
      if tertiary == x.subtype.id or tertiary == 'NONE' then
       n = n + 1
       targetList[n] = x
      end
     end
    end
   end
  elseif secondary == 'PANTS' then
   for i,x in pairs(itemList) do
    if dfhack.items.getPosition(x) and df.item_pantsst:is_instance(x) then
     if x.subtype then
      if tertiary == x.subtype.id or tertiary == 'NONE' then
       n = n + 1
       targetList[n] = x
      end
     end
    end
   end
  elseif secondary == 'AMMO' then
   for i,x in pairs(itemList) do
    if dfhack.items.getPosition(x) and df.item_ammost:is_instance(x) then
     if x.subtype then
      if tertiary == x.subtype.id or tertiary == 'NONE' then
       n = n + 1
       targetList[n] = x
      end
     end
    end
   end
  elseif secondary == 'MATERIAL' then
   local mat_type = dfhack.matinfo.find(tertiary).type
   local mat_index = dfhack.matinfo.find(tertiary).index
   for i,x in pairs(itemList) do
    if dfhack.items.getPosition(x) and x.mat_type == mat_type and x.mat_index == mat_index then
     n = n + 1
     targetList[n] = x
    end
   end
  elseif secondary == 'VALUE' then
   if tertiary == 'LESS_THAN' then
    for i,x in pairs(itemList) do
     if dfhack.items.getPosition(x) and dfhack.items.getValue(x) <= tonumber(quaternary) then
      n = n + 1
      targetList[n] = x
     end
    end
   elseif tertiary == 'GREATER_THAN' then
    for i,x in pairs(itemList) do
     if dfhack.items.getPosition(x) and dfhack.items.getValue(x) >= tonumber(quaternary) then
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
  print('No valid item found for event')
  return nil
 end
end