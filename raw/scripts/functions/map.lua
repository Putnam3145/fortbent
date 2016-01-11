function changeInorganic(x,y,z,inorganic,dur)
 if y == nil and z == nil then
  pos = x
 else
  pos = {x = x, y = y, z = z}
 end

 local block=dfhack.maps.ensureTileBlock(pos)
 local current_inorganic = 'clear'
 for k = #block.block_events-1,0,-1 do
   if df.block_square_event_mineralst:is_instance(block.block_events[k]) then
    if current_inorganic == 'clear' then current_inorganic = block.block_events[k].inorganic_mat end
    b.block_events:erase(k)
   end
 end
 if inorganic == 'clear' then
  return
 else
  if tonumber(inorganic) then
   inorganic = tonumber(inorganic)
  else
   inorganic = dfhack.matinfo.find(inorganic).index
  end
  ev=df.block_square_event_mineralst:new()
  ev.inorganic_mat=inorganic
  ev.flags.vein=true
  block.block_events:insert("#",ev)
  dfhack.maps.setTileAssignment(ev.tile_bitmask,math.fmod(pos.x,16),math.fmod(pos.y,16),true)
 end

 if dur > 0 then
  dfhack.script_environment('persist-delay').environmentDelay(dur,'functions/map','changeInorganic',{pos.x,pos.y,pos.z,current_inorganic,0})
 end
end

function changeTemperature(x,y,z,temperature,dur)
 if y == nil and z == nil then
  pos = x
 else
  pos = {x = x, y = y, z = z}
 end

 local block = dfhack.maps.ensureTileBlock(pos)
 local current_temperature = block.temperature_2[x%16][y%16]

 block.temperature_1[x%16][y%16] = temperature
 if dur > 0 then
  block.temperature_2[x%16][y%16] = temperature
  block.flags.update_temperature = false
 end

 if dur > 0 then
  dfhack.script_environment('persistDelay').environmentDelay(dur,'functions/map','changeTemperature',{pos.x,pos.y,pos.z,current_temperature,0})
 end
end

function checkBounds(pos)
 local mapx, mapy, mapz = dfhack.maps.getTileSize()
 if pos.x < 1 then pos.x = 1 end
 if pos.x > mapx-1 then pos.x = mapx-1 end
 if pos.y < 1 then pos.y = 1 end
 if pos.y > mapy-1 then pos.y = mapy-1 end
 if pos.z < 1 then pos.z = 1 end
 if pos.z > mapz-1 then pos.z = mapz-1 end

 return pos
end

function getEdgesPosition(pos,radius)

 local edges = {}
 local rx = radius.x or radius[1] or 0
 local ry = radius.y or radius[2] or 0
 local rz = radius.z or radius[3] or 0
 local xpos = pos.x or pos[1]
 local ypos = pos.y or pos[2]
 local zpos = pos.z or pos[3]

 local mapx, mapy, mapz = dfhack.maps.getTileSize()
 edges.xmin = xpos - rx
 edges.xmax = xpos + rx
 edges.ymin = ypos - ry
 edges.ymax = ypos + ry
 edges.zmax = zpos + rz
 edges.zmin = zpos - rz
 if edges.xmin < 1 then edges.xmin = 1 end
 if edges.ymin < 1 then edges.ymin = 1 end
 if edges.zmin < 1 then edges.zmin = 1 end
 if edges.xmax > mapx then edges.xmax = mapx-1 end
 if edges.ymax > mapy then edges.ymax = mapy-1 end
 if edges.zmax > mapz then edges.zmax = mapz-1 end

 return edges
end

