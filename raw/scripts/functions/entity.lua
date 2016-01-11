function changeCreature(entity,stype,mobj,sobj,direction,verbose)

 if tonumber(entity) then
  civid = tonumber(entity)
  civ = df.global.world.entities.all[civid]
 else
  civ = entity
 end
 resources = civ.resources

 creature = {}
 check = false
 if string.upper(mobj) == 'ALL' then
  for i,x in ipairs(df.global.world.raws.creatures.all) do
   creature[i] = {}
  end
  check = true
 else
  mobj_id = -1
  for i,x in ipairs(df.global.world.raws.creatures.all) do
   if string.upper(mobj) == x.creature_id then
    mobj_id = i
    check = true
    creature[mobj_id] = {}
    break
   end
  end
 end
 if not check then
  if verbose then print('Creature not found '..mobj) end
  return
 end
 check = false
 if string.upper(sobj) == 'ALL' then
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
    if string.upper(sobj) == y.caste_id then
     sobj_id = j
     creature[i][sobj_id] = sobj_id
     check = true
     break
    end
   end
  end
 end
 if not check then
  if verbose then print('Caste not found '..sobj) end
  return
 end
 if string.upper(stype) == 'ALL' then
  if verbose then print('-type CREATURE:ALL IS NOT CURRENTLY SUPPORTED') end
  return
 elseif string.upper(stype) == 'PET' then
  races = resources.animals.pet_races
  castes = resources.animals.pet_castes
 elseif string.upper(stype) == 'WAGON' then
  races = resources.animals.wagon_puller_races
  castes = resources.animals.wagon_puller_castes
 elseif string.upper(stype) == 'MOUNT' then
  races = resources.animals.mount_races
  castes = resources.animals.mount_castes
 elseif string.upper(stype) == 'PACK' then
  races = resources.animals.pack_animal_races
  castes = resources.animals.pack_animal_castes
 elseif string.upper(stype) == 'MINION' then
  races = resources.animals.minion_races
  castes = resources.animals.minion_castes
 elseif string.upper(stype) == 'EXOTIC' then
  races = resources.animals.exotic_pet_races
  castes = resources.animals.exotic_pet_castes
 elseif string.upper(stype) == 'FISH' then
  races = resources.fish_races
  castes = resources.fish_castes
 elseif string.upper(stype) == 'EGG' then
  races = resources.egg_races
  castes = resources.egg_castes
 else
  if verbose then print('Not a valid type') end
 end

 if direction == -1 then
  local int = 1
  removing = {}
  for i,x in pairs(races) do
   if creature[x] then
    if creature[x][castes[i]] then
     removing[int] = i
     int = int + 1
     if verbose then print('Removing CREATURE:CASTE '..x..':'..i..' from '..stype) end
    end
   end
  end
  for i = #removing,1,-1 do
   races:erase(removing[i])
   castes:erase(removing[i])
  end
 elseif direction == 1 then
  for i,x in pairs(creature) do
   for j,y in pairs(x) do
    races:insert('#',i)
    castes:insert('#',y)
    if verbose then print('Adding CREATURE:CASTE '..i..':'..y..' to '..stype) end
   end
  end
 end

end

function changeInorganic(entity,stype,mobj,sobj,direction,verbose)
 stype = string.upper(stype)
 mobj = string.upper(mobj)

 if tonumber(entity) then
  civid = tonumber(entity)
  civ = df.global.world.entities.all[civid]
 else
  civ = entity
 end
 resources = civ.resources

 if stype == 'ALL' then
  if verbose then print('-type INORGANIC:ALL IS NOT CURRENTLY SUPPORTED') end
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
  if verbose then print('Not a valid type') end
  return
 end
 if mobj == 'ALL' then
  if direction == -1 then
   for i=#inorganic-1,0,-1 do
    inorganic:erase(i)
    if verbose then print('Removing inorganic TYPE:SUBTYPE'..stype..':'..i) end
   end
  elseif direction == 1 then
   for i,x in pairs(df.global.world.raws.inorganics) do
    if x.material.flags[check] then
     inorganic:insert('#',dfhack.matinfo.find(x.id).index)
     if verbose then print('Adding inorganic TYPE:SUBTYPE'..stype..':'..dfhack.matinfo.find(x.id).index) end
    end
   end
  end
 else
  mat_id = dfhack.matinfo.find(mobj).index
  if dfhack.matinfo.decode(0,mat_id).material.flags[check] then
   if direction == -1 then
    for i=#inorganic-1,0,-1 do
     if inorganic[i] == mat_id then
      inorganic:erase(i)
      if verbose then print('Removing inorganic TYPE:SUBTYPE'..stype..':'..mat_id) end
      break
     end
    end
   elseif direction == 1 then
    inorganic:insert('#',mat_id)
    if verbose then print('Adding inorganic TYPE:SUBTYPE'..stype..':'..mat_id) end
   end
  else
   if verbose then print('Material not valid ['..check..'] material') end
  end
 end

