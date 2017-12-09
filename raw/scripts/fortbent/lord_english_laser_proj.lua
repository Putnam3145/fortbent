local function posIsEqual(pos1,pos2)
    return pos1.x == pos2.x and pos1.y == pos2.y and pos1.z == pos2.z
end

local function getUnitHitByProjectile(projectile)
    for k,unit in ipairs(df.global.world.units.active) do
        if posIsEqual(unit.pos,projectile.cur_pos) then return unit.id end
    end
    return nil
end

local utils=require('utils')

validArgs = validArgs or utils.invert({
 'projectile'
})

local args = utils.processArgs({...}, validArgs)
local uid = getUnitHitByProjectile(df.item.find(args.projectile))

dfhack.run_script('fortbent/lord_english_laser',uid)