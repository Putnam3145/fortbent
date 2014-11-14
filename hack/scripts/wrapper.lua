--wrapper_test.lua v0.1
isSelected = require('wrapper.isSelected')
getValue = require('wrapper.getValue')
local split = require('split')
local utils = require 'utils'

function permute(tab)
 math.randomseed()
 math.random()
 n = #tab
 for i = 1, n do
  local j = math.random(i, n)
  tab[i], tab[j] = tab[j], tab[i]
 end
 return tab
end
function callback(script)
 return function (delayTrigger)
  dfhack.run_script(script[1],select(2,table.unpack(script)))
 end
end

function scriptRun(args)
 maxtargets = tonumber(args.maxtargets) or 0
 delay = tonumber(args.delay) or 0
 
 for count = 0, tonumber(args.chain) or 0, 1 do
  unit1 = df.unit.find(tonumber(args.unitSource))
  if count == 0 then unit2 = unit1 end
  if count == 0 then unit3 = df.unit.find(tonumber(args.unitTarget)) end
  if count > 0 then unit2 = unit3 end
  if count > 0 then unit3 = ctargets[math.random(1,#ctargets)] end
  local selected,targetList,unitSelf,verbose,announcement = isSelected(unit1,unit2,unit3,args,count)

  local targets = {}
  local nn = 1
  if maxtargets == 0 then
   for i,x in ipairs(targetList) do
    if selected[i] then
     targets[nn] = x
     nn = nn + 1
    end
   end
  else
   local temptargets = {}
   for i,x in ipairs(targetList) do
    if selected[i] then
     temptargets[nn] = x
     nn = nn + 1
    end
   end
   if maxtargets > #temptargets then maxtargets = #temptargets end
   temptargets = permute(temptargets)
   for i = 1,maxtargets,1 do
    targets[i] = temptargets[i]    
   end
  end
  ctargets = targets
  if args.center then targets = {unit3} end
  printall(targets)
  for j,y in ipairs(targets) do
   script = {}
   for k,z in ipairs(args.script) do
    if z == '!TARGET' then 
	 script[k] = y.id
    elseif z == '!LOCATION' then 
	 script[k] = y.pos
    elseif z == '!SOURCE' then 
	 script[k] = unit1.id
	elseif z == '!CENTER' then 
	 script[k] = unit2.id
    elseif z == '!VALUE' then 
	 script[k] = getValue(selected,targetList,unitSelf,y,args.value)
	else 
	 script[k] = z
	end
   end
   if delay == 0 then 
    dfhack.run_script(script[1],select(2,table.unpack(script)))
   else
    dfhack.timeout(delay,'ticks',callback(script))
   end
  end
 end
end

validArgs = validArgs or utils.invert({
 'help',
 'unitTarget',
 'unitSource',
 'script',
 'chain',
 'value',
 'maxtargets',
 'delay',
 'radius',
 'target',
 'aclass',
 'acreature',
 'asyndrome',
 'atoken',
 'iclass',
 'icreature',
 'isyndrome',
 'itoken',
 'physical',
 'mental',
 'skills',
 'traits',
 'age',
 'speed',
 'noble',
 'profession',
 'entity',
 'reflect',
 'silence',
 'counters',
 'plan',
 'self',
 'verbose',
 'los',
 'center',
})
local args = utils.processArgs({...}, validArgs)

scriptRun(args)

