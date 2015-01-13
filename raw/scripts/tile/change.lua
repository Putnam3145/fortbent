--tile-change.lua v1.0

local split = require('split')
local utils = require 'utils'

function read_file(path)
 local iofile = io.open(path,"r")
 local read = iofile:read("*all")
 iofile:close()

 local reada = split(read,',')
 local x = {}
 local y = {}
 local t = {}
 local xi = 0
 local yi = 1
 local x0 = 0
 local y0 = 0
 for i,v in ipairs(reada) do
  if split(v,'\n')[1] ~= v then
   xi = 1
   yi = yi + 1
  else
   xi = xi + 1
  end
  if v == 'X' or v == '\nX' then
   x0 = xi
   y0 = yi
  end
  if v == 'X' or v == '\nX' or v == '1' or v == '\n1' then
   t[i] = true
  else
   t[i] = false
  end
  x[i] = xi
  y[i] = yi
 end
 return x,y,t
end

function resetTemp(pos,temp1,temp2)
 return function(reset1)
  dfhack.maps.ensureTileBlock(pos).temperature_1[pos.x%16][pos.y%16] = temp1
  dfhack.maps.ensureTileBlock(pos).temperature_1[pos.x%16][pos.y%16] = temp2
  dfhack.maps.ensureTileBlock(pos).flags.update_temperature = true
 end
end
function changeTemp(x,y,z,temp,dur)
 local pos = {x=x,y=y,z=z}
 local block = dfhack.maps.ensureTileBlock(pos)
 local stemp1 = block.temperature_1[x%16][y%16]
 local stemp2 = block.temperature_2[x%16][y%16]

 block.temperature_1[x%16][y%16] = temp
 if dur >= 0 then 
  block.temperature_2[x%16][y%16] = temp
  block.flags.update_temperature = false
 end

 if dur > 0 then dfhack.timeout(dur,'ticks',resetTemp(pos,stemp1,stemp2)) end
end

function findMineralEv(block,inorganic) -- Taken from Warmist's constructor.lua
 for k,v in pairs(block.block_events) do
  if df.block_square_event_mineralst:is_instance(v) and v.inorganic_mat==inorganic then
   return v
  end
 end
end
function set_vein(x,y,z,mat) -- Taken from Warmist's constructor.lua
    local b=dfhack.maps.ensureTileBlock(x,y,z)
    local ev=findMineralEv(b,mat.index)
    if ev==nil then
        ev=df.block_square_event_mineralst:new()
        ev.inorganic_mat=mat.index
        ev.flags.vein=true
        b.block_events:insert("#",ev)
    end
    dfhack.maps.setTileAssignment(ev.tile_bitmask,math.fmod(x,16),math.fmod(y,16),true)
end
function clear_vein(x,y,z)
 local b=dfhack.maps.ensureTileBlock(x,y,z)
 for k = #b.block_events-1,0,-1 do
  print(k)
  b.block_events:erase(k)
 end
end
function changeType(x,y,z,material,dur)
 local mat
 if material ~= 'clear' then 
  mat = dfhack.matinfo.find(material)
  set_vein(x,y,z,mat)
 else
  clear_vein(x,y,z)
 end
end

validArgs = validArgs or utils.invert({
 'help',
 'plan',
 'location',
 'temperature',
 'material',
 'dur',
 'unit',
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
 print([[special-fallingitems.lua
  Creates an item that falls from the sky and can inflict damage
  arguments:
   -help
     print this help message
   -unit id
     id of the unit to center on
     required if using -plan
   -plan filename                           \
     filename of plan to use (without .txt) |
   -location [#,#,#]                        | Must have at least one of these
     x,y,z coordinates to use for position  /
   -temperature #               \
     temperature to set tile to |
   -material INORGANIC_TOKEN    |
     material to set tile to    |
     examples:                  | Must have at least one of these
      STEEL                     |
      GRANITE                   |
      RUBY                      /
   -dur #
     length of time for tile change to last
     0 means the change is natural and will revert back to normal temperature
     DEFAULT 0
  examples:
   tile-change -unit \\UNIT_ID -plan 5x5_X -temperature 15000 -dur 1000
   tile-change -location [\\LOCATION] -material RUBY 
 ]])
 return
end

unit = df.unit.find(tonumber(args.unit)) or 0 -- Check for unit declaration !REQUIRED if using -args.plan
dur = tonumber(args.dur) or 0 -- Check if there is a duration (default 0)

if args.plan then -- Check if changing tiles based on external file plan. !!RUN SCRIPTS!!
 local unitTarget = unit
 local file = args.plan..".txt"
 local path = dfhack.getDFPath().."/hack/scripts/"..file
 local x,y,t = read_file(path)
 for i,_ in ipairs(x) do
  xc = x[i] - x0 + pos.x
  yc = y[i] - y0 + pos.y
  zc = z
  if t[i] then
   if args.temperature then changeTemp(xc,yc,zc,tonumber(args.temperature),dur) end
   if args.material then changeType(xc,yc,zc,args.material,dur) end
  end
 end
end
if args.location then -- Check if changing tiles based on location. !!RUN SCRIPTS!!
 local x = args.location[1]
 local y = args.location[2]
 local z = args.location[3]
 if args.temperature then changeTemp(xc,yc,zc,tonumber(args.temperature),dur) end
 if args.material then changeType(xc,yc,zc,args.material,dur) end
end