function getFillPosition(pos,radius)

 local positions = {}
 local rx = radius.x or radius[1] or 0
 local ry = radius.y or radius[2] or 0
 local rz = radius.z or radius[3] or 0
 local xpos = pos.x or pos[1]
 local ypos = pos.y or pos[2]
 local zpos = pos.z or pos[3]

 local mapx, mapy, mapz = dfhack.maps.getTileSize()
 n = 0
 for k = 0,rz,1 do
  for j = 0,ry,1 do
   for i = 0,rx,1 do
    n = n+1
    positions[n] = {x = xpos+i, y = ypos+j, z = zpos+k}
    if positions[n].x < 1 then positions[n].x = 1 end
    if positions[n].y < 1 then positions[n].y = 1 end
    if positions[n].z < 1 then positions[n].z = 1 end
    if positions[n].x > mapx then positions[n].x = mapx-1 end
    if positions[n].y > mapy then positions[n].y = mapy-1 end
    if positions[n].z > mapz then positions[n].z = mapz-1 end
   end
  end
 end

 return positions,n
end

function getPositionPlan(file,target,origin)

 local xtar = target.x or target[1]
 local ytar = target.y or target[2]
 local ztar = target.z or target[3]

 local utils = require 'utils'
 local split = utils.split_string

 local iofile = io.open(file,"r")
 local data = iofile:read("*all")
 iofile:close()
 local splitData = split(data,',')

 local x = {}
 local y = {}
 local t = {}
 local xi = 0
 local yi = 1
 local xT = -1
 local yT = -1
 local xS = -1
 local yS = -1
 local xC = -1
 local yC = -1
 local n = 0
 local locations = {}

 for i,v in ipairs(splitData) do
  if split(v,'\n')[1] ~= v then
   xi = 1
   yi = yi + 1
  else
   xi = xi + 1
  end
  if v == 'T' or v == '\nT' then
   xT = xi
   yT = yi
  end
  if v == 'S' or v == '\nS' then
   xS = xi
   yS = yi
  end
  if v == 'C' or v == '\nC' then
   xC = xi
   yC = yi
  end
  if v == 'T' or v == '\nT' or v == '1' or v == '\n1' or v == 'C' or v == '\nC' then
   t[i] = true
  else
   t[i] = false
  end
  x[i] = xi
  y[i] = yi
 end
  
 if origin then
  xorg = origin.x or origin[1]
  yorg = origin.y or origin[2]
  zorg = origin.z or origin[3]
  xdis = math.abs(xorg-xtar)
  ydis = math.abs(yorg-ytar)
  if ztar ~= zorg then return locations,n end
  if xdis ~= 0 then
   xface = (xorg-xtar)/math.abs(xorg-xtar)
  else
   xface = 0
  end
  if ydis ~= 0 then
   yface = (yorg-ytar)/math.abs(yorg-ytar)
  else
   yface = 0
  end
  if xface == 0 and yface == 0 then
   xface = 0
   yface = 1
  end
  if xT == -1 and xS > 0 then
   for i,v in ipairs(x) do
    if t[i] then
     n = n + 1
	 xO = x[i] - xS
	 yO = y[i] - yS
	 xpos = -yface*xO+xface*yO
	 ypos = xface*xO+yface*yO
	 locations[n] = {x = xorg + xpos, y = yorg + ypos, z = zorg}
	 if (xface == 1 and yface == 1) or (xface == -1 and yface == 1) or (xface == 1 and yface == -1) or (xface == -1 and yface == -1) then
	  if xO ~= 0 and yO ~= 0 and (xO+yO) ~= 0 and (xO-yO) ~= 0 then
       n = n + 1
	   if yO < 0 and xO < 0 then
	    locations[n] = {x = xorg + xpos + (xface-yface)*xface*xface/2, y = yorg + ypos + (xface+yface)*xface*yface/2, z = zorg}
	   elseif yO < 0 and xO > 0 then
	    locations[n] = {x = xorg + xpos + (xface+yface)*xface*xface/2, y = yorg + ypos + (xface-yface)*xface*yface/2, z = zorg}
	   elseif yO > 0 and xO > 0 then
	    locations[n] = {x = xorg + xpos - (xface-yface)*xface*xface/2, y = yorg + ypos - (xface+yface)*xface*yface/2, z = zorg}
	   elseif yO > 0 and xO < 0 then
	    locations[n] = {x = xorg + xpos - (xface+yface)*xface*xface/2, y = yorg + ypos - (xface-yface)*xface*yface/2, z = zorg}
	   end
	  end
	 end
    end
   end
  elseif xT > 0 and xS == -1 then
   for i,v in ipairs(x) do
    if t[i] then
     n = n + 1
	 xO = x[i] - xT
	 yO = y[i] - yT
	 xpos = -yface*xO+xface*yO
	 ypos = xface*xO+yface*yO
	 locations[n] = {x = xorg + xpos, y = yorg + ypos, z = zorg}
	 if (xface == 1 and yface == 1) or (xface == -1 and yface == 1) or (xface == 1 and yface == -1) or (xface == -1 and yface == -1) then
	  if xO ~= 0 and yO ~= 0 and (xO+yO) ~= 0 and (xO-yO) ~= 0 then
       n = n + 1
	   if yO < 0 and xO < 0 then
	    locations[n] = {x = xorg + xpos + (xface-yface)*xface*xface/2, y = yorg + ypos + (xface+yface)*xface*yface/2, z = zorg}
	   elseif yO < 0 and xO > 0 then
	    locations[n] = {x = xorg + xpos + (xface+yface)*xface*xface/2, y = yorg + ypos + (xface-yface)*xface*yface/2, z = zorg}
	   elseif yO > 0 and xO > 0 then
	    locations[n] = {x = xorg + xpos - (xface-yface)*xface*xface/2, y = yorg + ypos - (xface+yface)*xface*yface/2, z = zorg}
	   elseif yO > 0 and xO < 0 then
	    locations[n] = {x = xorg + xpos - (xface+yface)*xface*xface/2, y = yorg + ypos - (xface-yface)*xface*yface/2, z = zorg}
	   end
	  end
	 end
    end
   end
  elseif xT > 0 and xS > 0 then -- For now just use the same case as above, in the future should add a way to check for both
   for i,v in ipairs(x) do
    if t[i] then
     n = n + 1
	 xO = x[i] - xT
	 yO = y[i] - yT
	 xpos = -yface*xO+xface*yO
	 ypos = xface*xO+yface*yO
	 locations[n] = {x = xorg + xpos, y = yorg + ypos, z = zorg}
	 if (xface == 1 and yface == 1) or (xface == -1 and yface == 1) or (xface == 1 and yface == -1) or (xface == -1 and yface == -1) then
	  if xO ~= 0 and yO ~= 0 and (xO+yO) ~= 0 and (xO-yO) ~= 0 then
       n = n + 1
	   if yO < 0 and xO < 0 then
	    locations[n] = {x = xorg + xpos + (xface-yface)*xface*xface/2, y = yorg + ypos + (xface+yface)*xface*yface/2, z = zorg}
	   elseif yO < 0 and xO > 0 then
	    locations[n] = {x = xorg + xpos + (xface+yface)*xface*xface/2, y = yorg + ypos + (xface-yface)*xface*yface/2, z = zorg}
	   elseif yO > 0 and xO > 0 then
	    locations[n] = {x = xorg + xpos - (xface-yface)*xface*xface/2, y = yorg + ypos - (xface+yface)*xface*yface/2, z = zorg}
	   elseif yO > 0 and xO < 0 then
	    locations[n] = {x = xorg + xpos - (xface+yface)*xface*xface/2, y = yorg + ypos - (xface-yface)*xface*yface/2, z = zorg}
	   end
	  end
	 end
    end
   end
  end
 else
  for i,v in ipairs(x) do
   if t[i] then
    n = n + 1
    locations[n] = {x = xtar + x[i] - xT, y = ytar + y[i] - yT, z = ztar}
   end
  end
 end

 return locations,n
