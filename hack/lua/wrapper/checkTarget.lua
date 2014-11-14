local M
split = require('split')
local function checkTarget(unit,target,unitCaster) -- CHECK 1
 sel = true
 if target == 'invasion' then
  if unit.invasion_id ~= unitCaster.invasion_id then sel = false end
 elseif target == 'civ' then
  if unit.civ_id ~= unitCaster.civ_id then sel = false end
 elseif target == 'population' then
  if unit.population_id ~= unitCaster.population_id then sel = false end
 elseif target == 'race' then
  if unit.race ~= unitCaster.race then sel = false end
 elseif target == 'sex' then
  if unit.sex ~= unitCaster.sex then sel = false end
 elseif target == 'caste' then
  if unit.race ~= unitCaster.race or unit.caste ~= unitCaster.caste then sel = false end
 end
 return sel, ''
end

M = checkTarget

return M