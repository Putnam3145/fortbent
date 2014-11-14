
local split = require('split')
local utils = require 'utils'
local establishclass = require('classes.establish-class')
local read_file = require('classes.read-file')
local checkspell = require('classes.requirements-spell')

function findUnitSyndrome(unit,syn_id)
 for index,syndrome in ipairs(unit.syndromes.active) do
  if syndrome['type'] == syn_id then
   return syndrome
  end
 end
 return nil
end

function learnspell(unit,spell,classes,upgrade)
 local syndrome
 for _,syn in ipairs(df.global.world.raws.syndromes.all) do
  if syn.syn_name == spell then
   syndrome = syn
   break
  end
 end
 oldsyndrome = findUnitSyndrome(unit,syndrome.id)
 if oldsyndrome then
  print('Already knows this spell')
  return false
 end
 if upgrade then
  dfhack.run_script('modtools/add-syndrome',table.unpack({'-target',tostring(unit.id),'-syndrome',spell}))
  dfhack.run_script('modtools/add-syndrome',table.unpack({'-target',tostring(unit.id),'-syndrome',upgrade,'-eraseAll'}))
 else
  dfhack.run_script('modtools/add-syndrome',table.unpack({'-target',tostring(unit.id),'-syndrome',spell}))
 end
 print(spell..' learned successfully!')
 return true
end

file = dfhack.getDFPath().."/raw/objects/classes.txt"
classes = read_file(file)

validArgs = validArgs or utils.invert({
 'help',
 'unit',
 'spell',
})
local args = utils.processArgs({...}, validArgs)

unit = df.unit.find(tonumber(args.unit))

establishclass(unit,classes)
yes,upgrade = checkspell(unit,args.spell,classes)
if yes then 
 success = learnspell(unit,args.spell,classes,upgrade)
 if success then
 -- Erase items used for reaction
 end
end