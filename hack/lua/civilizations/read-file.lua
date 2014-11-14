
local split = require('split')
local utils = require 'utils'

function read_file(path)
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
 civs = {}
 count = 1
 for i,x in ipairs(totdat) do
  if split(x,':')[1] == '[CIV' then
   d[count] = {split(split(x,':')[2],']')[1],i,0}
   count = count + 1
  end
 end
 for i,x in ipairs(d) do
  if i == #d then
   x[3] = #totdat
  else
   x[3] = d[i+1][2]-1
  end
  civs[x[1]]={}
 end
 for i,x in ipairs(d) do
  civs[x[1]]['LEVEL'] = {}
  for j = x[2]+1,x[3],1 do
   totdat[j] = totdat[j]:gsub("%s+","")
   if split(totdat[j],':')[1] == '[NAME' then   
    civs[x[1]]['NAME'] = split(split(totdat[j],':')[2],']')[1]
   elseif split(totdat[j],':')[1] == '[LEVELS' then 
    civs[x[1]]['LEVELS'] = tonumber(split(split(totdat[j],':')[2],']')[1])
   elseif split(totdat[j],':')[1] == '[LEVEL_METHOD' then 
    civs[x[1]]['METHOD'] = {split(totdat[j],':')[2],split(split(totdat[j],':')[3],']')[1]}
   elseif split(totdat[j],':')[1] == '[LEVEL' then 
	level = split(split(totdat[j],':')[2],']')[1]
    civs[x[1]]['LEVEL'][level] = {}
    civs[x[1]]['LEVEL'][level]['ETHIC'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE_POSITION'] = {}
    civs[x[1]]['LEVEL'][level]['ADD_POSITION'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['CREATURE'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['CREATURE']['ALL'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['CREATURE']['PET'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['CREATURE']['WAGON'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['CREATURE']['MOUNT'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['CREATURE']['PACK'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['CREATURE']['MINION'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['CREATURE']['EXOTIC'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['CREATURE']['FISH'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['CREATURE']['EGG'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['INORGANIC'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['INORGANIC']['ALL'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['INORGANIC']['METAL'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['INORGANIC']['STONE'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['INORGANIC']['GEM'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['ORGANIC'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['ORGANIC']['ALL'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['ORGANIC']['LEATHER'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['ORGANIC']['FIBER'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['ORGANIC']['SILK'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['ORGANIC']['WOOL'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['ORGANIC']['WOOD'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['ORGANIC']['PLANT'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['ORGANIC']['SEED'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['REFUSE'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['REFUSE']['ALL'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['REFUSE']['BONE'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['REFUSE']['SHELL'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['REFUSE']['PEARL'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['REFUSE']['IVORY'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['REFUSE']['HORN'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['ITEM'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['ITEM']['ALL'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['ITEM']['WEAPON'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['ITEM']['SHIELD'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['ITEM']['AMMO'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['ITEM']['HELM'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['ITEM']['ARMOR'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['ITEM']['PANTS'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['ITEM']['SHOES'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['ITEM']['GLOVES'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['ITEM']['TRAP'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['ITEM']['SIEGE'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['ITEM']['TOY'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['ITEM']['INSTRUMENT'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['ITEM']['TOOL'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['ITEM']['DIGGER'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['ITEM']['TRAINING'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['MISC'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['MISC']['ALL'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['MISC']['OTHER'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['MISC']['GLASS'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['MISC']['SAND'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['MISC']['CLAY'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['MISC']['CRAFTS'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['MISC']['GLASS_UNUSED'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['MISC']['BARRELS'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['MISC']['FLASKS'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['MISC']['QUIVERS'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['MISC']['BACKPACKS'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['MISC']['CAGES'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['MISC']['WOOD2'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['MISC']['ROCK_METAL'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['MISC']['BOOZE'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['MISC']['CHEESE'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['MISC']['POWDER'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['MISC']['EXTRACT'] = {}
    civs[x[1]]['LEVEL'][level]['REMOVE']['MISC']['MEAT'] = {}
    civs[x[1]]['LEVEL'][level]['ADD'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['CREATURE'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['CREATURE']['PET'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['CREATURE']['WAGON'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['CREATURE']['MOUNT'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['CREATURE']['PACK'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['CREATURE']['MINION'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['CREATURE']['EXOTIC'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['CREATURE']['FISH'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['CREATURE']['EGG'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['INORGANIC'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['INORGANIC']['METAL'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['INORGANIC']['STONE'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['INORGANIC']['GEM'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['ORGANIC'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['ORGANIC']['LEATHER'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['ORGANIC']['FIBER'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['ORGANIC']['SILK'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['ORGANIC']['WOOL'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['ORGANIC']['WOOD'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['ORGANIC']['PLANT'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['ORGANIC']['SEED'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['REFUSE'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['REFUSE']['BONE'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['REFUSE']['SHELL'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['REFUSE']['PEARL'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['REFUSE']['IVORY'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['REFUSE']['HORN'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['ITEM'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['ITEM']['WEAPON'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['ITEM']['SHIELD'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['ITEM']['AMMO'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['ITEM']['HELM'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['ITEM']['ARMOR'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['ITEM']['PANTS'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['ITEM']['SHOES'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['ITEM']['GLOVES'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['ITEM']['TRAP'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['ITEM']['SIEGE'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['ITEM']['TOY'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['ITEM']['INSTRUMENT'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['ITEM']['TOOL'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['ITEM']['DIGGER'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['ITEM']['TRAINING'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['MISC'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['MISC']['OTHER'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['MISC']['GLASS'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['MISC']['SAND'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['MISC']['CLAY'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['MISC']['CRAFTS'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['MISC']['GLASS_UNUSED'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['MISC']['BARRELS'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['MISC']['FLASKS'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['MISC']['QUIVERS'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['MISC']['BACKPACKS'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['MISC']['CAGES'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['MISC']['WOOD2'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['MISC']['ROCK_METAL'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['MISC']['BOOZE'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['MISC']['CHEESE'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['MISC']['POWDER'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['MISC']['EXTRACT'] = {}
    civs[x[1]]['LEVEL'][level]['ADD']['MISC']['MEAT'] = {}
   elseif split(totdat[j],':')[1] == '[LEVEL_NAME' then
    civs[x[1]]['LEVEL'][level]['NAME'] = split(split(totdat[j],':')[2],']')[1]
   elseif split(totdat[j],':')[1] == '[LEVEL_REMOVE' then
    if split(totdat[j],':')[2] == 'CREATURE' then
     civs[x[1]]['LEVEL'][level]['REMOVE']['CREATURE'][split(totdat[j],':')[3]][split(totdat[j],':')[4]] = split(split(totdat[j],':')[5],']')[1]
    elseif split(totdat[j],':')[2] == 'INORGANIC' then  
     civs[x[1]]['LEVEL'][level]['REMOVE']['INORGANIC'][split(totdat[j],':')[3]][split(split(totdat[j],':')[4],']')[1]] = split(split(totdat[j],':')[4],']')[1]
    elseif split(totdat[j],':')[2] == 'ORGANIC' then
     civs[x[1]]['LEVEL'][level]['REMOVE']['ORAGNIC'][split(totdat[j],':')[3]][split(totdat[j],':')[4][1]] = split(split(totdat[j],':')[5],']')[1]
    elseif split(totdat[j],':')[2] == 'REFUSE' then
     civs[x[1]]['LEVEL'][level]['REMOVE']['REFUSE'][split(totdat[j],':')[3]][split(split(totdat[j],':')[4],']')[1]] = split(split(totdat[j],':')[4],']')[1]
    elseif split(totdat[j],':')[2] == 'ITEM' then
     civs[x[1]]['LEVEL'][level]['REMOVE']['ITEM'][split(totdat[j],':')[3]][split(split(totdat[j],':')[4],']')[1]] = split(split(totdat[j],':')[4],']')[1]
    elseif split(totdat[j],':')[2] == 'MISC' then
     civs[x[1]]['LEVEL'][level]['REMOVE']['MISC'][split(totdat[j],':')[3]][split(split(totdat[j],':')[4],']')[1]] = split(split(totdat[j],':')[4],']')[1]
    end
   elseif split(totdat[j],':')[1] == '[LEVEL_ADD' then
    if split(totdat[j],':')[2] == 'CREATURE' then
     civs[x[1]]['LEVEL'][level]['ADD']['CREATURE'][split(totdat[j],':')[3]][split(totdat[j],':')[4]] = split(split(totdat[j],':')[5],']')[1]
    elseif split(totdat[j],':')[2] == 'INORGANIC' then  
     civs[x[1]]['LEVEL'][level]['ADD']['INORAGNIC'][split(totdat[j],':')[3]][split(split(totdat[j],':')[4],']')[1]] = split(split(totdat[j],':')[4],']')[1]
    elseif split(totdat[j],':')[2] == 'ORGANIC' then
     civs[x[1]]['LEVEL'][level]['ADD']['ORAGNIC'][split(totdat[j],':')[3]][split(split(totdat[j],':')[4],']')[1]] = split(split(totdat[j],':')[4],']')[1]
    elseif split(totdat[j],':')[2] == 'REFUSE' then
     civs[x[1]]['LEVEL'][level]['ADD']['REFUSE'][split(totdat[j],':')[3]][split(split(totdat[j],':')[4],']')[1]] = split(split(totdat[j],':')[4],']')[1]
    elseif split(totdat[j],':')[2] == 'ITEM' then
     civs[x[1]]['LEVEL'][level]['ADD']['ITEM'][split(totdat[j],':')[3]][split(split(totdat[j],':')[4],']')[1]] = split(split(totdat[j],':')[4],']')[1]
    elseif split(totdat[j],':')[2] == 'MISC' then
     civs[x[1]]['LEVEL'][level]['ADD']['MISC'][split(totdat[j],':')[3]][split(split(totdat[j],':')[4],']')[1]] = split(split(totdat[j],':')[4],']')[1]  
    end
   elseif split(totdat[j],':')[1] == '[LEVEL_CHANGE_ETHIC' then
    civs[x[1]]['LEVEL'][level]['ETHIC'][split(totdat[j],':')[2]] = split(split(totdat[j],':')[3],']')[1]
   elseif split(totdat[j],':')[1] == '[LEVEL_CHANGE_METHOD' then
    civs[x[1]]['LEVEL'][level]['METHOD']= {split(totdat[j],':')[2],split(split(totdat[j],':')[3],']')[1]}
   elseif split(totdat[j],':')[1] == '[LEVEL_REMOVE_POSITION' then
    civs[x[1]]['LEVEL'][level]['REMOVE_POSITION'][split(split(totdat[j],':')[2],']')[1]] = split(split(totdat[j],':')[2],']')[1]
   elseif split(totdat[j],':')[1] == '[LEVEL_ADD_POSITION' then
    position = split(split(totdat[j],':')[2],']')[1]
    civs[x[1]]['LEVEL'][level]['ADD_POSITION'][position] = {}
    civs[x[1]]['LEVEL'][level]['ADD_POSITION'][position]['ALLOWED_CREATURE'] = {}
    civs[x[1]]['LEVEL'][level]['ADD_POSITION'][position]['ALLOWED_CLASS'] = {}
    civs[x[1]]['LEVEL'][level]['ADD_POSITION'][position]['REJECTED_CREATURE'] = {}
    civs[x[1]]['LEVEL'][level]['ADD_POSITION'][position]['REJECTED_CLASS'] = {}
    civs[x[1]]['LEVEL'][level]['ADD_POSITION'][position]['RESPONSIBILITY'] = {}
    civs[x[1]]['LEVEL'][level]['ADD_POSITION'][position]['APPOINTED_BY'] = {}
    civs[x[1]]['LEVEL'][level]['ADD_POSITION'][position]['FLAGS'] = {}
   elseif split(totdat[j],':')[1] == '[ALLOWED_CREATURE' then
    print(position)
    printall(split(totdat[j-1],':'))
    printall(split(totdat[j],':'))
    printall(civs[x[1]]['LEVEL'][level])
    printall(civs[x[1]]['LEVEL'][level]['ADD_POSITION'])
    printall(civs[x[1]]['LEVEL'][level]['ADD_POSITION'][position])
    civs[x[1]]['LEVEL'][level]['ADD_POSITION'][position]['ALLOWED_CREATURE'][split(totdat[j],':')[2]] = split(split(totdat[j],':')[3],']')[1]
   elseif split(totdat[j],':')[1] == '[REJECTED_CREATURE' then
    civs[x[1]]['LEVEL'][level]['ADD_POSITION'][position]['REJECTED_CREATURE'][split(totdat[j],':')[2]] = split(split(totdat[j],':')[3],']')[1]
   elseif split(totdat[j],':')[1] == '[ALLOWED_CLASS' then
    civs[x[1]]['LEVEL'][level]['ADD_POSITION'][position]['ALLOWED_CLASS'][split(split(totdat[j],':')[2],']')[1]] = split(split(totdat[j],':')[2],']')[1]
   elseif split(totdat[j],':')[1] == '[REJECTED_CLASS' then
    civs[x[1]]['LEVEL'][level]['ADD_POSITION'][position]['REJECTED_CLASS'][split(split(totdat[j],':')[2],']')[1]] = split(split(totdat[j],':')[2],']')[1]
   elseif split(totdat[j],':')[1] == '[NAME' then
    civs[x[1]]['LEVEL'][level]['ADD_POSITION'][position]['NAME'] = split(totdat[j],':')[2]..':'..split(split(totdat[j],':')[3],']')[1]
   elseif split(totdat[j],':')[1] == '[NAME_MALE' then
    civs[x[1]]['LEVEL'][level]['ADD_POSITION'][position]['NAME_MALE'] = split(totdat[j],':')[2]..':'..split(split(totdat[j],':')[3],']')[1]
   elseif split(totdat[j],':')[1] == '[NAME_FEMALE' then
    civs[x[1]]['LEVEL'][level]['ADD_POSITION'][position]['NAME_FEMALE'] = split(totdat[j],':')[2]..':'..split(split(totdat[j],':')[3],']')[1]
   elseif split(totdat[j],':')[1] == '[SPOUSE' then
    civs[x[1]]['LEVEL'][level]['ADD_POSITION'][position]['SPOUSE'] = split(totdat[j],':')[2]..':'..split(split(totdat[j],':')[3],']')[1]
   elseif split(totdat[j],':')[1] == '[SPOUSE_MALE' then
    civs[x[1]]['LEVEL'][level]['ADD_POSITION'][position]['SPOUSE_MALE'] = split(totdat[j],':')[2]..':'..split(split(totdat[j],':')[3],']')[1]
   elseif split(totdat[j],':')[1] == '[SPOUSE_FEMALE' then
    civs[x[1]]['LEVEL'][level]['ADD_POSITION'][position]['SPOUSE_FEMALE'] = split(totdat[j],':')[2]..':'..split(split(totdat[j],':')[3],']')[1]
   elseif split(totdat[j],':')[1] == '[NUMBER' then
    civs[x[1]]['LEVEL'][level]['ADD_POSITION'][position]['NUMBER'] = split(split(totdat[j],':')[2],']')[1]
   elseif split(totdat[j],':')[1] == '[SUCCESSION' then
    civs[x[1]]['LEVEL'][level]['ADD_POSITION'][position]['SUCCESSION'] = split(split(totdat[j],':')[2],']')[1]
   elseif split(totdat[j],':')[1] == '[LAND_HOLDER' then
    civs[x[1]]['LEVEL'][level]['ADD_POSITION'][position]['LAND_HOLDER'] = split(split(totdat[j],':')[2],']')[1]
   elseif split(totdat[j],':')[1] == '[LAND_NAME' then
    civs[x[1]]['LEVEL'][level]['ADD_POSITION'][position]['LAND_NAME'] = split(split(totdat[j],':')[2],']')[1]
   elseif split(totdat[j],':')[1] == '[APPOINTED_BY' then
    civs[x[1]]['LEVEL'][level]['ADD_POSITION'][position]['APPOINTED_BY'][split(split(totdat[j],':')[2],']')[1]] = split(split(totdat[j],':')[2],']')[1]
   elseif split(totdat[j],':')[1] == '[REPLACED_BY' then
    civs[x[1]]['LEVEL'][level]['ADD_POSITION'][position]['REPLACED_BY'] = split(split(totdat[j],':')[2],']')[1]
   elseif split(totdat[j],':')[1] == '[RESPONIBILITY' then
    civs[x[1]]['LEVEL'][level]['ADD_POSITION'][position]['RESPONSIBILITY'][split(split(totdat[j],':')[2],']')[1]] = split(split(totdat[j],':')[2],']')[1]
   elseif split(totdat[j],':')[1] == '[PRECEDENCE' then
    civs[x[1]]['LEVEL'][level]['ADD_POSITION'][position]['PRECEDENCE'] = split(split(totdat[j],':')[2],']')[1]
   elseif split(totdat[j],':')[1] == '[REQUIRES_POPULATION' then
    civs[x[1]]['LEVEL'][level]['ADD_POSITION'][position]['REQUIRES_POPULATION'] = split(split(totdat[j],':')[2],']')[1]
   elseif split(totdat[j],':')[1] == '[REQUIRED_BOXES' then
    civs[x[1]]['LEVEL'][level]['ADD_POSITION'][position]['REQUIRED_BOXES'] = split(split(totdat[j],':')[2],']')[1]
   elseif split(totdat[j],':')[1] == '[REQUIRED_CABINETS' then
    civs[x[1]]['LEVEL'][level]['ADD_POSITION'][position]['REQUIRED_CABINETS'] = split(split(totdat[j],':')[2],']')[1]
   elseif split(totdat[j],':')[1] == '[REQUIRED_RACKS' then
    civs[x[1]]['LEVEL'][level]['ADD_POSITION'][position]['REQUIRED_RACKS'] = split(split(totdat[j],':')[2],']')[1]
   elseif split(totdat[j],':')[1] == '[REQUIRED_STANDS' then
    civs[x[1]]['LEVEL'][level]['ADD_POSITION'][position]['REQUIRED_STANDS'] = split(split(totdat[j],':')[2],']')[1]
   elseif split(totdat[j],':')[1] == '[REQUIRED_OFFICE' then
    civs[x[1]]['LEVEL'][level]['ADD_POSITION'][position]['REQUIRED_OFFICE'] = split(split(totdat[j],':')[2],']')[1]
   elseif split(totdat[j],':')[1] == '[REQUIRED_BEDROOM' then
    civs[x[1]]['LEVEL'][level]['ADD_POSITION'][position]['REQUIRED_BEDROOM'] = split(split(totdat[j],':')[2],']')[1]
   elseif split(totdat[j],':')[1] == '[REQUIRED_DINING' then
    civs[x[1]]['LEVEL'][level]['ADD_POSITION'][position]['REQUIRED_DINING'] = split(split(totdat[j],':')[2],']')[1]
   elseif split(totdat[j],':')[1] == '[REQUIRED_TOMB' then
    civs[x[1]]['LEVEL'][level]['ADD_POSITION'][position]['REQUIRED_TOMB'] = split(split(totdat[j],':')[2],']')[1]
   elseif split(totdat[j],':')[1] == '[MANDATE_MAX' then
    civs[x[1]]['LEVEL'][level]['ADD_POSITION'][position]['MANDATE_MAX'] = split(split(totdat[j],':')[2],']')[1]
   elseif split(totdat[j],':')[1] == '[DEMAND_MAX' then
    civs[x[1]]['LEVEL'][level]['ADD_POSITION'][position]['DEMAND_MAX'] = split(split(totdat[j],':')[2],']')[1]
   elseif split(totdat[j],':')[1] == '[COLOR' then
    civs[x[1]]['LEVEL'][level]['ADD_POSITION'][position]['COLOR'] = split(totdat[j],':')[2]..':'..split(totdat[j],':')[3]..':'..split(split(totdat[j],':')[4],']')[1]
   elseif split(totdat[j],':')[1] == '[SQUAD' then
    civs[x[1]]['LEVEL'][level]['ADD_POSITION'][position]['SQUAD'] = split(totdat[j],':')[2]..':'..split(totdat[j],':')[3]..':'..split(split(totdat[j],':')[4],']')[1]
   elseif split(totdat[j],':')[1] == '[COMMANDER' then
    civs[x[1]]['LEVEL'][level]['ADD_POSITION'][position]['COMMANDER'] = split(totdat[j],':')[2]..':'..split(split(totdat[j],':')[3],']')[1]
   elseif split(totdat[j],':')[1] == '[FLAGS' then
    civs[x[1]]['LEVEL'][level]['ADD_POSITION'][position]['FLAGS'][split(split(totdat[j],':')[2],']')[1]] = true
   else
    if position then civs[x[1]]['LEVEL'][level]['ADD_POSITION'][position][split(split(totdat[j],']')[1],'%[')[1]] = true end
   end
  end
 end
 return civs
end

return read_file