end

function changeItem(entity,stype,mobj,sobj,direction,verbose)
 stype = string.upper(stype)
 mobj = string.upper(mobj)

 if tonumber(entity) then
  civid = tonumber(entity)
  civ = df.global.world.entities.all[civid]
 else
  civ = entity
 end
 resources = civ.resources

 if stype == 'ALL' then
  if verbose then print('-type ITEM:ALL IS NOT CURRENTLY SUPPORTED') end
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
  if verbose then print('Not a valid item type') end
  return
 end
-- Add or remove item
 if mobj == 'ALL' then
  if direction == -1 then
   for i=#items-1,0,-1 do
    items:erase(i)
    if verbose then print('Removing item TYPE:SUBTYPE '..stype..':'..i) end
   end
  elseif direction == 1 then
   for i=0,dfhack.items.getSubtypeCount(ind)-1 do
    local item_subtype = dfhack.items.getSubtypeDef(ind,i).subtype
    items:insert('#',item_subtype)
    if verbose then print('Adding item TYPE:SUBTYPE '..stype..':'..item_subtype) end
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
  if direction == -1 then
   for i=#items-1,0,-1 do
    if item_subtype == items[i] then
     items:erase(i)
     if verbose then print('Removing item TYPE:SUBTYPE '..stype..':'..item_subtype) end
    end
   end
  elseif direction == 1 then
   items:insert('#',item_subtype)
   if verbose then print('Adding item TYPE:SUBTYPE '..stype..':'..item_subtype) end
  end
 end

end

