
local split = require('split')
local utils = require 'utils'
local establishclass = require('classes.establish-class')
local read_file = require('classes.read-file')
local checkclass = require('classes.requirements-class')
local checkspell = require('classes.requirements-spell')

function addexperience(unit,amount,classes)
 kill_id = unit
 if kill_id >=0 then
  exps = amount
  pers,status = dfhack.persistent.get(tostring(kill_id)..'_current_class')
  pers.ints[1] = pers.ints[1] + exps
  pers.ints[2] = pers.ints[2] + exps
  if pers.value ~= 'NONE' then
   cpers,status = dfhack.persistent.get(tostring(kill_id)..'_'..pers.value)
   clevel = cpers.ints[2]
   if clevel < classes[pers.value]['LEVELS'] then
    cexp = tonumber(split(classes[pers.value]['EXP'][clevel+1],']')[1])
    if pers.ints[2] > cexp then
     cpers.ints[2] = cpers.ints[2] + 1
      print('LEVEL UP!! '..pers.value..' LEVEL '..tostring(cpers.ints[2]))
      if classes[pers.value]['B_PHYS'] then
       for i,x in pairs(classes[pers.value]['B_PHYS']) do
        dfhack.run_script('unit/attribute-change',table.unpack({'-unit',tostring(kill_id),'-physical',i,'-fixed','\\'..tostring(tonumber(split(x[cpers.ints[2]+1],']')[1])-tonumber(split(x[cpers.ints[2]],']')[1]))}))
       end
      end
      if classes[pers.value]['B_MENT'] then
       for i,x in pairs(classes[pers.value]['B_MENT']) do
        dfhack.run_script('unit/attribute-change',table.unpack({'-unit',tostring(kill_id),'-mental',i,'-fixed','\\'..tostring(tonumber(split(x[cpers.ints[2]+1],']')[1])-tonumber(split(x[cpers.ints[2]],']')[1]))}))
       end
      end
      if classes[pers.value]['B_SKILL'] then
       for i,x in pairs(classes[pers.value]['B_SKILL']) do
        dfhack.run_script('unit/skill-change',table.unpack({'-unit',tostring(kill_id),'-skill',i,'-fixed','\\'..tostring(tonumber(split(x[cpers.ints[2]+1],']')[1])-tonumber(split(x[cpers.ints[2]],']')[1]))}))
       end
      end
      if classes[pers.value]['B_TRAIT'] then
       for i,x in pairs(classes[pers.value]['B_TRAIT']) do
        dfhack.run_script('unit/trait-change',table.unpack({'-unit',tostring(kill_id),'-trait',i,'-fixed','\\'..tostring(tonumber(split(x[cpers.ints[2]+1],']')[1])-tonumber(split(x[cpers.ints[2]],']')[1]))}))
       end
      end
      if cpers.ints[2] == classes[pers.value]['LEVELS'] then 
	   print('REACHED MAX LEVEL FOR CLASS '..pers.value)
	   if classes[pers.value]['A_UPGRADE'] then dfhack.run_script('classes/change-class',table.unpack({'-unit',tostring(kill_id),'-class',classes[pers.value]['A_UPGRADE']})) end
	  end
     end
    end
   dfhack.persistent.save({key=tostring(kill_id)..'_'..cpers.value,value=cpers.value,ints=cpers.ints})
  end
 end
end

file = dfhack.getDFPath().."/raw/objects/classes.txt"
classes = read_file(file)

validArgs = validArgs or utils.invert({
 'help',
 'unit',
 'amount',
})
local args = utils.processArgs({...}, validArgs)

establishclass(unit,classes)
addexperience(tonumber(args.unit),tonumber(args.amount),classes)