end

function getPositionCenter(radius)
 local pos = {}
 local rand = dfhack.random.new()

 local mapx, mapy, mapz = dfhack.maps.getTileSize()

 if tonumber(radius) then
  radius = tonumber(radius)
 else
  radius = 0
 end

 x = math.floor(mapx/2)
 y = math.floor(mapy/2)
 pos.x = rand:random(radius) + (rand:random(2)-1)*x
 pos.y = rand:random(radius) + (rand:random(2)-1)*y
 pos.z = rand:random(mapz)

 return pos
end

function getPositionEdge()
 local pos = {}
 local rand = dfhack.random.new()

 local mapx, mapy, mapz = dfhack.maps.getTileSize()

 roll = rand:random(2)
 if roll == 1 then
  pos.x = 2
 else
  pos.x = mapx-1
 end
 roll = rand:random(2)
 if roll == 1 then
  pos.y = 2
 else
  pos.y = mapy-1
 end
 pos.z = rand:random(mapy)

 return pos
end

function getPositionRandom()
 local pos = {}
 local rand = dfhack.random.new()

 local mapx, mapy, mapz = dfhack.maps.getTileSize()

 pos.x = rand:random(mapx)
 pos.y = rand:random(mapy)
 pos.z = rand:random(mapz)

 return pos
