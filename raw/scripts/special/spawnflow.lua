--special-spawnflow.lua v1.0

local split = require('split')
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

function storm(stype,unit,radius,number,itype,strength)

 local i
 local rando = dfhack.random.new()
 local snum = flowtypes[stype]
 local inum = 0
 if itype ~= 0 then
  inum = dfhack.matinfo.find(itype).index
 end

 local mapx, mapy, mapz = dfhack.maps.getTileSize()
 local xmin = unit.pos.x - radius
 local xmax = unit.pos.x + radius
 local ymin = unit.pos.y - radius
 local ymax = unit.pos.y + radius
 if xmin < 1 then xmin = 1 end
 if ymin < 1 then ymin = 1 end
 if xmax > mapx then xmax = mapx-1 end
 if ymax > mapy then ymax = mapy-1 end

 local dx = xmax - xmin
 local dy = ymax - ymin
 local pos = {}
 pos.x = 0
 pos.y = 0
 pos.z = 0

 for i = 1, number, 1 do

  local rollx = rando:random(dx) - radius
  local rolly = rando:random(dy) - radius

  pos.x = unit.pos.x + rollx
  pos.y = unit.pos.y + rolly
  pos.z = unit.pos.z
  
  local j = 0
  while not dfhack.maps.ensureTileBlock(pos.x,pos.y,pos.z+j).designation[pos.x%16][pos.y%16].outside do
   j = j + 1
  end
  pos.z = pos.z + j
  dfhack.maps.spawnFlow(pos,snum,0,inum,strength)
 end
end

validArgs = validArgs or utils.invert({
 'help',
 'unit',
 'flow',
 'size',
 'radius',
 'number',
 'inorganic',
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
 print([[special-spawnflow.lua
  Create a number of flows spawned randomly on the surface every frequency for a set duration
  arguments:
   -help
     print this help message
   -unit id
     REQUIRED
     id of the unit to center on
   -inorganic INORGANIC_TOKEN
     specify the material of the flow, if applicable
     examples:
      IRON
      RUBY
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
     DEFAULT mist
   -size #
     specify how big each flow is
     DEFAULT 1
   -radius #
     specify the radius in r, where r = x^2 + y^2, where flows are spawned randomly
     DEFAULT 0
   -number #
     specify the number of flows that are spawned randomly in the radius
     DEFAULT 1
  examples:
   special-spawnflow -unit \\UNIT_ID -flow firebreath -size 25 -radius 10 -number 2
   special-spawnflow -unit \\UNIT_ID -flow web -inorganic STEEL -size 10 -radius 0 -number 1
 ]])
 return
end


if args.unit and tonumber(args.unit) then -- Check for unit declaration !REQUIRED
 unit = df.unit.find(tonumber(args.unit))
else
 print('No unit selected')
 return
end
stype = args.flow or 'mist' -- Specify type of flow (default mist)
radius = tonumber(args.radius) or 0 -- Specify radius of area (default 0)
strength = tonumber(args.size) or 1 -- Specify size of flows to spawn (default 1)
number = tonumber(args.number) or 1 -- Specify number of flows to spawn (default 1)
itype = args.inorganic or 0 -- Specify flow inorganic (default NONE)

storm(stype,unit,radius,number,itype,strength)