function changeMisc(entity,stype,mobj,sobj,direction,verbose)
 stype = string.upper(stype)
 mobj = string.upper(mobj)
 sobj = string.upper(sobj)

 if tonumber(entity) then
  civid = tonumber(entity)
  civ = df.global.world.entities.all[civid]
 else
  civ = entity
 end
 resources = civ.resources

 if stype == 'ALL' then
  if verbose then print('-type MISC:ALL IS NOT CURRENTLY SUPPORTED') end
  return
 elseif stype == 'OTHER' then
  if verbose then print('-type MISC:'..stype..' IS NOT CURRENTLY SUPPORTED') end
  return
 elseif stype == 'GLASS' then
  check = 'IS_GLASS'
  misc = resources.misc_mat.glass
 elseif stype == 'SAND' then
  if verbose then print('-type MISC:'..stype..' IS NOT CURRENTLY SUPPORTED') end
  return
 elseif stype == 'CLAY' then
  if verbose then print('-type MISC:'..stype..' IS NOT CURRENTLY SUPPORTED') end
  return
 elseif stype == 'CRAFTS' then
  if verbose then print('-type MISC:'..stype..' IS NOT CURRENTLY SUPPORTED') end
  return
 elseif stype == 'GLASS_UNUSED' then
  if verbose then print('-type MISC:'..stype..' IS NOT CURRENTLY SUPPORTED') end
  return
 elseif stype == 'BARRELS' then
  if verbose then print('-type MISC:'..stype..' IS NOT CURRENTLY SUPPORTED') end
  return
 elseif stype == 'FLASKS' then
  if verbose then print('-type MISC:'..stype..' IS NOT CURRENTLY SUPPORTED') end
  return
 elseif stype == 'QUIVERS' then
  if verbose then print('-type MISC:'..stype..' IS NOT CURRENTLY SUPPORTED') end
  return
 elseif stype == 'BACKPACKS' then
  if verbose then print('-type MISC:'..stype..' IS NOT CURRENTLY SUPPORTED') end
  return
 elseif stype == 'CAGES' then
  if verbose then print('-type MISC:'..stype..' IS NOT CURRENTLY SUPPORTED') end
  return
 elseif stype == 'WOOD2' then
  if verbose then print('-type MISC:'..stype..' IS NOT CURRENTLY SUPPORTED') end
  return
 elseif stype == 'ROCK_METAL' then
  if verbose then print('-type MISC:'..stype..' IS NOT CURRENTLY SUPPORTED') end
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
  if verbose then print('Not a valid type') end
  return
 end
 if mobj == 'ALL' then
  if direction == -1 then
   for i=#misc.mat_type-1,0,-1 do
    misc.mat_type:erase(i)
   end
   for i=#misc.mat_index-1,0,-1 do
    misc.mat_index:erase(i)
   end
  elseif direction == 1 then
   if verbose then print('ALL:ALL IS NOT CURRENTLY SUPPORTED') end
   return
  end
 else
  mat_type = dfhack.matinfo.find(mobj..':'..sobj).type
  mat_index = dfhack.matinfo.find(mobj..':'..sobj).index
  if dfhack.matinfo.decode(mat_type,mat_index).material.flags[check] then
   if direction == -1 then
    for i=#refuse.mat_type-1,0,-1 do
     if misc.mat_type[i] == mat_type then
      if misc.mat_index[i] == mat_index then
       misc.mat_type:erase(i)
       misc.mat_index:erase(i)
       if verbose then print('Removing misc '..stype..' TYPE:SUBTYPE '..mat_type..':'..mat_index) end
      end
     end
    end
   elseif direction == 1 then
    misc.mat_type:insert('#',mat_type)
    misc.mat_index:insert('#',mat_index)
    if verbose then print('Adding misc '..stype..' TYPE:SUBTYPE '..mat_type..':'..mat_index) end
   end
  else
   if verbose then print('Material not valid ['..check..'] material') end
  end
 end

end

