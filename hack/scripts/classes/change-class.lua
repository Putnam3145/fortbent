
local split = require('split')
local utils = require 'utils'
local establishclass = require('classes.establish-class')
local read_file = require('classes.read-file')
local checkclass = require('classes.requirements-class')
local checkspell = require('classes.requirements-spell')

function changeclass(unit,change,classes)
 key = tostring(unit.id)
-- Change the units class
 curpers,status = dfhack.persistent.get(key..'_current_class')
 curclass = curpers.value
 nexpers,status = dfhack.persistent.get(key..'_'..change)

 if curclass == change then
  print('Already this class')
  return false
 end
 curclass_exp = curpers.ints[1]
 if curclass ~= 'NONE' then
  pers,status = dfhack.persistent.get(key..'_'..curclass)
  pers.ints[1] = pers.ints[1] + curclass_exp
  curlevel = pers.ints[2]
  dfhack.persistent.save({key=key..'_'..curclass,value=pers.value,ints=pers.ints})
  dfhack.run_script("modtools/add-syndrome",table.unpack({"-target",key,"-syndrome",curclass,"-eraseAll"}))
  if classes[curclass]['B_PHYS'] then
   for i,x in pairs(classes[curclass]['B_PHYS']) do
    dfhack.run_script('unit/attribute-change',table.unpack({'-unit',key,'-physical',i,'-fixed','\\'..tostring(-tonumber(split(x[curlevel+1],']')[1]))}))
   end
  end
  if classes[curclass]['B_MENT'] then
   for i,x in pairs(classes[curclass]['B_MENT']) do
    dfhack.run_script('unit/attribute-change',table.unpack({'-unit',key,'-mental',i,'-fixed','\\'..tostring(-tonumber(split(x[curlevel+1],']')[1]))}))
   end
  end
  if classes[curclass]['B_SKILL'] then
   for i,x in pairs(classes[curclass]['B_SKILL']) do
    dfhack.run_script('unit/skill-change',table.unpack({'-unit',key,'-skill',i,'-fixed','\\'..tostring(-tonumber(split(x[curlevel+1],']')[1]))}))
   end
  end
  if classes[curclass]['B_TRAIT'] then
   for i,x in pairs(classes[curclass]['B_TRAIT']) do
    dfhack.run_script('unit/trait-change',table.unpack({'-unit',key,'-trait',i,'-fixed','\\'..tostring(-tonumber(split(x[curlevel+1],']')[1]))}))
   end
  end
 end
 curpers.value = change
 curpers.ints[1] = nexpers.ints[1]
 curlevel = nexpers.ints[2]
 dfhack.persistent.save({key=key..'_current_class',value=curpers.value,ints=curpers.ints})
 dfhack.persistent.save({key=key..'_'..change,value=nexpers.value,ints=nexpers.ints})
 dfhack.run_script("modtools/add-syndrome",table.unpack({"-target",key,"-syndrome",change}))
 if classes[change]['B_PHYS'] then
  for i,x in pairs(classes[change]['B_PHYS']) do
   dfhack.run_script('unit/attribute-change',table.unpack({'-unit',key,'-physical',i,'-fixed','\\'..tostring(tonumber(split(x[curlevel+1],']')[1]))}))
  end
 end
 if classes[change]['B_MENT'] then
  for i,x in pairs(classes[change]['B_MENT']) do
   dfhack.run_script('unit/attribute-change',table.unpack({'-unit',key,'-mental',i,'-fixed','\\'..tostring(tonumber(split(x[curlevel+1],']')[1]))}))
  end
 end
 if classes[change]['B_SKILL'] then
  for i,x in pairs(classes[change]['B_SKILL']) do
   dfhack.run_script('unit/skill-change',table.unpack({'-unit',key,'-skill',i,'-fixed','\\'..tostring(tonumber(split(x[curlevel+1],']')[1]))}))
  end
 end
 if classes[change]['B_TRAIT'] then
  for i,x in pairs(classes[change]['B_TRAIT']) do
   dfhack.run_script('unit/trait-change',table.unpack({'-unit',key,'-trait',i,'-fixed','\\'..tostring(tonumber(split(x[curlevel+1],']')[1]))}))
  end
 end
 if classes[change]['SPELL'] then
  for i,x in pairs(classes[change]['SPELL']) do
   for j,y in pairs(x) do
    if j == 'REQUIRED_LEVEL' and y == 'AUTO' then
     if checkspell(unit,i,classes) then
	  dfhack.run_script("modtools/add-syndrome",table.unpack({'-target',key,'syndrome',i,'-resetPolicy','DoNothing'}))
	 end
	end
   end
  end
 end
 print('Class change successful. Changed from '..curclass..' to '..change..'.')
 return true
end

file = dfhack.getDFPath().."/raw/objects/classes.txt"
classes = read_file(file)

validArgs = validArgs or utils.invert({
 'help',
 'unit',
 'class',
})
local args = utils.processArgs({...}, validArgs)

unit = df.unit.find(tonumber(args.unit))

establishclass(unit,classes)
yes = checkclass(unit,args.class,classes)
if yes then 
 success = changeclass(unit,args.class,classes)
 if success then
 -- Erase items used for reaction
 end
end