--special-fallingitems.lua v1.0

local split = require('split')
local utils = require 'utils'

validArgs = validArgs or utils.invert({
 'help',
 'unit',
 'location',
 'mat',
 'item',
 'number',
 'height',
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
 print([[special-fallingitems.lua
  Creates an item that falls from the sky and can inflict damage
  arguments:
   -help
     print this help message
   -unit id                                \
     id of the unit to use for position    |
   -location [#,#,#]                       | Must have one and only one of these arguments, if both, ignore -location
     x,y,z coordinates to use for position /
   -item TYPE:SUBTYPE
     REQUIRED
     item to fall from sky (only BOULDER, AMMO, and WEAPON supported)
     examples:
      BOULDER
      AMMO:ITEM_AMMO_BOLTS
      WEAPON:ITEM_WEAPON_SPEAR
   -mat INORGANIC_TOKEN
     REQUIRED
     material to make the item from
     examples:
      STEEL
      GRANITE
      RUBY
   -number #
     number of items to fall from the sky
     DEFAULT 1
   -height #
     height above chosen position (unit or location) to drop the items from
     DEFAULT 1
  examples:
   special-fallingitems -unit \\UNIT_ID -item AMMO:ITEM_AMMO_ARROWS -mat STEEL -number 10 -height 20
   special-fallingitems -location [\\LOCATION] -item BOULDER -mat SLADE -height 10
 ]])
 return
end

if args.unit and args.location then -- Check that unit and location sources have not been both specified
 print("Can't have unit and location specified as source at same time")
 args.location = nil
end

if args.unit then -- Check for source declaration !REQUIRED
 locSource = df.unit.find(tonumber(args.unit)).pos
elseif args.location then
 locSource = {x=args.location[1],y=args.location[2],z=args.location[3]}
else
 print('No source specified')
end
if args.item then -- Check for item !REQUIRED
 object = args.item
else
 print('No item specified')
 return
end
if args.mat then -- Check for material !REQUIRED
 mat = args.mat
else
 print('No material specified')
 return
end
number = tonumber(args.number) or 1 -- Specify number of falling projectiles (default 1)
height = tonumber(args.height) or 1 -- Specify height of falling projectiles (default 1)

mat_type = dfhack.matinfo.find(mat).type
mat_index = dfhack.matinfo.find(mat).index

for i = 1, number, 1 do
 if split(object,':')[1] == 'BOULDER' then
  item_index = df.item_type['BOULDER']
  item_subtype = -1
  item=df['item_boulderst']:new()
 elseif split(object,':')[1] == 'AMMO' then
  item_index = df.item_type['AMMO']
  item_subtype = -1
  for i=0,dfhack.items.getSubtypeCount(item_index)-1,1 do
   item_sub = dfhack.items.getSubtypeDef(item_index,i)
   if item_sub.id == split(object,':')[2] then item_subtype = item_sub.subtype end
  end
  if item_subtype == 'nil' then
   print("No item of that type found")
   return
  end
  item=df['item_ammost']:new()
 elseif split(object,';')[1] == 'WEAPON' then
  item_index = df.item_type['WEAPON']
  item_subtype = -1
  for i=0,dfhack.items.getSubtypeCount(item_index)-1,1 do
   item_sub = dfhack.items.getSubtypeDef(item_index,i)
   if item_sub.id == split(object,':')[2] then item_subtype = item_sub.subtype end
  end
  item=df['item_weaponst']:new()
 end

 item.id=df.global.item_next_id
 df.global.world.items.all:insert('#',item)
 df.global.item_next_id=df.global.item_next_id+1
 if object ~= 'BOULDER' then item:setSubtype(item_subtype) end
 item:setMaterial(mat_type)
 item:setMaterialIndex(mat_index)
 item:categorize(true)
 pos = {}
 block = dfhack.maps.ensureTileBlock(locSource.x,locSource.y,locSource.z+height)
 pos.x = locSource.x
 pos.y = locSource.y
 pos.z = locSource.z+height
 item.flags.removed=true
 dfhack.items.moveToGround(item,{x=pos.x,y=pos.y,z=pos.z})
 proj = dfhack.items.makeProjectile(item)
 proj.origin_pos.x=locSource.x
 proj.origin_pos.y=locSource.y
 proj.origin_pos.z=locSource.z + height
 proj.prev_pos.x=locSource.x
 proj.prev_pos.y=locSource.y
 proj.prev_pos.z=locSource.z + height
 proj.cur_pos.x=locSource.x
 proj.cur_pos.y=locSource.y
 proj.cur_pos.z=locSource.z + height
 proj.flags.no_impact_destroy=false
 proj.flags.bouncing=true
 proj.flags.piercing=true
 proj.flags.parabolic=true
 proj.flags.unk9=true
 proj.flags.no_collide=true
 proj.speed_x=0
 proj.speed_y=0
 proj.speed_z=0
end


