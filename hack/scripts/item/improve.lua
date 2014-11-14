--item/improve.lua v1.0

local split = require('split')
local utils = require 'utils'

function createcallback(x,sid)
 return function(resetitem)
  x:setQuality(sid)
 end
end
function upgradeitem(args,v,unit,dur,subtype)
 local sitems = {}
 if args.equipped and args.unit then
-- Upgrade only the input items with preserve reagent
  local inv = unit.inventory
  local j = 1
  for i,x in ipairs(inv) do
   if (v:is_instance(x.item) and (x.item.subtype.id == subtype or subtype == 'ALL')) then
    sitems[j] = x.item
    j = j+1
   end
  end
 elseif args.all then
-- Upgrade all items of the same type as input
  local itemList = df.global.world.items.all
  local k = 1
  for i,x in ipairs(itemList) do
   if (v:is_instance(x) and (x.subtype.id == subtype or subtype == 'ALL')) then 
    sitems[k] = itemList[i] 
    k = k + 1
   end
  end
 else
-- Randomly upgrade one specific item
  local itemList = df.global.world.items.all
  local k = 1
  for i,x in ipairs(itemList) do
   if (v:is_instance(x) and (x.subtype.id == subtype or subtype == 'ALL')) then 
    sitems[k] = itemList[i] 
    k = k + 1
   end
  end
  local rando = dfhack.random.new()
  sitems = {sitems[rando:random(#sitems)]}
 end

 if args.upgrade then
-- Increase items number by one
  for _,x in ipairs(sitems) do
   sid = x.quality
   x:setQuality(sid+1)
   if dur > 0 then dfhack.timeout(dur,'ticks',createcallback(x,sid)) end
  end
 elseif args.downgrade then
-- Decrease items number by one
  for _,x in ipairs(sitems) do
   sid = x.quality
   x:setQuality(sid-1)
   if dur > 0 then dfhack.timeout(dur,'ticks',createcallback(x,sid)) end
  end
 else
-- Change item to new quality
  for _,x in ipairs(sitems) do
   sid = x.quality
   x:setQuality(tonumber(args.quality))
   if dur > 0 then dfhack.timeout(dur,'ticks',createcallback(x,sid)) end
  end
 end
end

validArgs = validArgs or utils.invert({
 'help',
 'unit',
 'weapon',
 'armor',
 'helm',
 'shoes',
 'shield',
 'gloves',
 'pants',
 'ammo',
 'equipped',
 'all',
 'quality',
 'dur',
 'upgrade',
 'downgrade',
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
 print([[improve.lua
  Change the quality of an item
  arguments:
   -help
     print this help message
   -unit id
     id of the target unit
     required if using -equipped
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
   -dur #
     length of time, in in-game ticks, for the quality change to last
     0 means the change is permanent
     DEFAULT: 0
   -upgrade                                 \
     upgrade the quality of the item by 1   |
   -downgrade                               |
     downgrade the quality of the item by 1 | Must have one and only one of these arguments
   -quality #                               |
     set the quality to a specified level   /
   -equipped                                                       \
     change quality of only equipped items of the declared type(s) |
   -all                                                            |
     change quality of all item of the declared type(s)            | Must have one and only one of these arguments
   -random                                                         |
     change quality of a random item of the declared type(s)       /
  examples:
   item-improve -unit \\UNIT_ID -weapon ALL -equipped -quality 6 -dur 1000
   item-improve -weapon ITEM_WEAPON_GIANTS -all -downgrade
 ]])
 return
end

unit = df.unit.find(tonumber(args.unit)) or 0 -- Check for unit declaration !REQUIRED if using -equipped
dur = tonumber(args.dur) or 0 -- Specify duration of change (default 0)
if args.weapon then upgradeitem(args,df.item_weaponst,unit,dur,args.weapon) end
if args.armor then upgradeitem(args,df.item_armorst,unit,dur,args.armor) end
if args.helm then upgradeitem(args,df.item_helmst,unit,dur,args.helm) end
if args.shoes then upgradeitem(args,df.item_shoesst,unit,dur,args.shoes) end
if args.shield then upgradeitem(args,df.item_shieldst,unit,dur,args.shield) end
if args.gloves then upgradeitem(args,df.item_glovest,unit,dur,args.gloves) end
if args.pants then upgradeitem(args,df.item_pantsst,unit,dur,args.pants) end
if args.ammo then upgradeitem(args,df.item_ammost,unit,dur,args.ammo) end

upgradeitem(args)
