local utils=require('utils')

local function titleIsPassive(unitTitle) --getting quite a lot of mileage out of this, hehe
    return string.find(unitTitle,"heir") or string.find(unitTitle,"page") or string.find(unitTitle,"rogue") or string.find(unitTitle,"sylph") or string.find(unitTitle,"bard")
 --seers not included because they should be different than that
end

local function unitIsPassiveXHero(unit,herotype)
    local unitTitle = unit.curse.name
    if string.find(unitTitle,herotype) and titleIsPassive(unitTitle) then return true end
    return false
end

local function unitIsDoomKnowledgeHero(unit)
    local unitTitle = unit.curse.name
    if string.find(unitTitle,"doom") and (string.find(unitTitle,"seer") or string.find(unitTitle,"mage")) then return true end
    return false
end

local function unitIsSeerOfMind(unit) --or seer of heart
    local unitTitle = unit.curse.name
    if string.find(unitTitle,"seer of mind") or string.find(unitTitle,"seer of heart") then return true end --non-indicative name for a function, sure, but it follows
    return false
end
local function cancelAttacks()
    for eventid,event in ipairs(df.global.timed_events) do
        if event.type == df.timed_event_type.Megabeast or event.type == df.timed_event_type.CivAttack then
            table.remove(df.global.timed_events,eventid)
        end
    end
end

local function voidHide(unit,attackCanceled)
    if attackCanceled then return true end
    local fortress = df.global.ui
    local success = false
    if dfhack.units.isCitizen(unit) then
        if math.random()<.01 and unitIsPassiveXHero(unit,"void") and not attackCanceled then
            cancelAttacks() 
            success = true 
            end
        end
    return success
end

local function doomInform(unit,attackWarned)
    if attackWarned then return true end
    local fortress = df.global.ui
    local success = false
    if dfhack.units.isCitizen(unit) then
        if math.random()<.15 and unitIsDoomKnowledgeHero(unit) and not attackWarned then
            success = true 
        end
    end
    return success
end

local function lordEnglishSyndrome()
    for syn_id,syndrome in ipairs(df.global.world.raws.syndromes.all) do
        if syndrome.syn_name == "???" then return syn_id end
    end
    qerror("Certain syndrome not found. Aborting.")
end

local function unitHasLESoul(unit)
    if #unit.status.souls<2 then return false end
    for k,v in ipairs(unit.status.souls) do
        if v.unk3==1025 then return true end
    end
    return false
end

local function addLordEnglishSoul(unit,syndrome)
	local syndromeUtil=require('syndrome-util')
    unit.status.souls:insert('#', 
        {
            new = df.unit_soul,
            unit_id = unit.id, 
            race = df.global.world.raws.creatures.list_creature[utils.binsearch(df.global.world.raws.creatures.alphabetic,'Cherubic Lord of Time','name',utils.compare_field_key(0)).caste[0].index],
            sex = 1, 
            caste = 0,
            unk1 = -1, 
            unk2 = -1,
            unk3 = 1025, 
            unk4 = -1, 
            anon_1 = 0, 
            anon_2 = 0, 
            anon_3 = -1, 
            anon_4 = -1
        }
        )
    syndromeUtil.infectWithSyndromeIfValidTarget(unit,syndrome,syndromeUtil.ResetPolicy[ResetDuration])
end

local function insertMistThought(unit)
    unit.status.recent_events:insert('#', 
    {
        new = df.unit_thought,
        type = 162,
        age = 1,
        subtype = -1,
        severity = 0 
    }
    )
end

local function findIdentityUnit(seerOfMind,LESyndrome)
    for _,unit in ipairs(df.global.world.units.active) do
        if dfhack.units.getIdentity(unit) and math.random()<.35 then
            dfhack.gui.showPopupAnnouncement("Your citizen, " .. dfhack.TranslateName(dfhack.units.getVisibleName(seerOfMind)) .. ", says that " .. dfhack.TranslateName(dfhack.units.getVisibleName(unit)) .. "is hiding something!",COLOR_LIGHTRED)
        end
        if unitHasLESoul(unit) then
            if math.random()>.9 then addLordEnglishSoul(seerOfMind,LESyndrome) end
            elseif math.random()<.1 then dfhack.gui.showPopupAnnouncement("He is already here.",COLOR_LIGHTGREEN)
        end
    end
end

local function findLEPossessedPeople()
    lordEnglish = findLordEnglish()
    for _,unit in ipairs(df.global.world.units.active) do
        if unitHasLESoul(unit) then
            dfhack.gui.showAnnouncement("He is already here.",COLOR_LIGHTGREEN)
        end
        if unit.race == lordEnglish then
            dfhack.gui.showAnnouncement("Don't dig too deep.",COLOR_LIGHTGREEN)
        end
    end
end

local function seerOfMindCheckForDisguisesAndLE(unit,LESyndrome) --or seer of heart
    if dfhack.units.isCitizen(unit) then
        if unitIsSeerOfMind(unit) then
            findIdentityUnit(unit,LESyndrome)
        end
    end
end

local function passiveXHeroesFound(herotype)
    local numfound = 0
    for _,unit in ipairs(df.global.world.units.active) do
        if dfhack.units.isCitizen(unit) then
            if unitIsPassiveXHero(unit,herotype) then numfound = numfound + 1 end
        end
    end
    if numfound > 20 then numfound = 20 end
    return numfound
end

