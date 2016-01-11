local utils = require 'utils'

validArgs = validArgs or utils.invert({
 'help',
 'building',
 'unit',
 'item',
 'reagent',
 'type',
 'dur',
 'label',
})

local args = utils.processArgs({...}, validArgs)

if args.help then
print(
[[building/subtype-change.lua
 arguments:
  -help
   print this help message
  -building id
   specify the building to be removed
  -unit id
   specify the unit to use as location to find the building
  -item ids
   table of item ids to be added to the building
  -reagent codes
   table of reagent codes, used in conjunction with -label and -item
  -label code
   specific reagent code of item to be added to building
  -type TOKEN
   building to change the other into
  -dur #
   length of time in in-game ticks for the change to last, any items added will be removed
  -examples
   building/subtype-change -building \\BUILDING_ID -type NEW_BUILDING_ID -item [ \\INPUT_ITEMS ] -dur 1000
   building/subtpye-change -building \\BUILDING_ID -type NEW_BUILDING_ID -label add -item [ \\INPUT_ITEMS ] -reagent [ \\INPUT_REAGENTS ]
]])
return
end

if args.building then
 building = df.building.find(tonumber(args.building))
elseif args.unit then
 building = dfhack.buildings.findAtTile(df.unit.find(tonumber(args.unit)).pos)
else
 print('No unit or building declaration')
 return
end
if not building then print('No valid building') return end

if building.custom_type < 0 then print('Changing vanilla buildings not currently supported') return end
if not args.type then print('No specified subtype chosen') return end

dur = args.dur or 0

check = dfhack.script_environment('functions/building').changeSubtype(building,args.type,dur)

if check then
 if args.item and not args.label then
  for _,item in ipairs(args.item) do
   dfhack.script_environment('functions/building').addItem(building,item,dur)
  end
 end
 if args.label then
  if args.item and args.reagent then
   for i,code in ipairs(args.reagent) do
    if code == args.label then
     dfhack.script_environment('functions/building').addItem(building,args.item[i],dur)
    end
   end
  else
   print('When using a label, must provide both items and reagents')
   return
  end
 end
end
