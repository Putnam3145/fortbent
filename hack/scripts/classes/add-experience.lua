
local split = require('split')
local utils = require 'utils'
local establishclass = require('classes.establish-class')
local persistTable = require 'persist-table'
 
 
function addexperience(unit,amount)
 local kill_id = unit
 if kill_id >=0 then
  exps = amount
--  print('Add Experience to unit '..tostring(kill_id)..'. In the amount of '..tostring(amount))
  local unitClasses = persistTable.GlobalTable.roses.UnitTable[tostring(kill_id)]['Classes']
  local currentClass = persistTable.GlobalTable.roses.UnitTable[tostring(kill_id)]['Classes']['Current']
  local classes = persistTable.GlobalTable.roses.ClassTable
  currentClass['CurrentExp'] = tostring(tonumber(currentClass['CurrentExp'])+exps)
  currentClass['TotalExp'] = tostring(tonumber(currentClass['TotalExp'])+exps)
  currentClass['SkillExp'] = tostring(tonumber(currentClass['SkillExp'])+exps)
  --print(kill_name..' '..tostring(kill_id)..' killed '..name..' '..tostring(unit_id)..' and earned '..tostring(exps)..' experience. Total experience is '..persistTable.GlobalTable.roses.UnitTable[tostring(kill_id)]['Classes']['Current']['TotalExp']))
  if currentClass['Name'] ~= 'None' then
   local currentClassName = currentClass['Name']
   local currentClassLevel = tonumber(unitClasses[currentClassName]['Level'])
   if currentClassLevel < tonumber(classes[currentClassName]['Levels']) then
	classExpLevel = tonumber(split(classes[currentClassName]['Experience'][currentClassLevel+1],']')[1])
    if tonumber(currentClass['CurrentExp']) >= classExpLevel then
     print('LEVEL UP!! '..currentClassName..' LEVEL '..tostring(tonumber(currentClassLevel)+1))
	 dfhack.run_script('classes/level-up',table.unpack({'-unit',tostring(kill_id)}))
	end
   end
  end
 end
end

validArgs = validArgs or utils.invert({
 'help',
 'unit',
 'amount',
})
local args = utils.processArgs({...}, validArgs)

unit = df.unit.find(tonumber(args.unit))
establishclass(unit)
addexperience(tonumber(args.unit),tonumber(args.amount))