function changeNoble(entity,position,direction,verbose)
 if tonumber(entity) then
  civid = tonumber(entity)
  civ = df.global.world.entities.all[civid]
 else
  civ = entity
  civid = entity.id
 end
 positions = civ.positions

 if direction == -1 then
  for i,x in pairs(positions.own) do
   if position == x.code then
    positions.own:erase(i)
   end
  end
  for i,x in pairs(positions.site) do
   if position == x.code then
    positions.site:erase(i)
   end
  end
  for i,x in pairs(positions.conquered_site) do
   if position == x.code then
    positions.conquered_site:erase(i)
   end
  end
 elseif direction == 1 then
  local persistTable = require 'persist-table'
  entity = civ.entity_raw.code
  civilizationTable = persistTable.GlobalTable.roses.CivilizationTable[entity]
  if civilizationTable then
   if civilizationTable.Nobles then
    if civilizationTable.Nobles[position] then
     positionTable = civilizationTable.Nobles[position]
     pos = df['entity_position']:new()
     pos.code = position
     pos.id = positions.next_position_id
     positions.next_position_id = positions.next_position_id + 1
     for _,creature in pairs(positionTable.AllowedCreature._children) do
       local caste = positionTable.AllowedCreature[creature]
       for _,w in pairs(df.global.world.raws.creatures.all) do
        if creature == w.creature_id then
         for _,v in pairs(w.caste) do
          if caste == v.caste_id then
           pos.allowed_creature:insert('#',v.index)
          end
         end
        end
       end
      end
      for _,creature in pairs(positionTable.RejectedCreature._children) do
       local caste = positionTable.RejectedCreature[creature]
       for _,w in pairs(df.global.world.raws.creatures.all) do
        if creature == w.creature_id then
         for _,v in pairs(w.caste) do
          if caste == v.caste_id then
           pos.rejected_creature:insert('#',v.index)
          end
         end
        end
       end
      end
      for _,k in pairs(positionTable.AllowedClass._children) do
       local class = positionTable.AllowedClass[k]
       pos.allowed_class:insert('#',class)
      end
      for _,k in pairs(positionTable.RejectedClass._children) do
       local class = positionTable.RejectedClass[k]
       pos.rejected_class:insert('#',class)
      end
      if positionTable.Name then
       pos.name[0] = split(positionTable.Name,':')[1]
       pos.name[1] = split(positionTable.Name,':')[2]
       pos.name_female[0] = ''
       pos.name_female[1] = ''
       pos.name_male[0] = ''
       pos.name_male[1] = ''
      else
       pos.name[0] = ''
       pos.name[1] = ''
       pos.name_female[0] = ''
       pos.name_female[1] = ''
       pos.name_male[0] = ''
       pos.name_male[1] = ''
      end
      if positionTable.NameFemale then
       pos.name_female[0] = split(positionTable.NameFemale,':')[1]
       pos.name_female[1] = split(positionTable.NameFemale,':')[2]
      end
      if positionTable.NameMale then
       pos.name_male[0] = split(positionTable.NameMale,':')[1]
       pos.name_male[1] = split(positionTable.NameMale,':')[2]
      end
      if positionTable.Spouse then
       pos.spouse[0] = split(positionTable.Spouse,':')[1]
       pos.spouse[1] = split(positionTable.Spouse,':')[2]
       pos.spouse_female[0] = ''
       pos.spouse_female[1] = ''
       pos.spouse_male[0] = ''
       pos.spouse_male[1] = ''
      else
       pos.spouse[0] = ''
       pos.spouse[1] = ''
       pos.spouse_female[0] = ''
       pos.spouse_female[1] = ''
       pos.spouse_male[0] = ''
       pos.spouse_male[1] = ''
      end
      if positionTable.SpouseFemale then
       pos.spouse_female[0] = split(y['SpouseFemale'],':')[1]
       pos.spouse_female[1] = split(y['SpouseFemale'],':')[2]
      end
      if positionTable.SpouseMale then
       pos.spouse_male[0] = split(positionTable.SpouseMale,':')[1]
       pos.spouse_male[1] = split(positionTable.SpouseMale,':')[2]
      end
      if positionTable.Squad then
       pos.squad_size = tonumber(split(positionTable.Squad,':')[1])
       pos.squad[0] = split(positionTable.Squad,':')[2]
       pos.squad[1] = split(positionTable.Squad,':')[3]
      else
       pos.squad[0] = ''
       pos.squad[1] = ''
       pos.squad_size = 0
      end
      if positionTable.LandName then
       pos.land_name = positionTable.LandName
      else
       pos.land_name = ''
      end
      if positionTable.LandHolder then
       pos.land_holder = tonumber(positionTable.LandHolder)
      else
       pos.land_holder = 0
      end
      if positionTable.RequiredBoxes then
       pos.required_boxes = tonumber(positionTable.RequiredBoxes)
      else
       pos.required_boxes = 0
      end
      if positionTable.RequiredCabinets then
       pos.required_cabinets = tonumber(positionTable.RequiredCabinets)
      else
       pos.required_cabinets = 0
      end
      if positionTable.RequiredRacks then
       pos.required_racks = tonumber(positionTable.RequiredRacks)
      else
       pos.required_racks = 0
      end
      if positionTable.RequiredStands then
       pos.required_stands = tonumber(positionTable.RequiredStands)
      else
       pos.required_stands = 0
      end
      if positionTable.RequiredOffice then
       pos.required_office = tonumber(positionTable.RequiredOffice)
      else
       pos.required_office = 0
      end
      if positionTable.RequiredBedroom then
       pos.required_bedroom = tonumber(positionTable.RequiredBedroom)
      else
       pos.required_bedroom = 0
      end
      if positionTable.RequiredDining then
       pos.required_dining = tonumber(positionTable.RequiredDining)
      else
       pos.required_dining = 0
      end
      if positionTable.RequiredTomb then
       pos.required_tomb = tonumber(positionTable.RequiredTomb)
      else
       pos.required_tomb = 0
      end
      if positionTable.MandateMax then
       pos.mandate_max = tonumber(positionTable.MandateMax)
      else
       pos.mandate_max = 0
      end
      if positionTable.DemandMax then
       pos.demand_max = tonumber(positionTable.DemandMax)
      else
       pos.demand_max = 0
      end
      if positionTable.Color then
       pos.color[0] = split(positionTable.Color,':')[1]
       pos.color[1] = split(positionTable.Color,':')[2]
       pos.color[2] = split(positionTable.Color,':')[3]
      else
       pos.color[0] = 5
       pos.color[1] = 0
       pos.color[2] = 0
      end
      if positionTable.Precedence then
       pos.precedence = tonumber(positionTable.Precedence)
      else
       pos.precedence = -1
      end
      for v,w in pairs(pos.responsibilities) do
       if positionTable.Responsibility[v] then
        pos.responsibilities[v] = true
       else
        pos.responsibilities[v] = false
       end
      end
      for v,w in pairs(pos.flags) do
       if positionTable[v] then
        pos.flags[v] = true
       else
        pos.flags[v] = false
       end
      end
      if positionTable.Flags then
       for _,v in pairs(positionTable.Flags._children) do
        local w = positionTable.Flags[v]
        if pos.flags[v] then pos.flags[v] = true end
       end
      end
      if positionTable.Number then
       pos.number = tonumber(positionTable.Number)
      else
       pos.number = -1
      end
      for _,v in pairs(positionTable.AppointedBy._children) do
       p = -1
       own = false
       site = false
       for s,t in pairs(positions.own) do
        if v == t.code then
         p = t.id
         own = true
         break
        end
       end
       if p == -1 then
        for s,t in pairs(positions.site) do
         if v == t.code then
          p = t.id
          site = true
          break
         end
        end
       end
       if p == -1 then
        for s,t in pairs(positions.conquered_site) do
         if v == t.code then
          p = t.id
          break
         end
        end
       end
       if p == -1 then
        print('No valid APPOINTED_BY position found')
       else
        pos.appointed_by:insert('#',p)
        if own then pos.appointed_by_civ:insert('#',civid) end
        if site then pos.appointed_by_civ:insert('#',-1) end
       end
      end
      if positionTable.Commander then
       v = split(positionTable.Commander,':')[1]
       p = -1
       own = false
       site = false
       for s,t in pairs(positions.own) do
        if v == t.code then
         p = t.id
         own = true
         break
        end
       end
       if p == -1 then
        for s,t in pairs(positions.site) do
         if v == t.code then
          p = t.id
          site = true
          break
         end
        end
       end
       if p == -1 then
        for s,t in pairs(positions.conquered_site) do
         if v == t.code then
          p = t.id
          break
         end
        end
       end
       if p == -1 then
        print('No valid COMMANDER position found')
       else
        pos.commander_id:insert('#',p)
        pos.commander_types:insert('#',0)
        if own then pos.commander_civ:insert('#',civid) end
        if site then pos.commander_civ:insert('#',-1) end
       end
      end
      if positionTable.ReplacedBy then
       v = positionTable.ReplacedBy
       p = -1
       own = false
       site = false
       for s,t in pairs(positions.own) do
        if v == t.code then
         p = t.id
         own = true
         break
        end
       end
       if p == -1 then
        for s,t in pairs(positions.site) do
         if v == t.code then
          p = t.id
          site = true
          break
         end
        end
       end
       if p == -1 then
        for s,t in pairs(positions.conquered_site) do
         if v == t.code then
          p = t.id
          break
         end
        end
       end
       if p == -1 then
        print('No valid REPLACED_BY position found')
       else
        pos.replaced_by = p
       end
      else
       pos.replaced_by = -1
      end
      positions.own:insert('#',pos)
     else
      print('No valid position found in civilization.txt')
      return
     end
    end
   end
  end
