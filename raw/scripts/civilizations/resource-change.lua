local split = require('split')
local utils = require 'utils'
validArgs = validArgs or utils.invert({
 'help',
 'civ',
 'type',
 'obj',
 'remove',
 'add'
})
local args = utils.processArgs({...}, validArgs)

civid = tonumber(args.civ)
civ = df.global.world.entities.all[civid]
resources = civ.resources
mtype = split(args.type,':')[1]
stype = split(args.type,':')[2]
mobj = split(args.obj,':')[1]
sobj = split(args.obj,':')[2]
removes = false
add = false
if args.remove then removes = true end
if args.add then add = true end
if add and removes then return end
if not add and not removes then
 print('No valid command, use -remove or -add')
 return
end

-- ========================================================================================
if mtype == 'CREATURE' then
 creature = {}
 check = false
 if mobj == 'ALL' then
  for i,x in ipairs(df.global.world.raws.creatures.all) do
   creature[i] = {}
  end
  check = true
 else
  mobj_id = -1
  for i,x in ipairs(df.global.world.raws.creatures.all) do
   if mobj == x.creature_id then
    mobj_id = i
    check = true
    creature[mobj_id] = {}
    break
   end
  end
 end
 if not check then
  print('Creature not found '..mobj)
  return
 end
 check = false
 if sobj == 'ALL' then
  for i,x in pairs(creature) do
   for j,y in pairs(df.global.world.raws.creatures.all[i].caste) do
    creature[i][j] = j
   end
  end
  check = true
 else
  for i,x in pairs(creature) do
   sobj_id = -1
   for j,y in ipairs(df.global.world.raws.creatures.all[i].caste) do
    if sobj == y.caste_id then
     sobj_id = j
     creature[i][sobj_id] = sobj_id
     check = true
     break
    end
   end
  end
 end
 if not check then
  print('Caste not found '..sobj)
  return
 end
 if stype == 'ALL' then
  print('-type CREATURE:ALL IS NOT CURRENTLY SUPPORTED')
  return
 elseif stype == 'PET' then
  races = resources.animals.pet_races
  castes = resources.animals.pet_castes
 elseif stype == 'WAGON' then
  races = resources.animals.wagon_puller_races
  castes = resources.animals.wagon_puller_castes
 elseif stype == 'MOUNT' then
  races = resources.animals.mount_races
  castes = resources.animals.mount_castes
 elseif stype == 'PACK' then
  races = resources.animals.pack_animal_races
  castes = resources.animals.pack_animal_castes
 elseif stype == 'MINION' then
  races = resources.animals.minion_races
  castes = resources.animals.minion_castes
 elseif stype == 'EXOTIC' then
  races = resources.animals.exotic_pet_races
  castes = resources.animals.exotic_pet_castes
 elseif stype == 'FISH' then
  races = resources.fish_races
  castes = resources.fish_castes
 elseif stype == 'EGG' then
  races = resources.egg_races
  castes = resources.egg_castes
 else
  print('Not a valid type')
 end
 if removes then
  for i,x in pairs(races) do
   if creature[x] then
    if creature[x][castes[i]] then
     civ.resources.animals.races:erase(i)
     civ.resources.animals.castes:erase(i)
    end
   end
  end
 elseif add then
  for i,x in pairs(creature) do
   for j,y in pairs(x) do
    races:insert('#',i)
    castes:insert('#',y)
   end
  end
 end
