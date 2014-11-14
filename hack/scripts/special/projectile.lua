--special-projectile.lua v1.0

local split = require('split')
local utils = require 'utils'

validArgs = validArgs or utils.invert({
 'help',
 'unit_source',
 'unit_target',
 'location_source',
 'location_target',
 'mat',
 'item',
 'number',
 'maxrange',
 'velocity',
 'minrange',
 'hitchance',
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
 print([[special-projectile.lua
  Creates an item that shoots as a projectile
  arguments:
   -help
     print this help message
   -unit_source id                                                  \
     id of the unit to use for position of origin of projectile     |
   -location_source [#,#,#]                                         | Must have one and only one of these arguments, if both, ignore -location_source
     x,y,z coordinates to use for position for origin of projectile /
   -unit_target id                                                 \
     id of the unit to use for position of target of projectile    |
   -location_target [#,#,#]                                        | Must have one and only one of these arguments, if both, ignore -location_target
     x,y,z coordinates to use for position of target of projectile /
   -item TYPE:SUBTYPE
     REQUIRED
     item to fire as projectile (only BOULDER, AMMO, and WEAPON supported)
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
     number of items to fire as projectiles
     DEFAULT 1
   -maxrange #
     maximum range in tiles that the projectile can travel to hit its target
     DEFAULT 10
   -minrange #
     minimum range in tiles that the projectile needs to travel to hit its target
     DEFAULT 1
   -velocity #
     speed of projectile (does not affect how fast it moves across the map, only force that it hits the target with)
     DEFAULT 20
   -hitchance #
     chance for projectile to hit target (assume %?)
     DEFAULT 50
  examples:
   special-projectile -unit_source \\UNIT_ID -location_target [\\LOCATION] -item AMMO:ITEM_AMMO_ARROWS -mat STEEL -number 10 -maxrange 50 -minrange 10 -velocity 30 -hitchance 10
 ]])
 return
end

if args.unit_source and args.location_source then -- Check that unit and location sources have not been both specified
 print("Can't have unit and location specified as source at same time")
 args.location_source = nil
end
if args.unit_target and args.location_target then -- Check that unit and location targets have not been both specified
 print("Can't have unit and location specified as target at same time")
 args.location_target = nil
end
if args.unit_source then -- Check for source declaration !REQUIRED
 locSource = df.unit.find(tonumber(args.unit_source)).pos
elseif args.location_source then
 locSource = {x=args.location_source[1],y=args.location_source[2],z=args.location_source[3]}
else
 print('No source specified')
 return
end
if args.unit_target then -- Check for target declaration !REQUIRED
 locTarget = df.unit.find(tonumber(args.unit_target)).pos
elseif args.location_target then
 locTarget = {x=args.location_target[1],y=args.location_target[2],z=args.location_target[3]}
else
 print('No target specified')
 return
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
number = tonumber(args.number) or 1 -- Specify number of projectiles (default 1)
vel = tonumber(args.velocity) or 20 -- Specify velocity of projectiles (default 20)
hr = tonumber(args.hitchance) or 50 -- Specify hit percent of projectiles (default 50)
ft = tonumber(args.maxrange) or 10 -- Specify max range of projectiles (default 10)
md = tonumber(args.minrange) or 1 -- Specify minimum range of projectiles (default 1)

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
 elseif split(object,':')[1] == 'WEAPON' then
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
 block = dfhack.maps.ensureTileBlock(locSource.x,locSource.y,locSource.z)
 pos.x = locSource.x
 pos.y = locSource.y
 pos.z = locSource.z
 item.flags.removed=true
 dfhack.items.moveToGround(item,{x=pos.x,y=pos.y,z=pos.z})
 proj = dfhack.items.makeProjectile(item)
 proj.origin_pos.x=locSource.x
 proj.origin_pos.y=locSource.y
 proj.origin_pos.z=locSource.z
 proj.prev_pos.x=locSource.x
 proj.prev_pos.y=locSource.y
 proj.prev_pos.z=locSource.z
 proj.cur_pos.x=locSource.x
 proj.cur_pos.y=locSource.y
 proj.cur_pos.z=locSource.z
 proj.target_pos.x=locTarget.x
 proj.target_pos.y=locTarget.y
 proj.target_pos.z=locTarget.z
 proj.flags.no_impact_destroy=false
 proj.flags.bouncing=false
 proj.flags.piercing=false
 proj.flags.parabolic=false
 proj.flags.unk9=false
 proj.flags.no_collide=false
-- Need to figure out these numbers!!!
 proj.distance_flown=0 -- Self explanatory
 proj.fall_threshold=ft -- Seems to be able to hit units further away with larger numbers
 proj.min_hit_distance=md -- Seems to be unable to hit units closer than this value
 proj.min_ground_distance=ft-1 -- No idea
 proj.fall_counter=0 -- No idea
 proj.fall_delay=0 -- No idea
 proj.hit_rating=hr -- I think this is how likely it is to hit a unit (or to go where it should maybe?)
 proj.unk22 = vel
 proj.speed_x=0
 proj.speed_y=0
 proj.speed_z=0
end


