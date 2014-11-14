local M = {}
split = require('split')
local function getValue(selected,targetList,unitSelf,unitTarget,svalue) -- CHECK 1
 local valuea = split(svalue,':')
 local value = tonumber(valuea[3])
 local inc = tonumber(valuea[4])
 local int32 = 200000000
 if valuea[1] == 'stacking' then
  if valua[2] == 'total' then
   value = value + inc*(#selected)
  elseif valuea[2] == 'allowed' then
   for _,x in ipairs(selected) do
    if x then value = value + inc end
   end
  elseif valuea[2] == 'immune' then
   for _,x in ipairs(selected) do
    if not x then value = value + inc end
   end
  else
   value = value
  end
 elseif valuea[1] == 'destacking' then
  if valua[2] == 'total' then
   value = value - inc*(#selected)
  elseif valuea[2] == 'allowed' then
   for _,x in ipairs(selected) do
    if x then value = value - inc end
   end
  elseif valuea[2] == 'immune' then
   for _,x in ipairs(selected) do
    if not x then value = value - inc end
   end
  else
   value = value
  end
 else
  if valuea[1] == 'self' then unitTarget = unitSelf end
  etype = valuea[2]
  if etype == 'strength' then
   value = unitTarget.body.physical_attrs.STRENGTH*value/100 + inc
  elseif etype == 'agility' then
   value = unitTarget.body.physical_attrs.AGILITY*value/100 + inc
  elseif etype == 'endurance' then
   value = unitTarget.body.physical_attrs.ENDURANCE*value/100 + inc
  elseif etype == 'toughness' then
   value = unitTarget.body.physical_attrs.TOUGHNESS*value/100 + inc
  elseif etype == 'resistance' then
   value = unitTarget.body.physical_attrs.DISEASE_RESISTANCE*value/100 + inc
  elseif etype == 'recuperation' then
   value = unitTarget.body.physical_attrs.RECUPERATION*value/100 + inc
  elseif etype == 'analytical' then
   value = unitTarget.status.current_soul.mental_attrs.ANALYTICAL_ABILITY*value/100 + inc
  elseif etype == 'focus' then
   value = unitTarget.status.current_soul.mental_attrs.FOCUS*value/100 + inc
  elseif etype == 'wlllpower' then
   value = unitTarget.status.current_soul.mental_attrs.WILLPOWER*value/100 + inc
  elseif etype == 'creativity' then
   value = unitTarget.status.current_soul.mental_attrs.CREATIVITY*value/100 + inc
  elseif etype == 'intuition' then
   value = unitTarget.status.current_soul.mental_attrs.INTUITION*value/100 + inc
  elseif etype == 'patience' then
   value = unitTarget.status.current_soul.mental_attrs.PATIENCE*value/100 + inc
  elseif etype == 'memory' then
   value = unitTarget.status.current_soul.mental_attrs.MEMORY*value/100 + inc
  elseif etype == 'linguistic' then
   value = unitTarget.status.current_soul.mental_attrs.LINGUISTIC_ABILITY*value/100 + inc
  elseif etype == 'spatial' then
   value = unitTarget.status.current_soul.mental_attrs.SPATIAL_SENSE*value/100 + inc
  elseif etype == 'musicality' then
   value = unitTarget.status.current_soul.mental_attrs.MUSICALITY*value/100 + inc
  elseif etype == 'kinesthetic' then
   value = unitTarget.status.current_soul.mental_attrs.KINESTHETIC_SENSE*value/100 + inc
  elseif etype == 'empathy' then
   value = unitTarget.status.current_soul.mental_attrs.EMPATHY*value/100 + inc
  elseif etype == 'social' then
   value = unitTarget.status.current_soul.mental_attrs.SOCIAL_AWARENESS*value/100 + inc
  elseif etype == 'web' then
   value = unitTarget.counters.webbed*value/100 + inc
  elseif etype == 'stun' then
   value = unitTarget.counters.stunned*value/100 + inc
  elseif etype == 'winded' then 
   value = unitTarget.counters.winded*value/100 + inc
  elseif etype == 'unconscious' then 
   value = unitTarget.counters.unconscious*value/100 + inc
  elseif etype == 'pain' then 
   value = unitTarget.counters.pain*value/100 + inc
  elseif etype == 'nausea' then 
   value = unitTarget.counters.nausea*value/100 + inc
  elseif etype == 'dizziness' then 
   value = unitTarget.counters.dizziness*value/100 + inc
  elseif etype == 'paralysis' then 
   value = unitTarget.counters.paralysis*value/100 + inc
  elseif etype == 'numbness' then 
   value = unitTarget.counters.numbness*value/100 + inc
  elseif etype == 'fever' then 
   value = unitTarget.counters.fever*value/100 + inc
  elseif etype == 'exhaustion' then 
   value = unitTarget.counters.exhaustion*value/100 + inc
  elseif etype == 'hunger' then 
   value = unitTarget.counters.hunger_timer*value/100 + inc
  elseif etype == 'thirst' then 
   value = unitTarget.counters.thirst_timer*value/100 + inc
  elseif etype == 'sleep' then 
   value = unitTarget.counters.sleepiness_timer*value/100 + inc
  elseif etype == 'infection' then 
   value = unitTarget.body.infection_level*value/100 + inc
  elseif etype == 'blood' then
   value = unitTarget.body.blood_count*value/100 + inc
  end
 end
 return value
end
M.getValue = getValue

return M