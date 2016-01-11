--item/subtype-change.lua v1.0

local utils = require 'utils'
local split = utils.split_string

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
 'subtype',
 'dur',
 'upgrade',
 'downgrade',
 'track',
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
 print([[item/subtype-change.lua
  Change the subtype of an item
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
   -weapon SUBTYPE or ALL \
     change weapons       |
   -armor SUBTYPE or ALL  |
     change armor         |
   -helm SUBTYPE or ALL   |
     change helm          |
   -shoes SUBTYPE or ALL  |
     change shoes         | Must have at least one of these arguments
   -shield SUBTYPE or ALL |
     change shield        |
   -gloves SUBTYPE or ALL |
     change gloves        |
   -pants SUBTYPE or ALL  |
     change pants         |
   -ammo SUBTYPE or ALL   |
     change ammo          /
   -upgrade                                              \
     increase the number of the item SUBTYPE by 1        |
     (i.e. ITEM_WEAPON_DAGGER_1 -> ITEM_WEAPON_DAGGER_2) |
   -downgrade                                            |
     decrease the number of the item SUBTYPE by 1        | Must have one and only one of these arguments
     (i.e. ITEM_WEAPON_DAGGER_2 -> ITEM_WEAPON_DAGGER_1) |
   -subtype SUBTYPE                                         |
     change the item to the new SUBTYPE                  /
   -dur #
     length of time, in in-game ticks, for the quality change to last
     0 means the change is permanent
     DEFAULT: 0
  examples:
   item/subtype-change -unit \\UNIT_ID -weapon -upgrade -dur 1000
   item/subtype-change -type WEAPON:ITEM_WEAPON_GIANTS -subtype ITEM_WEAPON_GIANTS_WEAK -dur 1000
   item/subtype-change -unit \\UNIT_ID -armor -pants -helm -shoes -gloves -downgrade -dur 3600
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
 if tonumber(item) then
  item = df.item.find(tonumber(item))
 end
 local name = item.subtype.id
 local namea = split(name,'_')
 local num = tonumber(namea[#namea])
 if args.upgrade then
  num = num + 1
  namea[#namea] = tostring(num)
  subtype = table.concat(namea,'_')
 elseif args.downgrade then
  num = num - 1
  namea[#namea] = tostring(num)
  subtype = table.concat(namea,'_')
 elseif args.subtype then
  subtype = args.subtype
 else
  print('No subtype specified')
  return
 end
 dfhack.script_environment('functions/item').changeSubtype(item,subtype,dur,track)
end