
local split = require('split')
local utils = require 'utils'

function getAttrValue(unit,attr,mental)
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

function findUnitSyndrome(unit,syn_id)
 for index,syndrome in ipairs(unit.syndromes.active) do
  if syndrome['type'] == syn_id then
   return syndrome
  end
 end
 return nil
end

function checkrequirements(unit,spell,classes)
 key = tostring(unit.id)
 yes = true
 curpers,status = dfhack.persistent.get(key..'_current_class')
 curclass = curpers.value
 found = false
 if classes[curclass]['SPELL'] then
  for j,y in pairs(classes[curclass]['SPELL']) do
   if spell == j then
    found = true
    if y['REQUIRED_LEVEL'] == 'AUTO' then
     yes = false
 	print('This spell should have been learned automatically, no need to learn via reaction.')
    else
     pers,status = dfhack.persistent.get(key..'_'..curclass)
 	if pers.ints[2] < tonumber(y['REQUIRED_LEVEL']) then
      print('Class requirements not met. '..curclass..' level '..y['REQUIRED_LEVEL']..' needed. Current level is '..tostring(pers.ints[2]))
      yes = false	
 	end
    end
    if y['R_PHYS'] and yes then
     for i,x in pairs(y['R_PHYS']) do
      curstat = getAttrValue(unit,i,false)
      if curstat < tonumber(x) then
       print('Stat requirements not met. '..x..' '..i..' needed. Current amount is '..tostring(curstat))
       yes = false
      end
     end
    end
    if y['R_MENT'] and yes then
     for i,x in pairs(y['R_MENT']) do
      curstat = getAttrValue(unit,i,true)
      if curstat < tonumber(x) then
       print('Stat requirements not met. '..x..' '..i..' needed. Current amount is '..tostring(curstat))
       yes = false
      end
     end
    end
    if y['F_SPELL'] and yes then
     for _,syn in ipairs(df.global.world.raws.syndromes.all) do
      for i,x in pairs(y['F_SPELL']) do
       if syn.syn_name == x then
        oldsyndrome = findUnitSyndrome(unit,syn.id)
        if oldsyndrome then
	     print('Knows a forbidden spell. '..x)
		 yes = false
	    end
	   end
	  end
	 end
    end	
    if y['F_CLASS'] and yes then
     for i,x in pairs(y['F_CLASS']) do
      pers,status = dfhack.persistent.get(key..'_'..i)
      if pers.ints[2] >= tonumber(x) and tonumber(x) ~= 0 then
       print('Already a member of a forbidden class. '..i)
       yes = false
      elseif tonumber(x) == 0 and pers.ints[1] > 0 then
       print('Already a member of a forbidden class. '..i)
       yes = false   
      end
     end
    end
    if y['COST'] and yes then
     pers,status = dfhack.persistent.get(key..'_current_class')
	 if pers.ints[3] >= tonumber(y['COST']) then
	  pers.ints[3] = pers.ints[3] - tonumber(y['COST'])
	  dfhack.persistent.save({key=key..'_current_class',value=pers.value,ints=pers.ints})
	 else
	  print('Not enough points to learn spell')
	  yes = false
	 end
	end
    if y['UPGRADE'] then upgrade = y['UPGRADE'] end
    break
   end
  end
 end
 if not found then
  print(spell..' not learnable by '..curclass)
  return false, upgrade
 else
  return yes, upgrade
 end
end

return checkrequirements