-- ============================================================================================
elseif mtype == 'ITEM' then
-- Check for subtype of Item
 if stype == 'ALL' then
  print('-type ITEM:ALL IS NOT CURRENTLY SUPPORTED')
  return
 elseif stype == 'WEAPON' then
  ind = df.item_type['WEAPON']
  items = resources.weapon_type
 elseif stype == 'SHIELD' then
  ind = df.item_type['SHIELD']
  items = resources.shield_type
 elseif stype == 'AMMO' then
  ind = df.item_type['AMMO']
  items = resources.ammo_type
 elseif stype == 'HELM' then
  ind = df.item_type['HELM']
  items = resources.helm_type
 elseif stype == 'ARMOR' then
  ind = df.item_type['ARMOR']
  items = resources.armor_type
 elseif stype == 'PANTS' then
  ind = df.item_type['PANTS']
  items = resources.pants_type
 elseif stype == 'SHOES' then
  ind = df.item_type['SHOES']
  items = resources.shoes_type
 elseif stype == 'GLOVES' then
  ind = df.item_type['GLOVES']
  items = resources.gloves_type
 elseif stype == 'TRAP' then
  ind = df.item_type['TRAPCOMP']
  items = resources.trapcomp_type
 elseif stype == 'SIEGE' then
  ind = df.item_type['SIEGEAMMO']
  items = resources.siegeammo_type
 elseif stype == 'TOY' then
  ind = df.item_type['TOY']
  items = resources.toy_type
 elseif stype == 'INSTRUMENT' then
  ind = df.item_type['INSTRUMENT']
  items = resources.instrument_type
 elseif stype == 'TOOL' then
  ind = df.item_type['TOOL']
  items = resources.tool_type
 elseif stype == 'DIGGER' then
  --Don't know what the item_type of digger is
 elseif stype == 'TRAINING' then
  --Don't know what the item_type of training is
 else
  print('Not a valid type')
  return
 end
-- Add or remove item
 if mobj == 'ALL' then
  if removes then
   for i=#items-1,0,-1 do
    items:erase(i)
   end
  elseif add then
   for i=0,dfhack.items.getSubtypeCount(ind)-1 do
    local item_subtype = dfhack.items.getSubtypeDef(ind,i).subtype
    items:insert('#',item_subtype)
   end
  end
 else
  for i=0,dfhack.items.getSubtypeCount(ind)-1 do
   local item_sub = dfhack.items.getSubtypeDef(ind,i)
   if item_sub.id == mobj then
    item_subtype = item_sub.subtype
    break
   end
  end
  if removes then
   for i=#items-1,0,-1 do
    if x == items[i] then items:erase(i) end
   end
  elseif add then
   items:insert('#',item_subtype)
  end
 end
-- =====================================================================================================
elseif mtype == 'INORGANIC' then
 if stype == 'ALL' then
  print('-type INORGANIC:ALL IS NOT CURRENTLY SUPPORTED')
  return
 elseif stype == 'METAL' then
  inorganic = resources.metals
  check = 'IS_METAL'
 elseif stype == 'STONE' then
  inorganic = resources.stones
  check = 'IS_STONE'
 elseif stype == 'GEM' then
  inorganic = resources.gems
  check = 'IS_GEM'
 else
  print('Not a valid type')
  return
 end
 if mobj == 'ALL' then
  if removes then
   for i=#inorganic-1,0,-1 do
    inorganic:erase(i)
   end
  elseif add then
   for i,x in pairs(df.global.world.raws.inorganics) do
    if x.material.flags[check] then
     inorganic:insert('#',dfhack.matinfo.find(x.id).index)
    end
   end
  end
 else
  mat_id = dfhack.matinfo.find(mobj).index
  if dfhack.matinfo.decode(0,mat_id).material.flags[check] then
   if removes then
    for i=#inorganic-1,0,-1 do
     if inorganic[i] == mat_id then inorganic:erase(i) end
    end
   elseif add then
    inorganic:insert('#',mat_id)
   end
  else
   print('Material not valid ['..check..'] material')
  end  
 end
