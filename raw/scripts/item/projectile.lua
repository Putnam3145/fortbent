--special-projectile.lua v1.0

local utils = require 'utils'

validArgs = validArgs or utils.invert({
 'help',
 'unitSource',
 'unitTarget',
 'locationSource',
 'locationTarget',
 'creator',
 'mat',
 'item',
 'number',
 'maxrange',
 'velocity',
 'minrange',
 'hitchance',
 'height',
 'equipped',
 'type',
 'quality',
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
 print([[item/projectile.lua
  Creates an item that shoots as a projectile
  arguments:
   -help
     print this help message
   -unitSource id                                                   \
     id of the unit to use for position of origin of projectile     |
   -locationSource [#,#,#]                                          | Must have one and only one of these arguments, if both, ignore -locationSource
     x,y,z coordinates to use for position for origin of projectile /
   -unitTarget id                                                  \
     id of the unit to use for position of target of projectile    |
   -locationTarget [#,#,#]                                         | Must have one and only one of these arguments, if both, ignore -locationTarget
     x,y,z coordinates to use for position of target of projectile /
   -creator id
     id of unit to use as creator of item, if not included assumes unitSource as creator
   -item itemstr
     specify the itemdef of the item to be created or checked for
     examples:
      WEAPON:ITEM_WEAPON_PICK
      AMMO:ITEM_AMMO_BOLT
   -mat matstring
     specify the material of the item to be created
     examples:
      INORGANIC:IRON
      CREATURE_MAT:DWARF:BRAIN
      PLANT_MAT:MUSHROOM_HELMET_PLUMP:DRINK
   -number #
     number of items to fire as projectiles
     DEFAULT 1
   -maxrange #
     maximum range in tiles that the projectile can travel to hit its target
     DEFAULT 10
   -minrange #
     minimum range in tiles that the projectile needs to travel to hit its target
     DEFAULT 1
   -velocity # for shooting mechanics, [ # # # ] for falling mechanics
     speed of projectile (does not affect how fast it moves across the map, only force that it hits the target with)
     DEFAULT 20 or [ 0 0 0 ]
   -hitchance #
     chance for projectile to hit target (assume %?)
     DEFAULT 50
   -height #
     height above the source location to start the item
     DEFAULT 0
   -equipped
     whether to check unitSource (or creatore) for the equipped item, if absent assumes you want the item to be created
  examples:
   item/projectile -unit_source \\UNIT_ID -location_target [\\LOCATION] -item AMMO:ITEM_AMMO_ARROWS -mat STEEL -number 10 -maxrange 50 -minrange 10 -velocity 30 -hitchance 10
 ]])
 return
end

if args.unitSource and args.locationSource then
 print("Can't have unit and location specified as source at same time")
 args.locationSource = nil
end
if args.unitTarget and args.locationTarget then
 print("Can't have unit and location specified as target at same time")
 args.locationTarget = nil
end
if args.unitSource then -- Check for source declaration !REQUIRED
 origin = df.unit.find(tonumber(args.unitSource)).pos
elseif args.locationSource then
 origin = {x=args.locationSource[1],y=args.locationSource[2],z=args.locationSource[3]}
else
 print('No source specified')
 return
end

if args.unitTarget then -- Check for target declaration !REQUIRED
 target = df.unit.find(tonumber(args.unitTarget)).pos
elseif args.locationTarget then
 target = {x=args.locationTarget[1],y=args.locationTarget[2],z=args.locationTarget[3]}
elseif args.falling then
 target = origin
else
 print('No target specified')
 return
end

if not args.item then
 print('No item specified')
 return
end

local itemType = dfhack.items.findType(args.item)
if itemType == -1 then
 print('Invalid item')
 return
end
local itemSubtype = dfhack.items.findSubtype(args.item)
local create = true
if args.equipped and (not args.unitSource and not args.creator) then
 print('No unit to check for equipment')
 return
elseif args.equipped and args.unitSource then
 create = false
 if args.unitSource and not args.creator then
  args.creator = args.unitSource
 end
end

if not args.creator or not tonumber(args.creator) or not df.unit.find(tonumber(args.creator)) then
 if args.unitSource then
  args.creator = args.unitSource
 else
  print('Invalid creator')
  return
 end
end
args.creator = df.unit.find(tonumber(args.creator))

number = tonumber(args.number) or 1 -- Specify number of projectiles (default 1)
for n = 1, number, 1 do
 item = nil
 if create then
  if not args.mat or not dfhack.matinfo.find(args.mat) then
   print('Invalid material')
   return
  end
  item = dfhack.script_environment('functions/item').create(args.item,args.mat,{creator=args.creator,quality=args.quality})
  item = df.item.find(item)
 else
  local inventory = args.creator.inventory
  for k,v in ipairs(inventory) do
   if v.item:getType() == itemType and v.item:getSubtype() == itemSubtype then
    item = v.item
    break
   else
    for l,w in ipairs(dfhack.items.getContainedItems(v.item)) do
     if w:getType() == itemType and w:getSubtype() == itemSubtype then
      item = w
      break
     end
    end
   end
  end
  if not item then
   print('Needed item not equipped')
   return
  end
  if item.stack_size == 1 then
   break
  else
   item.stack_size = item.stack_size - 1
   item = dfhack.script_environment('functions/item').create(args.item,dfhack.matinfo.getToken(item.mat_type,item.mat_index),{creator=dfhack.items.getHolderUnit(item),quality=item.quality})
   item = df.item.find(item)
  end
 end

 if args.type == 'falling' then
  velocity = args.velocity or {0,0,0}
  height = tonumber(args.height) or 0
  dfhack.items.moveToGround(item,{x=tonumber(target.x),y=tonumber(target.y),z=tonumber(target.z+height)})
  dfhack.script_environment('functions/item').makeProjectileFall(item,{target.x,target.y,target.z+height},velocity)
 else
  velocity = tonumber(args.velocity) or 20 -- Specify velocity of projectiles (default 20)
  hit_chance = tonumber(args.hitchance) or 50 -- Specify hit percent of projectiles (default 50)
  max_range = tonumber(args.maxrange) or 10 -- Specify max range of projectiles (default 10)
  min_range = tonumber(args.minrange) or 1 -- Specify minimum range of projectiles (default 1)
  height = tonumber(args.height) or 0
  dfhack.items.moveToGround(item,{x=tonumber(origin.x),y=tonumber(origin.y),z=tonumber(origin.z+height)})
  dfhack.script_environment('functions/item').makeProjectileShot(item,{origin.x,origin.y,origin.z+height},{target.x,target.y,target.z},{velocity=velocity,accuracy=hit_chance,range=max_range,minimum=min_range})
 end
end
