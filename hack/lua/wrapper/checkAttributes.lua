local M
split = require('split')
local function getAttrValue(unit,attr,mental) -- CHECK 1
 if unit.curse.attr_change then
  if mental then
   return (unit.status.current_soul.mental_attrs[attr].value+unit.curse.attr_change.ment_att_add[attr])*unit.curse.attr_change.ment_att_perc[attr]/100
  else
   return (unit.body.physical_attrs[attr].value+unit.curse.attr_change.phys_att_add[attr])*unit.curse.attr_change.phys_att_perc[attr]/100
  end
 else
  if mental then
   return unit.status.current_soul[attr].value
  else
   return unit.body.physical_attrs[attr].value
  end
 end
end

local function checkAttributes(unit,array,mental,unitTarget) -- CHECK 1
 local rtempa,itempa,r,i,required,immune = {},{},1,1,false,false
 local rtext = 'Targeting failed, ' .. tostring(unit.name.first_name) .. "'s attributes are too low."
 local itext = 'Targeting failed, ' .. tostring(unit.name.first_name) .. "'s attributes are too high."
 if type(array) ~= 'table' then array = {array} end
 for _,x in ipairs(array) do
  local utemp = getAttrValue(unit,split(x,':')[2],mental)
  if split(x,':')[1] == 'min' then
   if tonumber(split(x,':')[3]) >= utemp then
    rtempa[r] = true
   else
    rtempa[r] = false
   end
   r = r + 1
  elseif split(x,':')[1] == 'max' then
   if tonumber(split(x,':')[3]) <= utemp then
    itempa[r] = true
   else
    itempa[r] = false
   end
   i = i + 1
  elseif split(x,':')[1] == 'greater' then
   if utemp/getAttrValue(unitTarget,split(x,':')[2],mental) >= tonumber(split(x,':')[3]) then
    rtempa[r] = true
   else
    rtempa[r] = false
   end
   r = r + 1
  elseif split(x,':')[1] == 'less' then
   if utemp/getAttrValue(unitTarget,split(x,':')[2],mental) <= tonumber(split(x,':')[3]) then
    itempa[i] = true
   else
    itempa[i] = false
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
 if required and not immune then return false,itext end
 if required and immune then return true,'NONE' end
 if not required and immune then return false,rtext end
 if not required and not immune then return false,rtext end
end
M = checkAttributes

return M