end

function changeOrganic(entity,stype,mobj,sobj,direction,verbose)
 stype = string.upper(stype)
 mobj = string.upper(mobj)
 sobj = string.upper(sobj)

 if tonumber(entity) then
  civid = tonumber(entity)
  civ = df.global.world.entities.all[civid]
 else
  civ = entity
 end
 resources = civ.resources

 if stype == 'ALL' then
  if verbose then print('-type ORGANIC:ALL IS NOT CURRENTLY SUPPORTED') end
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
  if verbose then print('Not a valid type') end
  return
 end
 if mobj == 'ALL' then
  if direction == -1 then
   for i=#organic.mat_type-1,0,-1 do
    organic.mat_type:erase(i)
   end
   for i=#organic.mat_index-1,0,-1 do
    organic.mat_index:erase(i)
   end
  elseif direction == 1 then
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
   if direction == -1 then
    for i=#organic.mat_type-1,0,-1 do
     if organic.mat_type[i] == mat_type then
      if organic.mat_index[i] == mat_index then
       organic.mat_type:erase(i)
       organic.mat_index:erase(i)
       if verbose then print('Removing organic '..stype..' TYPE:SUBTYPE '..mat_type..':'..mat_index) end
      end
     end
    end
   elseif direction == 1 then
    organic.mat_type:insert('#',mat_type)
    organic.mat_index:insert('#',mat_index)
    if verbose then print('Adding organic '..stype..' TYPE:SUBTYPE '..mat_type..':'..mat_index) end
   end
  else
   if verbose then print('Material not valid ['..check..'] material') end
  end
 end
