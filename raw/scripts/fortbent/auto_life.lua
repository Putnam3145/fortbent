local utils=require('utils')

validArgs = validArgs or utils.invert({
 'unit'
})

local args = utils.processArgs({...}, validArgs)

local eventful=require('plugins.eventful')

eventful.enableEvent(eventful.eventType.UNIT_DEATH,1) --requires iterating through all units; however, scripts included in DFHack use 1, so that's what I am

eventful.onUnitDeath.auto_life_fortbent=eventful.onUnitDeath.auto_life_fortbent or function(unit_id)
    local life_amount=dfhack.persistent.get('AUTO_LIFE/'..unit_id)
    if life_amount and life_amount.ints[1]>0 then
        dfhack.run_script('full-heal','-r','-unit',unit.id)
    end
end

if args.unit then
    if not dfhack.persistent.get('AUTO_LIFE/'..args.unit) then dfhack.persistent.save{key='AUTO_LIFE/'..args.unit,ints={1}} end
end