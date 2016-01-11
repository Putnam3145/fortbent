--flow/random-pos.lua v1.0

local utils = require 'utils'

flowtypes = {
miasma = 0,
mist = 1,
mist2 = 2,
dust = 3,
lavamist = 4,
smoke = 5,
dragonfire = 6,
firebreath = 7,
web = 8,
undirectedgas = 9,
undirectedvapor = 10,
oceanwave = 11,
seafoam = 12
}

validArgs = validArgs or utils.invert({
 'help',
 'unit',
 'location',
 'liquid',
 'flow',
 'density',
 'radius',
 'number',
 'inorganic',
 'static',
 'liquid',
 'depth',
 'circle',
 'taper',
 'offset'
})
local args = utils.processArgs({...}, validArgs)

if args.help then
 print([[flow/random-pos.lua
  Spawns flows/liquid with more options than built-in function
  arguments:
   -help
     print this help message
  REQUIRED:
   -unit id                                             \
     id of the unit to use for position to spawn liquid |
   -location [ # # # ]                                  | Must have one and only one of these arguments, if both, ignore -location
     x,y,z coordinates for spawn                        /
  FOR FLOWS:
   -flow TYPE
     specify the flow type
     valid types:
      miasma
      mist
      mist2
      dust
      lavamist
      smoke
      dragonfire
      firebreath
      web
      undirectedgas
      undirectedvapor
      oceanwave
      seafoam
   -inorganic INORGANIC_TOKEN
     specify the material of the flow, if applicable
     examples:
      IRON
      RUBY
      etc...
   -radius [ # # # ]
      specify the radius in x y z where the flows are spawned randomly about the unit
      DEFAULT [ 0 0 0 ]
   -density #
     specify how dense each flow is
     DEFAULT 1
   -static
     sets the flow as static so that it doesn't expand
  FOR LIQUIDS:
   -liquid TYPE
     specify the liquid type
	 valid types:
	  water
	  magma
   -depth #
     specify the depth of the liquid spawned
	 DEFAULT 7
   -radius [ # # # ]
     sets the size of the liquid spawned in x y z coordinates
	 DEFAULT [ 0 0 0 ]
   -circle
     specify whether to spawn as a circle
   -taper
     specify whether to decrease depth as you move away from the center of the spawned liquid
  FOR BOTH:
   -offset [ # # # ]
     sets the x y z offset from the desired location to spawn around
	 DEFAULT [ 0 0 0 ]
   -number #
     specify the number of flows/liquids that are spawned randomly in the radius
	 if 0 then the entire area is covered
     DEFAULT 0
  examples:
   flow/random-pos -unit \\UNIT_ID -flow firebreath -density 25 -radius [ 10 10 0 ] -number 3
   flow/random-pos -unit \\UNIT_ID -flow web -inorganic STEEL -density 10 -number 1
   flow/random-pos -location [ \\LOCATION ] -liquid magma -depth 7 -radius [ 3 3 0 ] -offset [ 0 0 1 ] -circle -taper 
 ]])
 return
end

if args.unit and tonumber(args.unit) then
 pos = df.unit.find(tonumber(args.unit)).pos
elseif args.location then
 pos = args.location
else
 print('No unit or location selected')
 return
end
radius = args.radius or {0,0,0}
offset = args.offset or {0,0,0}
number = tonumber(args.number) or 0
location = {}
location.x = pos.x + offset[1] or pos[1] + offset[1]
location.y = pos.y + offset[2] or pos[2] + offset[2]
location.z = pos.z + offset[3] or pos[3] + offset[3]
if args.flow then
 stype = args.flow
 density = tonumber(args.density) or 1
 itype = args.inorganic or 0
 local snum = flowtypes[stype]
 local inum = 0
 if itype ~= 0 then
  inum = dfhack.matinfo.find(itype).index
 end
 if number == 0 then
  edges = dfhack.script_environment('functions/map').getEdgesPosition(location,radius)
  dfhack.script_environment('functions/map').spawnFlow(edges,{0,0,0},snum,inum,density,args.static)
 else
  for i = 1, number, 1 do
   pos = dfhack.script_environment('functions/map').getPositionLocationRandom(location,radius)
   dfhack.script_environment('functions/map').spawnFlow(pos,{0,0,0},snum,inum,density,args.static)
  end
 end
elseif args.liquid then
 if args.liquid == magma then magma = true end
 if number == 0 then
  edges = dfhack.script_environment('functions/map').getEdgesPosition(location,radius)
  dfhack.script_environment('functions/map').spawnLiquid(edges,{0,0,0},depth,magma,args.circle,args.taper)
 else
  for i = 1, number, 1 do
   pos = dfhack.script_environment('functions/map').getPositionLocationRandom(location,radius)
   dfhack.script_environment('functions/map').spawnLiquid(pos,{0,0,0},depth,magma,nil,nil)
  end
 end
else
 print('Neither a flow or liquid specified, aborting.')
end
