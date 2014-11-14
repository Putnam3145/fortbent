--item/imbue.lua v1.0
local split = require('split')
local utils = require 'utils'

function createcallback(item,stype,sindex)
 return function (resetweapon)
  item.mat_type = stype
  item.mat_index = sindex
 end
end
function imbue(v,mat,dur)
 local mat_type = dfhack.matinfo.find(mat).type
 local mat_index = dfhack.matinfo.find(mat).index

 local inv = unit.inventory
 local items = {}
 local j = 1
 for i = 0, #inv - 1, 1 do
  if v:is_instance(inv[i].item) then
   items[j] = i
   j = j+1
  end
 end

 if #items == 0 then 
  print('No necessary item equiped')
  return
 end

 for i,x in ipairs(items) do
  local sitem = inv[x].item
  local stype = sitem.mat_type
  local sindex = sitem.mat_index
  sitem.mat_type = mat_type
  sitem.mat_index = mat_index

  if dur ~= 0 then
   dfhack.timeout(dur,'ticks',createcallback(sitem,stype,sindex))
  end
 end
end

validArgs = validArgs or utils.invert({
 'help',
 'unit',
 'weapon',
 'armor',
 'helm',
 'shoes',
 'shield',
 'gloves',
 'pants',
 'ammo',
 'mat',
 'dur',
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
 print([[imbue.lua
  Change the material a equipped item is made out of
  arguments:
   -help
     print this help message
   -unit id
     REQUIRED
     id of the target unit
   -weapon          \
     change weapons |
   -armor           |
     change armor   |
   -helm            |
     change helm    |
   -shoes           |
     change shoes   | Must have at least one of these arguments
   -shield          |
     change shield  | 
   -gloves          |
     change gloves  |
   -pants           |
     change pants   | 
   -ammo            |
     change ammo    /
   -mat INORGANIC_TOKEN
     REQUIRED
     material to change the item to
     examples:
      STEEL
      GRANITE
      RUBY
   -dur #
     length of time, in in-game ticks, for the material change to last
     0 means the change is permanent
     DEFAULT: 0
  examples:
   item-imbue -unit \\UNIT_ID -weapon -ammo -mat IMBUE_FIRE -dur 3600
   item-imbue -unit \\UNIT_ID -armor -helm -shoes -pants -gloves -mat IMBUE_STONE -dur 1000
   item-imbue -unit \\UNIT_ID -shield -mat IMBUE_AIR
 ]])
 return
end

if args.unit and tonumber(args.unit) then -- Check for unit declaration !REQUIRED
 unit = df.unit.find(tonumber(args.unit))
else
 print('No unit selected')
 return
end
if args.mat then -- Check for material !REQUIRED
 mat = args.mat
else
 print('No material specified')
 return
end
dur = tonumber(args.dur) or 0 -- Specify duration of change (default 0)
if args.weapon then imbue(df.item_weaponst,mat,dur) end
if args.armor then imbue(df.item_armorst,mat,dur) end
if args.helm then imbue(df.item_helmst,mat,dur) end
if args.shoes then imbue(df.item_shoesst,mat,dur) end
if args.shield then imbue(df.item_shieldst,mat,dur) end
if args.gloves then imbue(df.item_glovest,mat,dur) end
if args.pants then imbue(df.item_pantsst,mat,dur) end
if args.ammo then imbue(df.item_ammost,mat,dur) end

