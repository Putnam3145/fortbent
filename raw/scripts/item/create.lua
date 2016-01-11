--item/create.lua v1.0
--author expwnent, modified by roses
--creates an item of a given type and material

local utils = require 'utils'

validArgs = validArgs or utils.invert({
 'help',
 'creator',
 'material',
 'item',
 'matchingGloves',
 'matchingShoes',
 'dur',
 'quality',
})

local args = utils.processArgs({...}, validArgs)

if args.help then
 print(
[[item/create.lua
arguments:
    -help
        print this help message
    -creator id
        specify the id of the unit who will create the item
        examples:
            0
            2
    -material matstring
        specify the material of the item to be created
        examples:
            INORGANIC:IRON
            CREATURE_MAT:DWARF:BRAIN
            PLANT_MAT:MUSHROOM_HELMET_PLUMP:DRINK
    -item itemstr
        specify the itemdef of the item to be created
        examples:
            WEAPON:ITEM_WEAPON_PICK
    -matchingShoes
        create two of this item
    -matchingGloves
        create two of this item, and set handedness appropriately
    -dur #
        length of time, in in-game ticks, for the item to exist
        0 means the item is permanent
        DEFAULT: 0
 ]])
 return
end

local item1 = dfhack.script_environment('functions/item').create(args.item,args.material,{creator=args.creator,quality=args.quality,dur=args.dur})
if args.matchingGloves or args.matchingShoes then
 if args.matchingGloves then
  item1 = df.item.find(item1)
  item1:setGloveHandedness(1);
 end
 local item2 = dfhack.script_environment('functions/item').create(args.item,args.material,{creator=args.creator,quality=args.quality,dur=args.dur})
 if args.matchingGloves then
  item2 = df.item.find(item2)
  item2:setGloveHandedness(2);
 end
end