local M
split = require('split')
local function checkDistance(unitTarget,array,plan) -- CHECK 1
 local unumber = 1

 local selected,targetList,announcement = {},{},{''}

 if plan ~= 'NONE' then
  local file = plan..".txt"
  local path = dfhack.getDFPath().."/hack/scripts/"..file

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

  for i,_ in ipairs(x) do
   x[i] = x[i] - x0 + unitTarget.pos.x
   y[i] = y[i] - y0 + unitTarget.pos.y
   t[tostring(x[i])..'_'..tostring(y[i])] = t[i]
  end

  local unitList = df.global.world.units.active
  local mapx, mapy, mapz = dfhack.maps.getTileSize()

  for i = 0, #unitList - 1, 1 do
   local unit = unitList[i]

   if (t[tostring(unit.pos.x)..'_'..tostring(unit.pos.y)] and unit.pos.z == unitTarget.pos.z) and unit.id ~= unitTarget.id then
    targetList[unumber] = unit
    announcement[unumber] = ''
    selected[unumber] = true
    unumber = unumber + 1
   end
  end
 else
  local rx = tonumber(split(array,',')[1])
  local ry = tonumber(split(array,',')[2])
  local rz = tonumber(split(array,',')[3])
  if rx*ry*rz >= 0 then
   local unitList = df.global.world.units.active
   local mapx, mapy, mapz = dfhack.maps.getTileSize()

   for i = 0, #unitList - 1, 1 do
    local unit = unitList[i]
    local xmin = unitTarget.pos.x - rx
    local xmax = unitTarget.pos.x + rx
    local ymin = unitTarget.pos.y - ry
    local ymax = unitTarget.pos.y + ry
    local zmin = unitTarget.pos.z - rz
    local zmax = unitTarget.pos.z + rz
    if xmin < 1 then xmin = 1 end
    if ymin < 1 then ymin = 1 end
    if zmin < 1 then zmin = 1 end
    if xmax > mapx then xmax = mapx-1 end
    if ymax > mapy then ymax = mapy-1 end
    if zmax > mapz then zmax = mapz-1 end

    if (unit.pos.x >= xmin and unit.pos.x <= xmax and unit.pos.y >= ymin and unit.pos.y <= ymax and unit.pos.z >= zmin and unit.pos.z <= zmax) then
     targetList[unumber] = unit
     announcement[unumber] = ''
     selected[unumber] = true
     unumber = unumber + 1
    end
   end
   else
    targetList[unumber] = unitTarget
    announcement[unumber] = ''
    selected[unumber] = true
  end
 end

 return selected, targetList, announcement
end
M = checkDistance

return M