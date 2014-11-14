function unitIsVoidHero(unit) --who's good enough for this
    for k,skill in ipairs(unit.status.current_soul.skills) do
        if skill.id==df.job_skill.MAGIC_NATURE then
            return skill.rating>14
        end
    end
    return false
end

local utils=require('utils')

validArgs = validArgs or utils.invert({
 'unit'
})

local args = utils.processArgs({...}, validArgs)

if unitIsVoidHero(df.unit.find(args.unit)) then
    dfhack.run_script('gui/hack-wish','-unit',args.unit)
end