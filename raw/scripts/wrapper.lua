local utils = require 'utils'

validArgs = validArgs or utils.invert({
 'help',
 'unitSource',
 'unitTarget',
 'locTarget',
 'locCheck',
 'script',
 'chain',
 'value',
 'maxtargets',
 'delay',
 'radius',
 'target',
 'rclass',
 'rcreature',
 'rsyndrome',
 'rtoken',
 'rnoble',
 'rprofession',
 'rentity',
 'iclass',
 'icreature',
 'isyndrome',
 'itoken',
 'inoble',
 'iprofession',
 'ientity',
 'maxphysical',
 'maxmental',
 'maxskills',
 'maxtraits',
 'maxage',
 'maxspeed',
 'minphysical',
 'minmental',
 'minskills',
 'mintraits',
 'minage',
 'minspeed',
 'reflect',
 'silence',
 'center',
})
local args = utils.processArgs({...}, validArgs)

if not args.script then
 print('No script provided to run')
 return
end
if not string.find(args.script[1],' ') then args.script = {table.concat(args.script, ' ')} end

if args.unitSource and tonumber(args.unitSource) and df.unit.find(tonumber(args.unitSource)) then
 source = df.unit.find(tonumber(args.unitSource))
else
 print('No valid source unit declared')
 return
end

-- Check if the casting unit is silenced
if args.silence then
 if dfhack.script_environment('functions/unit').checkClass(source,args.silence) then
  print('unit is prevented from using interaction (SILENCED)')
  return
 end
end

args.chain = tonumber(args.chain) or 0
args.maxTargets = tonumber(args.maxTargets) or 0
args.delay = tonumber(args.delay) or 0
 
if ((args.unitTarget and tonumber(args.unitTarget) and df.unit.find(tonumber(args.unitTarget))) or args.center) and not args.locTarget then
 center = target

 if args.center then
  center = source
 end

 for count = 0, args.chain, 1 do
  if count >= 0 then
 -- Step 1: Check for reflection
   if args.reflect then
    if dfhack.script_environment('functions/unit').checkClass(target,args.reflect) then
     save = source
     source = center
     center = save
    end
   end
 -- Step 2: Determine targets based on location and spell target
   targetList,n = dfhack.script_environment('functions/wrapper').checkLocation(center,args.radius)
   targetList,n = dfhack.script_environment('functions/wrapper').checkTarget(source,targetList,args.target)
 -- Step 3: Determine eligible targets from list based on age/speed/attributes/skills/etc...
   selected = {}
   for n,unit in pairs(targetList) do
    selected[n] = dfhack.script_environment('functions/wrapper').isSelected(source,unit,args)
   end
 -- Step 4: Pick targets from eligible list (between 1 and args.maxTargets)
   targets,i = {},0
   for n,unit in pairs(targetList) do
    if selected[n] then
     i = i + 1
     targets[i] = unit
    end
   end
   if i == 0 then return end
   if args.maxTargets == 0 or args.maxTargets >= i then
    targets = targets
   else
    targets = dfhack.script_environment('functions/misc').permute(targets)
    targets = {selected(#targets-args.maxTargets+1,table.unpack(targets))}
   end
 -- Step 5: Run Scripts
   for _,unit in ipairs(targets) do
    for _,script in ipairs(args.script) do
     script = script:gsub('\\TARGET',tostring(unit.id))
     script = script:gsub('\\SOURCE',tostring(source.id))
     script = script:gsub('\\CENTER',tostring(center.id))
     if args.value then
      if type(args.value) ~= 'table' then args.value = {args.value} end
      for n,equation in pairs(args.value) do
       script = script:gsub('\\VALUE_'..tostring(n),dfhack.script_environment('functions/wrapper').getValue(equation,unit,source,center,targetList,selected))
      end
     end
     if args.delay == 0 then
      dfhack.run_command(script)
     else
      dfhack.script_environment('persist-delay').delayCommand(script)
     end
    end
   end
   center = targets[1]
  end
 end
elseif args.locTarget then
 if args.unitTarget and tonumber(args.unitTarget) and df.unit.find(tonumber(args.unitTarget)) then
  center = df.unit.find(tonumber(args.unitTarget))
 else
  center = source
 end
 if type(args.locTarget) == 'table' then
  if args.radius then
   positions = dfhack.script_environment('functions/map').getFillPosition(args.locTarget,args.radius)
  else
   positions = {{x=args.locTarget[1],y=args.locTarget[2],z=args.locTarget[3]}}
  end
 elseif tonumber(args.locTarget) then
  if args.radius then
   positions = dfhack.script_environment('functions/map').getFillPosition(df.unit.find(tonumber(args.locTarget)).pos,args.radius)
  else
   positions = {df.unit.find(tonumber(args.locTarget)).pos}
  end
 elseif type(args.locTarget) == 'string' then
  positions = dfhack.script_environment('functions/map').getPositionPlan(args.locTarget,center,source)
 end
 if args.locCheck == 'unit' then
 elseif args.locCheck == 'tile' then
 end
 for _,pos in ipairs(positions) do
  for _,script in ipairs(args.script) do
   script = script:gsub('\\LOCATION',"[ "..tostring(pos.x).." "..tostring(pos.y).." "..tostring(pos.z).." ]")
   script = script:gsub('\\TARGET',"[ "..tostring(center.pos.x).." "..tostring(center.pos.y).." "..tostring(center.pos.z).." ]")
   script = script:gsub('\\SOURCE',"[ "..tostring(source.pos.x).." "..tostring(source.pos.y).." "..tostring(source.pos.z).." ]")
   if args.value then
    if type(args.value) ~= 'table' then args.value = {args.value} end
    for n,equation in pairs(args.value) do
     script = script:gsub('\\VALUE_'..tostring(n),dfhack.script_environment('functions/wrapper').getValue(equation,unit,source,center,targetList,selected))
    end
   end
   if args.delay == 0 then
    dfhack.run_command(script)
   else
    dfhack.script_environment('persist-delay').delayCommand(script)
   end
  end
 end
end