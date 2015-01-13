--item/create.lua v1.0

local split = require('split')
local utils = require 'utils'

function createcallback(item)
 return function (deleteitem)
  dfhack.items.remove(item)
 end
end
function createitem(unit,mat,location,dur,itemtype)
 local mat_type = dfhack.matinfo.find(mat).type
 local mat_index = dfhack.matinfo.find(mat).index
 local t = split(itemtype,':')[1]
 if t == 'WEAPON' then v = 'item_weaponst' end
 if t == 'ARMOR' then v = 'item_armorst' end
 if t == 'HELM' then v = 'item_helmst' end
 if t == 'SHOES' then v = 'item_shoesst' end
 if t == 'SHIELD' then v = 'item_shieldst' end
 if t == 'GLOVE' then v = 'item_glovest' end
 if t == 'PANTS' then v = 'item_pantsst' end
 if t == 'AMMO' then v = 'item_ammost' end

 local item_index = df.item_type[t]
 local item_subtype = 'nil'

 for i=0,dfhack.items.getSubtypeCount(item_index)-1 do
   local item_sub = dfhack.items.getSubtypeDef(item_index,i)
   if item_sub.id == split(itemtype,':')[2] then
    item_subtype = item_sub.subtype
  end
end

if item_subtype == 'nil' then
 print("No item of that type found")
 return
end

local item=df[v]:new() --incredible
item.id=df.global.item_next_id
df.global.world.items.all:insert('#',item)
df.global.item_next_id=df.global.item_next_id+1
item:setSubtype(item_subtype)
item:setMaterial(mat_type)
item:setMaterialIndex(mat_index)
item:categorize(true)
item.flags.removed=true
if t == 'WEAPON' then item:setSharpness(1,0) end
item:setQuality(0)
if location == 'ground' then dfhack.items.moveToGround(item,{x=unit.pos.x,y=unit.pos.y,z=unit.pos.z}) end
if location == 'inventory' then
 local umode = 0
 local bpart = 0
 dfhack.items.moveToInventory(item,unit,umode,bpart) 
end
if dur ~= 0 then dfhack.timeout(dur,'ticks',createcallback(item)) end
end

validArgs = validArgs or utils.invert({
 'help',
 'unit',
 'item',
 'mat',
 'dur',
 'ground',
 'inventory',
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
 print([[create.lua
  Create an equipable item
  arguments:
   -help
     print this help message
   -unit id
     REQUIRED
     id of the target unit
   -item TYPE:SUBTYPE
     REQUIRED
     type and subtype of item to create
     examples:
      WEAPON:ITEM_WEAPON_DAGGER
      AMMO:ITEM_AMMO_BOLTS
      HELM:ITEM_HELM_CAP
   -mat INORGANIC_TOKEN
     REQUIRED
     material to make the item from
     examples:
      STEEL
      GRANITE
      RUBY
   -dur #
     length of time, in in-game ticks, for the item to last
     0 means the item is permanent
     DEFAULT: 0
   -ground                                   \
     place item at feet of the unit          |
   -inventory                                | Must have one and only one of these
     place item in the inventory of the unit /
  examples:
   item-create -unit \\UNIT_ID -item WEAPON:ITEM_WEAPON_PICK -mat BRONZE -inventory -dur 1000
   item-create -unit \\UNIT_ID -item HELM:ITEM_HELM_HELM -mat STEEL -ground
 ]])
 return
end

if args.unit and tonumber(args.unit) then -- Check for unit declaration !REQUIRED!
 unit = df.unit.find(tonumber(args.unit))
else
 print('No unit selected')
 return
end
if args.mat then -- Check for material !REQUIRED!
 mat = args.mat
else
 print('No material specified')
 return
end
if args.item then -- Check for item !REQUIRED!
 itemtype = args.item
else
 print('No item specified')
 return
end
if args.ground then -- Check for item placement location (default -ground)
 loc = 'ground'
elseif args.inventory then
 loc = 'inventory'
else
 loc = 'ground'
end
dur = tonumber(args.dur) or 0 -- Specify duration of change (default 0)

createitem(unit,mat,loc,dur,itemtype)
