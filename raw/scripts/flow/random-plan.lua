--flow/random-plan.lua v1.0

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
 'offset',
 'origin',
 'plan',
 'fill',
})
local args = utils.processArgs({...}, validArgs)

if args.help then
 print([[flow/random-plan.lua
  Spawns flows/liquid with more options than built-in function following an externel txt file
  arguments:
   -help
     print this help message
  REQUIRED:
   -plan filename
     filename of plan to use for spawn
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
  FOR BOTH:
   -offset [ # # # ]
     sets the x y z offset from the desired location to spawn around
     DEFAULT [ 0 0 0 ]
   -number #
     specify the number of flows/liquids that are spawned randomly in the plan
     if 0, will fill the entire plan with a flow at each location
     DEFAULT 0
   -origin id or location
     for use in certain file plans
  examples:
   flow/random-plan -plan 5x5_X.txt -unit \\UNIT_ID -flow web -inorganic STEEL -density 50 -static -origin [ \\LOCATION ]
   flow/random-plan -plan spiral.txt -location [ \\LOCATION ] -liquid magma -depth 4 -number 10
 ]])
 return
end

if not args.plan then
 print('No plan file specified')
 return
end

if args.unit and tonumber(args.unit) then
 target = df.unit.find(tonumber(args.unit)).pos
elseif args.location then
 target = args.location
else
 print('No unit or location selected')
 return
end
offset = args.offset or {0,0,0}
number = args.number or 0
depth = args.depth or 7

if args.origin and tonumber(args.origin) then
 origin = df.unit.find(tonumber(args.origin)).pos
elseif args.origin then
 origin = args.origin
end

path = dfhack.getDFPath()..'/raw/files/'..args.plan
positions = dfhack.script_environment('functions/map').getPositionPlan(path,target,origin)

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
  for i,pos in ipairs(positions) do
   dfhack.script_environment('functions/map').spawnFlow(pos,offset,snum,inum,density,args.static)
  end
 else
  local rand = dfhack.random.new()
  for i = 1, number, 1 do
   j = rand:random(#positions)
   dfhack.script_environment('functions/map').spawnFlow(positions[j],offset,snum,inum,density,args.static)
  end
 end
elseif args.liquid then
 if args.liquid == magma then magma = true end
 if number == 0 then
  for i,pos in ipairs(positions) do
   dfhack.script_environment('functions/map').spawnLiquid(pos,offset,depth,magma,nil,nil)
  end
 else
  local rand = dfhack.random.new()
  for i = 1, number, 1 do
   j = rand:random(#positions)
   dfhack.script_environment('functions/map').spawnLiquid(positions[j],offset,depth,magma,nil,nil)
  end
 end
else
 print('Neither a flow or liquid specified, aborting.')
end