end

function changeRefuse(entity,stype,mobj,sobj,direction,verbose)
 stype = string.upper(stype)
 mobj = string.upper(mobj)
 sobj = string.upper(sobj)

 if tonumber(entity) then
  civid = tonumber(entity)
  civ = df.global.world.entities.all[civid]
 else
  civ = entity
 end
 resources = civ.resources

 if stype == 'ALL' then
  if verbose then print('-type REFUSE:ALL IS NOT CURRENTLY SUPPORTED') end
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
  if verbose then print('Not a valid type') end
  return
 end
 if mobj == 'ALL' then
  if direction == -1 then
   for i=#refuse.mat_type-1,0,-1 do
    refuse.mat_type:erase(i)
   end
   for i=#refuse.mat_index-1,0,-1 do
    refuse.mat_index:erase(i)
   end
  elseif direction == 1 then
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
   if direction == -1 then
    for i=#refuse.mat_type-1,0,-1 do
     if refuse.mat_type[i] == mat_type then
      if refuse.mat_index[i] == mat_index then
       refuse.mat_type:erase(i)
       refuse.mat_index:erase(i)
       if verbose then print('Removing refuse '..stype..' TYPE:SUBTYPE '..mat_type..':'..mat_index) end
      end
     end
    end
   elseif direction == 1 then
    refuse.mat_type:insert('#',mat_type)
    refuse.mat_index:insert('#',mat_index)
    if verbose then print('Adding refuse '..stype..' TYPE:SUBTYPE '..mat_type..':'..mat_index) end
   end
  else
   if verbose then print('Material not valid ['..check..'] material') end
  end
 end
end

function changeResources(entity,mtype,stype,mobj,sobj,direction,verbose)
 if string.upper(mtype) == 'CREATURE' then
  changeCreature(entity,stype,mobj,sobj,direction,verbose)
 elseif string.upper(mtype) == 'INORGANIC' then
  changeInorganic(entity,stype,mobj,sobj,direction,verbose)
 elseif string.upper(mtype) == 'ITEM' then
  changeItem(entity,stype,mobj,sobj,direction,verbose)
 elseif string.upper(mtype) == 'MISC' then
  changeMisc(entity,stype,mobj,sobj,direction,verbose)
 elseif string.upper(mtype) == 'ORGANIC' then
  changeOrganic(entity,stype,mobj,sobj,direction,verbose)
 elseif string.upper(mtype) == 'REFUSE' then
  changeRefuse(entity,stype,mobj,sobj,direction,verbose)
 else
  if verbose then print('No valid resource type to add') end
  return
 end
end