local function findCreatureGivenID(str)
    for k,v in ipairs(df.global.world.raws.creatures.all) do
        if v.creature_id==str then return k,v end
    end
end

local utils=require('utils')

validArgs = validArgs or utils.invert({
 'unit'
})

local args = utils.processArgs({...}, validArgs)

local unit = df.unit.find(args.unit)

LECreature = LECreature or findCreatureGivenID('LORD_ENGLISH')

for k,v in ipairs(df.global.world.units.active) do
    if v.race==LECreature then
        dfhack.run_script('add-emotion','-unit',args.unit,'-emotion','Uneasiness','-severity','800')
        dfhack.gui.show_announcement('HE IS ALREADY HERE.',COLOR_LIGHTGREEN)
        dfhack.gui.writeToGamelog('HE IS ALREADY HERE.')
    end
end