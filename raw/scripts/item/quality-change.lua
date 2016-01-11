
local utils = require 'utils'

validArgs = validArgs or utils.invert({
 'help',
 'unit',
 'item',
 'type',
 'weapon',
 'armor',
 'helm',
 'shoes',
 'shield',
 'gloves',
 'pants',
 'ammo',
 'quality',
 'dur',
 'upgrade',
 'downgrade',
 'track',
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
 print([[item/subtype-change.lua
  Change the quality of an item
  arguments:
   -help
     print this help message
   -unit id                                              \
     id of the target unit inventory to check            |
   -item id                                              |
     id of the target item                               |
   -type itemstr                                         | Must have one and only one of these arguments
     specify the itemdef of the item to be checked for   |
     examples:                                           |
      WEAPON:ITEM_WEAPON_PICK                            |
      AMMO:ITEM_AMMO_BOLT                                /
   -weapon                \
     change weapons       |
   -armor                 |
     change armor         |
   -helm                  |
     change helm          |
   -shoes                 |
     change shoes         | Must have at least one of these arguments when using -unit
   -shield                |
     change shield        |
   -gloves                |
     change gloves        |
   -pants                 |
     change pants         |
   -ammo                  |
     change ammo          /
   -upgrade                                 \
     upgrade the quality of the item by 1   |
   -downgrade                               |
     downgrade the quality of the item by 1 | Must have one and only one of these arguments
   -quality #                               |
     set the quality to a specified level   /
   -dur #
     length of time, in in-game ticks, for the quality change to last
     0 means the change is permanent
     DEFAULT: 0
  examples:
   item/quality-change -unit \\UNIT_ID -weapon -quality 6 -dur 1000
   item/quality-change -type WEAPON:ITEM_WEAPON_GIANTS -downgrade
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
elseif args.item and tonumber(args.item) then
 items = {df.item.find(tonumber(args.item))}
elseif args.type then
 local itemType = dfhack.items.findType(args.type)
 if itemType == -1 then
  print('Invalid item')
  return
 end
 local itemSubtype = dfhack.items.findSubtype(args.type)
 local itemList = df.global.world.items.all
 local k = 1
 for i,x in ipairs(itemList) do
   if x:getType() == itemType and x:getSubtype() == itemSubtype then
   items[k] = itemList[i]
   k = k + 1
  end
 end
else
 print('No unit or item selected')
 return
end

dur = tonumber(args.dur) or 0
track = nil
if args.track then track = 'track' end

for _,item in pairs(items) do
 if args.upgrade then
  quality = item.quality + 1
 elseif args.downgrade then
  quality = item.quality - 1
 elseif args.quality then
  quality = tonumber(args.quality)
 else
  print('No quality specified')
  return
 end
 dfhack.script_environment('functions/item').changeQuality(item,quality,dur,track)
end