-- ===============================================================================================
elseif mtype == 'ORGANIC' then
 if stype == 'ALL' then
  print('-type ORGANIC:ALL IS NOT CURRENTLY SUPPORTED')
  return
 elseif stype == 'LEATHER' then
  organic = resources.organic.leather
  check = 'LEATHER'
 elseif stype == 'FIBER' then
  organic = resources.organic.fiber
  check = 'THREAD_PLANT'
 elseif stype == 'SILK' then
  organic = resources.organic.silk
  check = 'SILK'
 elseif stype == 'WOOL' then
  organic = resources.organic.wool
  check = 'YARN'
 elseif stype == 'WOOD' then
  organic = resources.organic.wood
  check = 'WOOD'
 elseif stype == 'PLANT' then
  organic = resources.plants
  check = 'STRUCTURAL_PLANT_MAT'
 elseif stype == 'SEED' then
  organic = resources.seeds
  check = 'SEED_MAT'
 else
  print('Not a valid type')
  return
 end
 if mobj == 'ALL' then
  if removes then
   for i=#organic.mat_type-1,0,-1 do
    organic.mat_type:erase(i)
   end
   for i=#organic.mat_index-1,0,-1 do
    organic.mat_index:erase(i)
   end
  elseif add then
   for i,x in pairs(df.global.world.raws.creatures.all) do
    for j,y in pairs(x.material) do
     if y.flags[check] then
      organic.mat_type:insert('#',dfhack.matinfo.find(x.creature_id..':'..y.id).type)
      organic.mat_index:insert('#',dfhack.matinfo.find(x.creature_id..':'..y.id).index)
     end
    end
   end
  end
 else
  mat_type = dfhack.matinfo.find(mobj..':'..sobj).type
  mat_index = dfhack.matinfo.find(mobj..':'..sobj).index
  if dfhack.matinfo.decode(mat_type,mat_index).material.flags[check] then
   if removes then
    for i=#organic.mat_type-1,0,-1 do
     if organic.mat_type[i] == mat_type then
      if oganic.mat_index[i] == mat_index then
       organic.mat_type:erase(i)
       organic.mat_index:erase(i)
      end
     end
    end
   elseif add then
    organic.mat_type:insert('#',mat_type)
    organic.mat_index:insert('#',mat_index)
   end
  else
   print('Material not valid ['..check..'] material')
  end
 end
-- ==========================================================================================================
elseif mtype == 'REFUSE' then
 if stype == 'ALL' then
  print('-type REFUSE:ALL IS NOT CURRENTLY SUPPORTED')
  return
 elseif stype == 'BONE' then
  check = 'BONE'
  refuse = resources.refuse.bone
 elseif stype == 'SHELL' then
  check = 'SHELL'
  refuse = resources.refuse.shell
 elseif stype == 'PEARL' then
  check = 'PEARL'
  refuse = resources.refuse.pearl
 elseif stype == 'IVORY' then
  check = 'TOOTH'
  refuse = resources.refuse.ivory
 elseif stype == 'HORN' then
  check = 'HORN'
  refuse = resources.refuse.horn
 else
  print('Not a valid type')
  return
 end
 if mobj == 'ALL' then
  if removes then
   for i=#refuse.mat_type-1,0,-1 do
    refuse.mat_type:erase(i)
   end
   for i=#refuse.mat_index-1,0,-1 do
    refuse.mat_index:erase(i)
   end
  elseif add then
   for i,x in pairs(df.global.world.raws.creatures.all) do
    for j,y in pairs(x.material) do
     if y.flags[check] then
      refuse.mat_type:insert('#',dfhack.matinfo.find(x.creature_id..':'..y.id).type)
      refuse.mat_index:insert('#',dfhack.matinfo.find(x.creature_id..':'..y.id).index)
     end
    end
   end
  end
 else
  mat_type = dfhack.matinfo.find(mobj..':'..sobj).type
  mat_index = dfhack.matinfo.find(mobj..':'..sobj).index
  if dfhack.matinfo.decode(mat_type,mat_index).material.flags[check] then
   if removes then
    for i=#refuse.mat_type-1,0,-1 do
     if refuse.mat_type[i] == mat_type then
      if refuse.mat_index[i] == mat_index then
       refuse.mat_type:erase(i)
       refuse.mat_index:erase(i)
      end
     end
    end
   elseif add then
    refuse.mat_type:insert('#',mat_type)
    refuse.mat_index:insert('#',mat_index)
   end
  else
   print('Material not valid ['..check..'] material')
  end
 end
