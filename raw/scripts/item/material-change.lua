--item/material-change.lua v1.0

local utils = require 'utils'

validArgs = validArgs or utils.invert({
 'help',
 'unit',
 'item',
 'weapon',
 'armor',
 'helm',
 'shoes',
 'shield',
 'gloves',
 'pants',
 'ammo',
 'mat',
 'dur',
 'track',
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
 print([[item/material-change.lua
  Change the material a equipped item is made out of
  arguments:
   -help
     print this help message
   -unit id                   \
     id of the target unit    |
   -item id                   | Must have one and only one of them
     id of the target item    /
   -weapon          \
     change weapons |
   -armor           |
     change armor   |
   -helm            |
     change helm    |
   -shoes           |
     change shoes   | Must have at least one of these arguments if using -unit
   -shield          |
     change shield  |
   -gloves          |
     change gloves  |
   -pants           |
     change pants   |
   -ammo            |
     change ammo    /
   -mat matstring
     specify the material of the item to be changed to
     examples:
      INORGANIC:IRON
      CREATURE_MAT:DWARF:BRAIN
      PLANT_MAT:MUSHROOM_HELMET_PLUMP:DRINK
   -dur #
     length of time, in in-game ticks, for the material change to last
     0 means the change is permanent
     DEFAULT: 0
  examples:
   item/material-change -unit \\UNIT_ID -weapon -ammo -mat INORGANIC:IMBUE_FIRE -dur 3600
   item/material-change -unit \\UNIT_ID -armor -helm -shoes -pants -gloves -mat INORGANIC:IMBUE_STONE -dur 1000
   item/material-change -unit \\UNIT_ID -shield -mat INORGANIC:IMBUE_AIR
 ]])
 return
end

if args.unit and tonumber(args.unit) then
 unit = df.unit.find(tonumber(args.unit))
 local types = {}
 if args.weapon then types[1] = 'WEAPON' end
 if args.armor then types[2] = 'ARMOR' end
 if args.helm then types[3] = 'HELM' end
 if args.shoes then types[4] = 'SHOES' end
 if args.shield then types[5] = 'SHIELD' end
 if args.gloves then types[6] = 'GLOVES' end
 if args.pants then types[7] = 'PANTS' end
 if args.ammo then types[8] = 'AMMO' end
 items = dfhack.script_environment('functions/unit').checkInventoryType(unit,types)
else
 if args.item and tonumber(args.item) then
  items = {df.item.find(tonumber(args.item))}
 else
  print('No unit or item selected')
  return
 end
end

dur = tonumber(args.dur) or 0
track = nil
if args.track then track = 'track' end

for _,item in pairs(items) do
 dfhack.script_environment('functions/item').changeMaterial(item,args.mat,dur,track)
end
