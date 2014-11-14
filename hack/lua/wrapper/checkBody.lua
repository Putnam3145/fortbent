local M
split = require('split')
local function checkBody(unit,array)
 local rtempa,itempa,r,i,required,immune = {},{},1,1,false,false
 local rtext = 'Targeting failed, ' .. tostring(unit.name.first_name) .. ' does not have the required body part.'
 local itext = 'Targeting failed, ' .. tostring(unit.name.first_name) .. ' has an immune body part.'
 local tempa,utempa = split(array,','),unit.body.body_plan.body_parts
 for _,x in ipairs(tempa) do
  t = split(x,';')[2]
  b = split(x,';')[3]
  if split(x,';')[1] == 'required' then
   if t == 'token' then
    for j,y in ipairs(utempa) do
     if y.token == b and not unit.body.components.body_part_status[j].missing then 
      rtempa[r] = true
     else
      rtempa[r] = false
     end
     r = r + 1
    end
   elseif t =='category' then
    for j,y in ipairs(utempa) do
     if y.category == b and not unit.body.components.body_part_status[j].missing then 
      rtempa[r] = true
     else
      rtempa[r] = false
     end
     r = r + 1
    end
   elseif t =='flags' then
    for j,y in ipairs(utempa) do
     if y.flags[b] and not unit.body.components.body_part_status[j].missing then 
      rtempa[r] = true
     else
      rtempa[r] = false
     end
     r = r + 1
    end
   end
  elseif split(x,';')[1] == 'immune' then
   if t == 'token' then
    for j,y in ipairs(utempa) do
     if y.token == b and not unit.body.components.body_part_status[j].missing then 
      itempa[i] = true
     else
      itempa[i] = false
     end
     i = i + 1
    end
   elseif t =='category' then
    for j,y in ipairs(utempa) do
     if y.category == b and not unit.body.components.body_part_status[j].missing then 
      itempa[i] = true
     else
      itempa[i] = false
     end
     i = i + 1
    end
   elseif t =='flags' then
    for j,y in ipairs(utempa) do
     if y.flags[b] and not unit.body.components.body_part_status[j].missing then 
      rtempa[r] = true
     else
      rtempa[r] = false
     end
     i = i + 1
    end
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
M = checkBody

return M