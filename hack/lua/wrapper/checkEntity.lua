local M
split = require('split')
local function checkEntity(unit,array) -- CHECK 1
 local rtempa,itempa,r,i,required,immune = {},{},1,1,false,false
 local rtext = 'Targeting failed, ' .. tostring(unit.name.first_name) .. ' is not a member of a required entity.'
 local itext = 'Targeting failed, ' .. tostring(unit.name.first_name) .. ' is a member of an immune entity.'
 if unit.civ_id < 0 then return false, 'Targeting failed, ' .. tostring(unit.name.first_name) .. ' is an animal.' end
 if type(array) ~= 'table' then array = {array} end
 local utemp = df.global.world.entities[unit.civ_id].entity_raw.code
 for _,x in ipairs(array) do
  if split(x,':')[1] == 'required' then
   if split(x,':')[2] == utemp then
    rtempa[r] = true
   else
    rtempa[r] = false
   end
   r = r + 1
  elseif split(x,':')[1] == 'immune' then
   if split(x,':')[2] == utemp then
    itempa[r] = true
   else
    itempa[r] = false
   end
   i = i + 1
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
M = checkEntity

return M