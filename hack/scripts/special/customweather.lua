--special-customweather.lua v1.0

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

function weather3(stype,number,itype,strength,frequency)
 if weathercontinue then
  dfhack.timeout(frequency,'ticks',weather(stype,number,itype,strength,frequency))
 else
  return
 end
end
function weather2(cbid)
 return function (stopweather)
  weathercontinue = false
 end
end
function weather(stype,number,itype,strength,frequency)
 return function (startweather)
  local i
  local rando = dfhack.random.new()
  local snum = flowtypes[stype]
  local inum = 0
  if itype ~= 0 then
   inum = dfhack.matinfo.find(itype).index
  end

  local mapx, mapy, mapz = dfhack.maps.getTileSize()
  local xmin = 2
  local xmax = mapx - 1
  local ymin = 2
  local ymax = mapy - 1

  local dx = xmax - xmin
  local dy = ymax - ymin
  local pos = {}
  pos.x = 0
  pos.y = 0
  pos.z = 0

  for i = 1, number, 1 do

   local rollx = rando:random(dx)
   local rolly = rando:random(dy)

   pos.x = rollx
   pos.y = rolly
   pos.z = 20
  
   local j = 0
   while not dfhack.maps.ensureTileBlock(pos.x,pos.y,pos.z+j).designation[pos.x%16][pos.y%16].outside do
    j = j + 1
   end
   pos.z = pos.z + j
   dfhack.maps.spawnFlow(pos,snum,0,inum,strength)
  end
  weather3(stype,number,itype,strength,frequency)
 end
end

validArgs = validArgs or utils.invert({
 'help',
 'flow',
 'dur',
 'size',
 'frequency',
 'number',
 'inorganic',
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
 print([[special-customweather.lua
  Create a number of flows spawned randomly on the surface every frequency for a set duration
  arguments:
   -help
     print this help message
   -inorganic INORGANIC_TOKEN
     specify the material of the flow, if applicable
     examples:
      IRON
      RUBY
      etc...
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
   -dur #
     specify how long the 'weather' effect lasts in in-game ticks
     DEFAULT 1
   -frequency #
     specify how often the flows are spawned
     DEFAULT 100
   -number #
     specify the number of flows that are spawned at each frequency
     DEFAULT 1
  examples:
   special-customweather -flow firebreath -size 25 -frequency 200 -number 50 -dur 7200
   special-customweather -flow web -inorganic GOLD -size 50 -frequency 500 -number 100 -dur 1000
 ]])
 return
end

stype = args.flow or 'mist' -- Specify type of flow (default mist)
duration = tonumber(args.dur) or 1 -- Specify duration of flow spawning (default 1)
strength = tonumber(args.size) or 1 -- Specify size of flows to spawn (default 1)
frequency = tonumber(args.frequency) or 100 -- Specify frequency to spawn flows (default 1000)
number = tonumber(args.number) or 1 -- Specify number of flows to spawn (default 1)
itype = args.inorganic or 0 -- Specify flow inorganic (default NONE)

local test = 'abc'
weathercontinue = true

dfhack.timeout(1,'ticks',weather(stype,number,itype,strength,frequency))
dfhack.timeout(duration,'ticks',weather2(test))
