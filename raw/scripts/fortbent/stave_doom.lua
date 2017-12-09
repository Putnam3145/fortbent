local utils=require('utils')

validArgs = validArgs or utils.invert({
 'unit'
})

local args = utils.processArgs({...}, validArgs)

local unit = df.unit.find(args.unit)

local rng=dfhack.random.new()

unit.counters2.hunger_timer=unit.counters2.hunger_timer-rng:random(math.ceil(unit.counters2.hunger_timer/2))

unit.counters2.thirst_timer=unit.counters2.thirst_timer-rng:random(math.ceil(unit.counters2.thirst_timer/2))