end

function getPositionCavern(number)

 local mapx, mapy, mapz = dfhack.maps.getTileSize()
    for i = 1,mapx,1 do
     for j = 1,mapy,1 do
      for k = 1,mapz,1 do
       if dfhack.maps.getTileFlags(i,j,k).subterranean then
        if dfhack.maps.getTileBlock(i,j,k).global_feature >= 0 then
         for l,v in pairs(df.global.world.features.feature_global_idx) do
          if v == dfhack.maps.getTileBlock(i,j,k).global_feature then
           feature = df.global.world.features.map_features[l]
           if feature.start_depth == tonumber(quaternary) or quaternary == 'NONE' then
            if df.tiletype.attrs[dfhack.maps.getTileType(i,j,k)].caption == 'stone floor' then
             n = n+1
             targetList[n] = {x = i, y = j, z = k}
            end
           end
          end
         end
        end
       else
        break
       end
      end
     end
    end

 pos = dfhack.script_environment('functions/misc').permute(targetList)
 return pos[1]
end

function getPositionSurface(location)
 local pos = {}

 local mapx, mapy, mapz = dfhack.maps.getTileSize()

 pos.x = location.x or location[1]
 pos.y = location.y or location[2]
 pos.z = mapz - 1

 local j = 0
 while dfhack.maps.ensureTileBlock(pos.x,pos.y,pos.z-j).designation[pos.x%16][pos.y%16].outside do
  j = j + 1
 end
 pos.z = pos.z - j

 pos = checkBounds(pos)
 return pos
end

function getPositionSky(location)
 local pos = {}
 local rand = dfhack.random.new()

 local mapx, mapy, mapz = dfhack.maps.getTileSize()

 pos.x = location.x or location[1]
 pos.y = location.y or location[2]
 pos.z = mapz - 1

 local j = 0
 while dfhack.maps.ensureTileBlock(pos.x,pos.y,pos.z-j).designation[pos.x%16][pos.y%16].outside do
  j = j + 1
 end
 pos.z = rand:random(mapz-j)+j

 pos = checkBounds(pos)
 return pos
end

function getPositionUnderground(location)
 local pos = {}
 local rand = dfhack.random.new()

 local mapx, mapy, mapz = dfhack.maps.getTileSize()

 pos.x = location.x or location[1]
 pos.y = location.y or location[2]
 pos.z = mapz - 1

 local j = 0
 while dfhack.maps.ensureTileBlock(pos.x,pos.y,pos.z-j).designation[pos.x%16][pos.y%16].outside do
  j = j + 1
 end
 pos.z = rand:random(j-1)

 pos = checkBounds(pos)
 return pos
end

