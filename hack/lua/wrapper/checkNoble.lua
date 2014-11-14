local M
split = require('split')
local function checkNoble(unit,array) -- CHECK 1
 local rtempa,itempa,r,i,required,immune = {},{},1,1,false,false
 local rtext = 'Targeting failed, ' .. tostring(unit.name.first_name) .. ' does not hold the required position.'
 local itext = 'Targeting failed, ' .. tostring(unit.name.first_name) .. ' is holding an immune position.'
 if type(array) ~= 'table' then array = {array} end
 local utempa = dfhack.units.getNoblePositions(unit)
 for _,x in ipairs(array) do
  for _,y in ipairs(utempa) do
   if split(x,':')[1] == 'required' then
    if split(x,':')[2] == y.position.code then
     rtempa[r] = true
    else
     rtempa[r] = false
    end
    r = r + 1
   elseif split(x,':')[1] == 'immune' then
    if split(x,':')[2] == y.position.code then
     itempa[i] = true
    else
     itempa[i] = false
    end
    i = i + 1
   end
  end
 end
 for _,x in ipairs(rtempa) do
  if x then required = true end
 end
 for _,x in ipairs(itempa) do
  if x then immune = true end
 end
 if required and not immune then return true,'NONE' end
 if required and immune then return false,itext end
 if not required and immune then return false,itext end
 if not required and not immune then return false,rtext end
end
M = checkNoble

return M