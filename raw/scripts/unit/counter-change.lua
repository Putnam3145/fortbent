--unit/counter-change.lua v2.0

local utils = require 'utils'

validArgs = validArgs or utils.invert({
 'help',
 'token',
 'fixed',
 'percent',
 'set',
 'dur',
 'unit',
 'argument'
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
 print([[unit/counter-change.lua
  Change the value(s) of a unit
  arguments:
   -help
     print this help message
   -unit id
     REQUIRED
     id of the target unit
   -token TYPE
     REQUIRED
     token to be changed
     valid types:
      webbed
      stunned
      winded
      unconscious
      pain
      nausea
      dizziness
      paralysis
      numbness
      fever
      exhaustion
      hunger
      thirst
      sleepiness
      blood
      infection
   -fixed #                                  \
     change token value by fixed amount      |
   -percent #                                |
     change token value by percentage amount | Must have one and only one of these arguments
   -set #                                    |
     set token value to this value           /
   -dur #
     length of time, in in-game ticks, for the change to last
     0 means the change is permanent
     DEFAULT: 0
  examples:
   unit/counter-change -unit \\UNIT_ID -fixed 10000 -token stunned -dur 10
   unit/counter-change -unit \\UNIT_ID -set [ 0 0 0 0 ] -token [ nausea dizziness numbness fever ]
   unit/counter-change -unit \\UNIT_ID -percent \-100 -token blood
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
if type(args.token) == 'string' then args.token = {args.token} end
if #value ~= #args.token then
 print('Mismatch between number of tokens declared and number of changes declared')
 return
end

for i,counter in ipairs(args.token) do
 if (counter == 'webbed' or counter == 'stunned' or counter == 'winded' or counter == 'unconscious'
     or counter == 'pain' or counter == 'nausea' or counter == 'dizziness') then
  location = unit.counters
 elseif (counter == 'paralysis' or counter == 'numbness' or counter == 'fever' or counter == 'exhaustion'
         or counter == 'hunger' or counter == 'thirst' or counter == 'sleepiness' or oounter == 'hunger_timer'
         or counter == 'thirst_timer' or counter == 'sleepiness_timer') then
  if (counter == 'hunger' or counter == 'thirst' or counter == 'sleepiness') then counter = counter .. '_timer' end
  location = unit.counters2
 elseif counter == 'blood' or counter == 'infection' then
  location = unit.body
 else
  print('Invalid counter token declared')
  return
 end
 current = location[counter]

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
 dfhack.script_environment('functions/unit').changeCounter(unit,counter,change,dur)
 if args.announcement then
--add announcement information
 end
end