function getPositionLocationRandom(location,radius)
 lx = location.x or location[1]
 ly = location.y or location[2]
 lz = location.z or location[3]

 local pos = {}
 local rand = dfhack.random.new()

 local mapx, mapy, mapz = dfhack.maps.getTileSize()
 local rx = radius.x or radius[1] or 0
 local ry = radius.y or radius[2] or 0
 local rz = radius.z or radius[3] or 0
 local xmin = lx - rx
 local ymin = ly - ry
 local zmin = lz - rz
 local xmax = lx + rx
 local ymax = ly + ry
 local zmax = lz + rz

 pos.x = rand:random(xmax-xmin) + xmin
 pos.y = rand:random(ymax-ymin) + ymin
 pos.z = rand:random(zmax-zmin) + zmin

 pos = checkBounds(pos)
 return pos
end

function getPositionUnitRandom(unit,radius)
 if tonumber(unit) then
  unit = df.unit.find(tonumber(unit))
 end

 local pos = {}
 local rand = dfhack.random.new()

 local mapx, mapy, mapz = dfhack.maps.getTileSize()
 local rx = radius.x or radius[1] or 0
 local ry = radius.y or radius[2] or 0
 local rz = radius.z or radius[3] or 0
 local xmin = unit.pos.x - rx
 local ymin = unit.pos.y - ry
 local zmin = unit.pos.z - rz
 local xmax = unit.pos.x + rx
 local ymax = unit.pos.y + ry
 local zmax = unit.pos.z + rz

 pos.x = rand:random(xmax-xmin) + xmin
 pos.y = rand:random(ymax-ymin) + ymin
 pos.z = rand:random(zmax-zmin) + zmin

 pos = checkBounds(pos)
 return pos
end

function spawnFlow(edges,offset,flowType,inorganic,density,static)
 local ox = offset.x or offset[1] or 0
 local oy = offset.y or offset[2] or 0
 local oz = offset.z or offset[3] or 0
 if edges.xmin then
  xmin = edges.xmin + ox
  xmax = edges.xmax + ox
  ymin = edges.ymin + oy
  ymax = edges.ymax + oy
  zmin = edges.zmin + oz
  zmax = edges.zmax + oz
 else
  xmin = edges.x + ox or edges[1] + ox
  ymin = edges.y + oy or edges[2] + oy
  zmin = edges.z + oz or edges[3] + oz
  xmax = edges.x + ox or edges[1] + ox
  ymax = edges.y + oy or edges[2] + oy
  zmax = edges.z + oz or edges[3] + oz
 end
 
 for x = xmin, xmax, 1 do
  for y = ymin, ymax, 1 do
   for z = zmin, zmax, 1 do
    block = dfhack.maps.ensureTileBlock(x,y,z)
	dsgn = block.designation[x%16][y%16]
	if not dsgn.hidden then
     flow = dfhack.maps.spawnFlow({x=x,y=y,z=z},flowType,0,inorganic,density)
     if static then flow.expanding = false end
	end
   end
  end
 end
end

