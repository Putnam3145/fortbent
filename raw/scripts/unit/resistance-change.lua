--unit/resistance-change.lua v2.0

local utils = require 'utils'

validArgs = validArgs or utils.invert({
 'help',
 'resistance',
 'fixed',
 'percent',
 'set',
 'dur',
 'unit',
 'announcement',
 'track',
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
 print([[unit/attribute-change.lua
  Change the attribute(s) of a unit
  arguments:
   -help
     print this help message
   -unit id
     REQUIRED
     id of the target unit
   -resistance RESISTANCE_ID
     resistance(s) to be changed
     valid arguments:
      PHYSICAL:ALL
      PHYSICAL:BLUNT
      PHYSICAL:PIERCE
      PHYSICAL:SLASH
      MAGICAL:ALL
      MAGICAL:ELEMENTAL:ALL
      MAGICAL:ELEMENTAL:FIRE
      MAGICAL:ELEMENTAL:WATER
      MAGICAL:ELEMENTAL:AIR
      MAGICAL:ELEMENTAL:EARTH
      MAGICAL:ELEMENTAL:SMOKE
      MAGICAL:ELEMENTAL:ICE
      MAGICAL:ELEMENTAL:STORM
      MAGICAL:ELEMENTAL:METAL
      MAGICAL:ARCANE:ALL
      MAGICAL:ARCANE:FORCE
      MAGICAL:ARCANE:TIME
      MAGICAL:ARCANE:SPACE
      MAGICAL:ARCANE:AEGIS
      MAGICAL:MENTAL:ALL
      MAGICAL:MENTAL:ILLUSION
      MAGICAL:MENTAL:THOUGHT
      MAGICAL:MENTAL:EMOTION
      MAGICAL:MENTAL:MIND
      MAGICAL:NATURE:ALL
      MAGICAL:NATURE:ANIMAL
      MAGICAL:NATURE:PLANT
      MAGICAL:NATURE:GROUND
      MAGICAL:NATURE:SPIRIT
      MAGICAL:DIVINE:ALL
      MAGICAL:DIVINE:LIGHT
      MAGICAL:DIVINE:DARK
      MAGICAL:DIVINE:VOID
      MAGICAL:DIVINE:SHADOW
   -fixed #                                \
     change attribute by fixed amount      |
   -percent #                              |
     change attribute by percentage amount | Must have one and only one of these arguments
   -set #                                  |
     set attribute to this value           /
   -dur #
     length of time, in in-game ticks, for the change to last
     0 means the change is permanent
     DEFAULT: 0
   -announcement string
     optional argument to create an announcement and combat log report
  examples:
   unit/attribute-change -unit \\UNIT_ID -fixed 100 -attribute STRENGTH
   unit/attribute-change -unit \\UNIT_ID -percent [ 10 10 10 ] -attribute [ ENDURANCE TOUGHNESS WILLPOWER ] -dur 3600
   unit/attribute-change -unit \\UNIT_ID -set 5000 -attribute WILLPOWER -dur 1000
 ]])
 return
end

if args.unit and tonumber(args.unit) then
 unit = df.unit.find(tonumber(args.unit))
else
 print('No unit selected')
 return
end

value = args.fixed or args.percent or args.set

dur = tonumber(args.dur) or 0
if type(value) == 'string' then value = {value} end
if type(args.attribute) == 'string' then args.attribute = {args.attribute} end
if #value ~= #args.attribute then
 print('Mismatch between number of attributes declared and number of changes declared')
 return
end

track = nil
if args.track then track = 'track' end

for i,resistance in ipairs(args.resistance) do
 array = split(resistance,':')
 for i,entry in pairs(array) do
  array[i] = string.lower(entry):gsub("^%l",string.upper)
 end
 resistance = "Resistances"..table.concat(array,':')
 current = dfhack.script_environment('functions/misc').getCounter("UNIT:"..resistance..":Base",unit.id)
 if args.fixed then
  change = tonumber(value[i])
 elseif args.percent then
  local percent = (100+tonumber(value[i]))/100
  change = current*percent - current
 elseif args.set then
  change = tonumber(value[i]) - current
 else
  print('No method for change defined')
  return
 end
 dfhack.script_environment('functions/unit').changeResistance(unit,resistance,change,dur,track)
end
if args.announcement then
--add announcement information
end