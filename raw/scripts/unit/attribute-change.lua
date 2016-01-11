--unit/attribute-change.lua v2.0

local utils = require 'utils'

validArgs = validArgs or utils.invert({
 'help',
 'attribute',
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
   -attribute ATTRIBUTE_ID
     attribute(s) to be changed
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

for i,attribute in ipairs(args.attribute) do
 if df.physical_attribute_type[attribute] then
  current = unit.body.physical_attrs[attribute].value
 elseif df.mental_attribute_type[attribute] then
  current = unit.status.current_soul.mental_attrs[attribute].value
 else
  print('Invalid attribute id')
  return
 end
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
 dfhack.script_environment('functions/unit').changeAttribute(unit,attribute,change,dur,track)
end
if args.announcement then
--add announcement information
end