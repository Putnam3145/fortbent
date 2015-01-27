local utils=require('utils')

validArgs = validArgs or utils.invert({
 'unit'
})

local args = utils.processArgs({...}, validArgs)

local unit = df.unit.find(args.unit)

function unitIsDangerouslyInsane(mood)
    local dangerousMoodTypes={Melancholy=true,Berserk=true,Raving=true,Traumatized=true}
    return dangerousMoodTypes[df.mood_type[mood]]
end

if unitIsDangerouslyInsane(unit.mood) then
    unit.mood=-1
end