function spawnLiquid(edges,offset,depth,magma,circle,taper)
 local ox = offset.x or offset[1] or 0
 local oy = offset.y or offset[2] or 0
 local oz = offset.z or offset[3] or 0
 if edges.xmin then
  xmin = edges.xmin + ox
  xmax = edges.xmax + ox
  ymin = edges.ymin + oy
  ymax = edges.ymax + oy
  zmin = edges.zmin + oz
  zmax = edges.zmax + oz
 else
  xmin = edges.x + ox or edges[1] + ox
  ymin = edges.y + oy or edges[2] + oy
  zmin = edges.z + oz or edges[3] + oz
  xmax = edges.x + ox or edges[1] + ox
  ymax = edges.y + oy or edges[2] + oy
  zmax = edges.z + oz or edges[3] + oz
 end

 for x = xmin, xmax, 1 do
  for y = ymin, ymax, 1 do
   for z = zmin, zmax, 1 do
    if circle then
     if (math.abs(x-(xmax+xmin)/2)+math.abs(y-(ymax+ymin)/2)+math.abs(z-(zmax+zmin)/2)) <= math.sqrt((xmax-xmin)^2/4+(ymax-ymin)^2/4+(zmax-zmin)^2/4) then
      block = dfhack.maps.ensureTileBlock(x,y,z)
      dsgn = block.designation[x%16][y%16]
      if not dsgn.hidden then
       if taper then
        size = math.floor(depth-((xmax-xmin)*math.abs((xmax+xmin)/2-x)+(ymax-ymin)*math.abs((ymax+ymin)/2-y)+(zmax-zmin)*math.abs((zmax+zmin)/2-z))/depth)
        if size < 0 then size = 0 end
       else
        size = depth
       end
       dsgn.flow_size = size
       if magma then dsgn.liquid_type = true end
       flow = block.liquid_flow[x%16][y%16]
       flow.temp_flow_timer = 10
       flow.unk_1 = 10
       block.flags.update_liquid = true
       block.flags.update_liquid_twice = true
      end
     end
    else
     block = dfhack.maps.ensureTileBlock(x,y,z)
     dsgn = block.designation[x%16][y%16]
     if not dsgn.hidden then
      if taper then
       size = math.floor(depth-((xmax-xmin)*math.abs((xmax+xmin)/2-x)+(ymax-ymin)*math.abs((ymax+ymin)/2-y)+(zmax-zmin)*math.abs((zmax+zmin)/2-z))/depth)
       if size < 0 then size = 0 end
      else
       size = depth
      end
      flow = block.liquid_flow[x%16][y%16]
      flow.temp_flow_timer = 10
      flow.unk_1 = 10
      dsgn.flow_size = size
      if magma then dsgn.liquid_type = true end
      block.flags.update_liquid = true
      block.flags.update_liquid_twice = true
     end
    end
   end
  end
 end
end

function findLocation(search)
 local primary = search[1]
 local secondary = search[2] or 'NONE'
 local tertiary = search[3] or 'NONE'
 local quaternary = search[4] or 'NONE'
 local x_map, y_map, z_map = dfhack.maps.getTileSize()
 x_map = x_map - 1
 y_map = y_map - 1
 z_map = z_map - 1
 local targetList = {}
 local target = nil
 local found = false
 local n = 1
 local rando = dfhack.random.new()
 if primary == 'RANDOM' then
  if secondary == 'NONE' or secondary == 'ALL' then
   n = 1
   targetList = {{x = rando:random(x_map-1)+1,y = rando:random(y_map-1)+1,z = rando:random(z_map-1)+1}}
  elseif secondary == 'SURFACE' then
   if tertiary == 'ALL' or tertiary == 'NONE' then
    targetList[n] = getPositionRandom()
    targetList[n] = getPositionSurface(target[n])
   elseif tertiary == 'EDGE' then
    targetList[n] = getPositionEdge()
    targetList[n] = getPositionSurface(target[n])
   elseif tertiary == 'CENTER' then
    targetList[n] = getPositionCenter(quaternary)
    targetList[n] = getPositionSurface(target[n])
   end
  elseif secondary == 'UNDERGROUND' then
   if tertiary == 'ALL' or tertiary == 'NONE' then
    targetList[n] = getPositionRandom()
    targetList[n] = getPositionUnderground(target[n])
   elseif tertiary == 'CAVERN' then
    targetList[n] = getPositionCavern(quaternary)
   end
  elseif secondary == 'SKY' then
   if tertiary == 'ALL' or tertiary == 'NONE' then
    targetList[n] = getPositionRandom()
    targetList[n] = getPositionSky(target[n])
   elseif tertiary == 'EDGE' then
    targetList[n] = getPositionEdge()
    targetList[n] = getPositionSky(target[n])
   elseif tertiary == 'CENTER' then
    targetList[n] = getPositionCenter(quaternary)
    targetList[n] = getPositionSky(target[n])
   end
  end
 end
 target = targetList[1]
 return target
end