local function passiveHeartHeroesMakeHappy()
    if math.random()<passiveXHeroesFound("heart")*.05 then
        for _,unit in ipairs(df.global.world.units.active) do
            if dfhack.units.isCitizen(unit) then insertMistThought(unit) end
        end
    end
end

local function forceRandomCaravan()
    local entities = df.global.world.entities.all
    for i=1,100 do --the method I use has a theoretical upper limit in time of... infinity, so I'd rather it run in a bounded loop
        local entity = entities[math.random(#entities-1)] --#entities is number of entities, of course. This designation is kinda evil, but it's readable.
        local flags = entity.entity_raw.flags
        if flags.COMMON_DOMESTIC_PACK and flags.COMMON_DOMESTIC_PULL and not (flags.LOCAL_BANDITRY or flags.SKULKING or flags.BABYSNATCHER) then
            df.global.timed_events:insert('#', 
            { 
                new = df.timed_event,
                type = df.timed_event_type.Caravan,
                season = df.global.cur_season,
                season_ticks = df.global.cur_season_tick,
                entity = entity 
            } 
            )
            return true
        end
    end
    local entity = entities[df.global.ui.civ_id]
        df.global.timed_events:insert('#', 
        { 
            new = df.timed_event,
            type = df.timed_event_type.Caravan,
            season = df.global.cur_season,
            season_ticks = df.global.cur_season_tick,
            entity = entity 
        } 
        )
    return false
end

local function passiveRageHeroesForceCaravan() --hehe
    local fortress = df.global.ui
    if math.random()<passiveXHeroesFound("rage")*.02 then --50 passive rage heroes makes a 100% chance per month; at 200 fort members, there should be a ~16% chance of an extra caravan per month
        forceRandomCaravan() 
        return true
    end
    return false
end

local function unitIsSeerOrMageOfRage(unit)
    local unitTitle=unit.curse.name
    if string.find(unitTitle,"rage") and (string.find(unitTitle,"mage") or string.find(unitTitle,"seer")) then return true end
end

local function unitIsDestroyWithRageHero(unit)
    local unitTitle = unit.curse.name
    if string.find(unitTitle,"rage") and (string.find(unitTitle,"prince") or string.find(unitTitle,"bard")) then return true end
    end

local function mageSeerRageCheckLE(unit)
    if dfhack.units.isCitizen(unit) and unitIsSeerOrMageOfRage(unit) then
        findLEPossessedPeople()
    end
end

local function princesAndBardsOfRageLE(unit,LESyndrome) 
    if unitIsDestroyWithRageHero(unit) and not unitHasLESoul(unit) then addLordEnglishSoul(unit,LESyndrome) end
end

local function passiveMindHeroesIncreasePotential() --look at all those nestings
    if math.random()<.02*passiveXHeroesFound("mind") then
        for _,unit in ipairs(df.global.world.units.active) do
            if dfhack.units.isCitizen(unit) then
                for _,attribute in ipairs(unit.status.current_soul.mental_attrs) do
                    if attribute.max_value < 100000 then
                        attribute.max_value = attribute.max_value*1.2
                        if attribute.max_value > 100000 then
                            attribute.max_value = 100000
                        end
                    end
                end
            end
        end
    end
end

local function passiveDoomHeroesRemoveHunger(unit,numberOfDoomUnits)
    if math.random()<.002*numberOfDoomUnits then
        local counters = unit.counters2
        counters.hunger_timer=0
        counters.thirst_timer=0
        counters.sleepiness_timer=0
    end
end

local function unitIsMaidOrKnightOfTime(unit) 
    local unitTitle = unit.curse.name
    return (unitTitle=="knight of time" or unitTitle=="maid of time")
end

local function maidAndKnightOfTimeTravel(unit)
    if not unitIsMaidOrKnightOfTime(unit) then return false
    else
        dfhack.run_script(fortbent/timeTravel,unit.id,pos.x+1,pos.y,pos.z,18000)
        return true
    end
end

local function fortbent() --bad name, but oh well
    local attackCanceled = false
    local attackWarned = false
    local LESyndrome = lordEnglishSyndrome()
    local numberOfDoomUnits = passiveXHeroesFound("doom")
    for _,unit in ipairs(df.global.world.units.active) do
        if dfhack.units.isCitizen(unit) then 
            attackCanceled = (voidHide(unit,attackCanceled)) and true or attackCanceled
            attackWarned = (doomInform(unit,attackWarned)) and true or attackWarned
            seerOfMindCheckForDisguisesAndLE(unit,LESyndrome)
            mageSeerRageCheckLE(unit,LESyndrome)
            princesAndBardsOfRageLE(unit,LESyndrome)
            passiveDoomHeroesRemoveHunger(unit,numberOfDoomUnits)
            maidAndKnightOfTimeTravel(unit)
        end
    end
    if attackCanceled then
        dfhack.gui.showAnnouncement("Your void heroes have succesfully hidden you from an attack.",COLOR_LIGHTBLUE)
    end
    if attackWarned then
        dfhack.gui.showAnnouncement("A citizen of yours is warning of an impending attack!",COLOR_LIGHTBLUE)
    end
end

local function fortbentCallback()
    fortbent()
    passiveHeartHeroesMakeHappy()
    passiveMindHeroesIncreasePotential()
    passiveRageHeroesForceCaravan()
    dfhack.timeout(1,'months',fortbentCallback)
end

dfhack.timeout(1,'months',fortbentCallback)