-- ==========================================================================================================
elseif mtype == 'MISC' then
 if stype == 'ALL' then
  print('-type MISC:ALL IS NOT CURRENTLY SUPPORTED')
  return
 elseif stype == 'OTHER' then
  print('-type MISC:'..stype..' IS NOT CURRENTLY SUPPORTED')
  return
 elseif stype == 'GLASS' then
  check = 'IS_GLASS'
  misc = resources.misc_mat.glass
 elseif stype == 'SAND' then
  print('-type MISC:'..stype..' IS NOT CURRENTLY SUPPORTED')
  return
 elseif stype == 'CLAY' then
  print('-type MISC:'..stype..' IS NOT CURRENTLY SUPPORTED')
  return
 elseif stype == 'CRAFTS' then
  print('-type MISC:'..stype..' IS NOT CURRENTLY SUPPORTED')
  return
 elseif stype == 'GLASS_UNUSED' then
  print('-type MISC:'..stype..' IS NOT CURRENTLY SUPPORTED')
  return
 elseif stype == 'BARRELS' then
  print('-type MISC:'..stype..' IS NOT CURRENTLY SUPPORTED')
  return
 elseif stype == 'FLASKS' then
  print('-type MISC:'..stype..' IS NOT CURRENTLY SUPPORTED')
  return
 elseif stype == 'QUIVERS' then
  print('-type MISC:'..stype..' IS NOT CURRENTLY SUPPORTED')
  return
 elseif stype == 'BACKPACKS' then
  print('-type MISC:'..stype..' IS NOT CURRENTLY SUPPORTED')
  return
 elseif stype == 'CAGES' then
  print('-type MISC:'..stype..' IS NOT CURRENTLY SUPPORTED')
  return
 elseif stype == 'WOOD2' then
  print('-type MISC:'..stype..' IS NOT CURRENTLY SUPPORTED')
  return
 elseif stype == 'ROCK_METAL' then
  print('-type MISC:'..stype..' IS NOT CURRENTLY SUPPORTED')
  return
 elseif stype == 'BOOZE' then
  check = 'ALCOHOL'
  misc = resources.misc_mat.booze
 elseif stype == 'CHEESE' then
  check = 'CHEESE'
  misc = resources.misc_mat.cheese
 elseif stype == 'POWDER' then
  check = 'POWDER_MISC'
  misc = resources.misc_mat.powders
 elseif stype == 'EXTRACT' then
  check = 'LIQUID_MISC'
  misc = resources.misc_mat.extracts
 elseif stype == 'MEAT' then
  check = 'MEAT'
  misc = resources.misc_mat.meat
 else
  print('Not a valid type')
  return
 end
 if mobj == 'ALL' then
  if removes then
   for i=#misc.mat_type-1,0,-1 do
    misc.mat_type:erase(i)
   end
   for i=#misc.mat_index-1,0,-1 do
    misc.mat_index:erase(i)
   end
  elseif add then
   print('-obj ALL:ALL -add IS NOT CURRENTLY SUPPORTED')
   return
  end
 else
  mat_type = dfhack.matinfo.find(mobj..':'..sobj).type
  mat_index = dfhack.matinfo.find(mobj..':'..sobj).index
  if dfhack.matinfo.decode(mat_type,mat_index).material.flags[check] then
   if removes then
    for i=#refuse.mat_type-1,0,-1 do
     if misc.mat_type[i] == mat_type then
      if misc.mat_index[i] == mat_index then
       misc.mat_type:erase(i)
       misc.mat_index:erase(i)
      end
     end
    end
   elseif add then
    misc.mat_type:insert('#',mat_type)
    misc.mat_index:insert('#',mat_index)
   end
  else
   print('Material not valid ['..check..'] material')
  end
 end
-- ==========================================================================================================
else
 print('Not a valid type')
 return
end