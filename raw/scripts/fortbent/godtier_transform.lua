local eventful=require('plugins.eventful')

eventful.enableEvent(eventful.eventType.SYNDROME,5)

local function casteHasCreatureClass(class,caste)
    for k,v in ipairs(caste.creature_class) do
        if v.value==class then return true end
    end
    return false
end

local function properGodTierCreature(unit,aspect)
    local caste=df.creature_raw.find(unit.race).caste[unit.caste]
    if casteHasCreatureClass('INCESTUOUS_SLURRY',caste) then
        for k,v in ipairs(df.global.world.raws.creatures.all) do
            if v.creature_id:sub(15)==aspect and v.creature_id:sub(1,5)=='TROLL' then return k end 
        end
    else
        for k,v in ipairs(df.global.world.raws.creatures.all) do
            if v.creature_id:sub(15)==aspect and v.creature_id:sub(1,5)=='HUMAN' then return k end
        end
    end
    qerror('God tier creature could not be found!')
end

eventful.onSyndrome.fortbentGodTierAutoTrueTransform=function(unit_id,syndrome_index)
    local unit=df.unit.find(unit_id)
    local syndrome=df.syndrome.find(syndrome_index)
    if syndrome.syn_name:sub(1,11)=='GO_GOD_TIER' then
        local race=properGodTierCreature(unit,syndrome.syn_name:sub(13))
        unit.enemy.normal_race=race
    end
end

function forcedTransform(unit_id,syndrome_index)
    local unit=df.unit.find(unit_id)
    local syndrome=df.syndrome.find(syndrome_index)
    if syndrome.syn_name:sub(1,11)=='GO_GOD_TIER' then
        local race=properGodTierCreature(unit,syndrome.syn_name:sub(13))
        print('Set unit #' ..unit_id..' to race '..race)
        unit.enemy.normal_race=race
    end
end

local function forceIt()
    for k,v in ipairs(df.global.world.units.active) do
        for kk,vv in ipairs(v.syndromes.active) do\
            pcall(function() forcedTransform(v.id,vv.type) end)
        end
    end
end

if ...=="force" then forceIt() end

require('repeat-util').scheduleUnlessAlreadyScheduled('Goddamn God Tiers Not Doing Their Job',1,'months',forceIt)
