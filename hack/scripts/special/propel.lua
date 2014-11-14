--special-propel.lua v1.0

local split = require('split')
local utils = require 'utils'

function propel(ptype,unitTarget,strength,unitSource)
 local strengtha = split(strength,',')
 local sx = tonumber(strengtha[1])
 local sy = tonumber(strengtha[2])
 local sz = tonumber(strengtha[3])
 local dx = 1
 local dy = 1
 local dz = 1
 local rando = dfhack.random.new()
 
 if unitSource ~= 0 then
  if unitTarget.pos.x - unitSource.pos.x ~= 0 then
   dx = (unitTarget.pos.x - unitSource.pos.x)/math.abs(unitTarget.pos.x - unitSource.pos.x)
  else
   dx = rando:random(3) - 1
  end
  if unitTarget.pos.y - unitSource.pos.y ~= 0  then
   dy = (unitTarget.pos.y - unitSource.pos.y)/math.abs(unitTarget.pos.y - unitSource.pos.y)
  else
   dy = rando:random(3) - 1
  end
  if unitTarget.pos.z - unitSource.pos.z ~= 0 then
   dz = (unitTarget.pos.z - unitSource.pos.z)/math.abs(unitTarget.pos.z - unitSource.pos.z)
  else
   dz = rando:random(3) - 1
  end
 end
 
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

 if ptype == 'random' then
  rollx = rando:unitrandom()*sx
  rolly = rando:unitrandom()*sy
  rollz = rando:unitrandom()*sz
  bsize = unitTarget.body.size_info.size_cur
  resultx = math.floor(rollx)
  resulty = math.floor(rolly)
  resultz = math.floor(rollz)
 elseif ptype == 'fixed' then
  resultx = sx
  resulty = sy
  resultz = sz
 elseif ptype == 'relative' then
  resultx = sx*dx
  resulty = sy*dy
  resultz = sz*dz
 else
  print('Not a valid type')
 end

 newlist = df.proj_list_link:new()
 lastlist.next=newlist
 newlist.prev=lastlist
 proj = df.proj_unitst:new()
 newlist.item=proj
 proj.link=newlist
 proj.id=df.global.proj_next_id
 df.global.proj_next_id=df.global.proj_next_id+1
 proj.unit=unitTarget
 proj.origin_pos.x=unitTarget.pos.x
 proj.origin_pos.y=unitTarget.pos.y
 proj.origin_pos.z=unitTarget.pos.z
 proj.prev_pos.x=unitTarget.pos.x
 proj.prev_pos.y=unitTarget.pos.y
 proj.prev_pos.z=unitTarget.pos.z
 proj.cur_pos.x=unitTarget.pos.x
 proj.cur_pos.y=unitTarget.pos.y
 proj.cur_pos.z=unitTarget.pos.z
 proj.flags.no_impact_destroy=true
 proj.flags.piercing=true
 proj.flags.parabolic=true
 proj.flags.unk9=true
 proj.speed_x=resultx
 proj.speed_y=resulty
 proj.speed_z=resultz
 unitoccupancy = dfhack.maps.ensureTileBlock(unitTarget.pos).occupancy[unitTarget.pos.x%16][unitTarget.pos.y%16]
 if not unitTarget.flags1.on_ground then 
  unitoccupancy.unit = false 
 else 
  unitoccupancy.unit_grounded = false 
 end
 unitTarget.flags1.projectile=true
 unitTarget.flags1.on_ground=false
end

validArgs = validArgs or utils.invert({
 'help',
 'unit_source',
 'unit_target',
 'velocity',
 'fixed',
 'random',
 'relative',
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
 print([[special-propel.lua
  Flings a unit by turning them into a projectile
  arguments:
   -help
     print this help message
   -unit_source id
     id of the unit to use to use for positioning
     required if using -relative
   -unit_target id
     REQUIRED
     id of the unit to use turn into a projectile
   -velocity #,#,#
     velocity in x,y,z coordinates
     DEFAULT 1,1,1
   -fixed                                                                                                    \
     turns the unit into a projectile and gives the unit the specified velocity                              |
   -random                                                                                                   |
     turns the unit into a projectile and gives the unit a random velocity up to +/- the specified velocity  | Must have one and only one of these arguments
   -relative                                                                                                 |
     turns the unit into a projectile and gives the unit the specified velocity relative to the -unit_source /
  examples:
   special-projectile -unit_source \\UNIT_ID -location_target [\\LOCATION] -item AMMO:ITEM_AMMO_ARROWS -mat STEEL -number 10 -maxrange 50 -minrange 10 -velocity 30 -hitchance 10
 ]])
 return
end

if args.fixed then -- Set type of propel (default fixed) !REQUIRED
 ptype = 'fixed'
elseif args.random then
 ptype = 'random'
elseif args.relative then
 ptype = 'relative'
else
 ptype = 'fixed'
end
if args.unit_target then -- Check for target declaration !REQUIRED
 unit = df.unit.find(tonumber(args.unit_target)).pos
else
 print('No target specified')
 return
end
unitSource = df.unit.find(tonumber(args.unit_source)).pos or 0 -- Check for source declaration
strength = args.velocity or '0,0,0' -- Specify x,y,z velocity (default 0,0,0)

propel(ptype,unit,strength,unitSource)
