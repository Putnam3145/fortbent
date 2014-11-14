local M
split = require('split')
local function checkTypes(unit,class,creature,syndrome,token,immune) -- CHECK 1
 local unitraws = df.creature_raw.find(unit.race)
 local casteraws = unitraws.caste[unit.caste]
 local unitracename = unitraws.creature_id
 local castename = casteraws.caste_id
 local unitclasses = casteraws.creature_class
 local syndromes = df.global.world.raws.syndromes.all
 local actives = unit.syndromes.active
 local flags1 = unitraws.flags
 local flags2 = casteraws.flags
 local tokens = {}
 for k,v in pairs(flags1) do
  tokens[k] = v
 end
 for k,v in pairs(flags2) do
  tokens[k] = v
 end
 local tempa,ttempa,i,t,yes,no = {},{},1,1,false,false
 local yestext = 'Targeting failed, ' .. tostring(unit.name.first_name) .. ' is not an allowed type.'
 local notext = 'Targeting failed, ' .. tostring(unit.name.first_name) .. ' is an immune type.' 

 if class ~= 'NONE' then
  if type(class) ~= 'table' then class = {class} end
  for _,unitclass in ipairs(unitclasses) do
   for _,x in ipairs(class) do
    if x == unitclass.value then
     tempa[i] = true
    else
     tempa[i] = false
    end
    i = i + 1
   end
  end
 end
 if creature ~= 'NONE' then
  if type(creature) ~= 'table' then creature = {creature} end
  for _,x in ipairs(creature) do
   local xsplit = split(x,':')
   if xsplit[1] == unitracename and xsplit[2] == castename then
    tempa[i] = true
   else
    tempa[i] = false
   end
   i = i + 1
  end
 end
 if syndrome ~= 'NONE' then
  if type(syndrome) ~= 'table' then syndrome = {syndrome} end
  for _,x in ipairs(actives) do
   local synclass=syndromes[x.type].syn_class
   for _,y in ipairs(synclass) do
    for _,z in ipairs(syndrome) do
     if z == y.value then
      tempa[i] = true
     else
      tempa[i] = false
     end
     i = i + 1
    end
   end
  end
 end
 if token ~= 'NONE' then
  if type(token) ~= 'table' then token = {token} end
  for _,x in ipairs(token) do
   ttempa[t] = tokens[x]
   t = t + 1       
  end
 end

 for _,x in ipairs(tempa) do
  if immune then
   if x then no = true end
  else
   if x then yes = true end
  end
 end
 for _,x in ipairs(ttempa) do
  if immune then
   if x then no = true end
  else
   if not x then 
    yes = false
    break
   else
    yes = true
   end
  end
 end
 if immune then
  if no then return false,notext end
 else
  if not yes then return false,yestext end
 end
 return true,'NONE'
end
M = checkTypes

return M