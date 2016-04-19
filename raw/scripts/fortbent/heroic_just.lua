local function can_god_tier(unit)
    local active_syndromes=unit.syndromes.active
    for _,c_syndrome in ipairs(active_syndromes) do
        local syndrome_classes=df.syndrome.find(c_syndrome.type).syn_class
        for _,synclass in ipairs(syndrome_classes) do
            if synclass.value == "CAN_GO_GOD_TIER" then return true end
        end
    end
    return false
end

local function is_god_tier(unit)
    local active_syndromes=unit.syndromes.active
    for _,c_syndrome in ipairs(active_syndromes) do
        local syndrome_classes=df.syndrome.find(c_syndrome.type).syn_class
        for _,synclass in ipairs(syndrome_classes) do
            if synclass.value == "GOD_TIER" then return true end
        end
    end
    return false
end

local function is_lord_english(unit)
    for k,v in ipairs(df.creature_raw.find(unit.race).caste[unit.caste].creature_class) do
        if v.value=='UNCONDITIONAL_IMMORTALITY' then return true end
    end
    return false
end

local function death_was_accident(incident)
    local death_cause=df.death_type[incident.death_cause]
    return incident.killer==-1 or not (death_cause=='SHOT' or death_cause=='BLEED' or death_cause=='STRUCK_DOWN' or death_cause=='DRAGONFIRE' or death_cause=='FIRE' or death_cause=='MURDER' or death_cause=='TRAP' or death_cause=='QUIT' or death_cause=='DRAIN_BLOOD')
end

local function death_was_final(unit)
    --first we need to determine if the death was due to some action that could be regarded as either heroic or just
    if death_was_accident(df.incident.find(unit.counters.death_id)) then return false end
    local is_scared_of_current_combat=false
    local is_in_combat=false
    for k,emotion in ipairs(unit.status.current_soul.personality.emotions) do
        if emotion.thought==df.unit_thought_type.Conflict or emotion.thought==df.unit_thought_type.JoinConflict then
            is_in_combat=is_in_combat or df.global.cur_year_tick-emotion.year_tick<1200
            is_scared_of_current_combat = is_scared_of_current_combat or (emotion.type==df.emotion_type.Terror or emotion.type==df.emotion_type.Fright or emotion.type==df.emotion_type.Shaken or emotion.type==df.emotion_type.Fear or emotion.type==df.emotion_type.Panic)
        end
    end
    return not ((not is_in_combat) or is_scared_of_current_combat)
end

local function death_was_just(incident)
    local total_enemy_amount=0
    for k,entity_link in ipairs(df.historical_figure.find(incident.victim_hfid).entity_links) do
        if df.histfig_entity_link_enemyst:is_instance(entity_link) then
            total_enemy_amount=total_enemy_amount+1
        end
        if df.histfig_entity_link_criminalst:is_instance(entity_link) then --kind of a dumb workaround until i can figure out how to determine a murderer
            return true
        end
        if total_enemy_amount>5 then return true end
    end
    return false
end

local function death_was_heroic_or_just(unit)
    return death_was_final(unit) and (death_was_just(df.incident.find(unit.counters.death_id)) and "just" or "heroic") or false
end

local eventful=require('plugins.eventful')

eventful.enableEvent(eventful.eventType.UNIT_DEATH,5) --requires iterating through all units

eventful.onUnitDeath.heroic_or_just_god_tier_death=function(unit_id)
    local unit=df.unit.find(unit_id)
    if is_god_tier(unit) then
        local heroic_or_just=death_was_heroic_or_just(unit)
        if heroic_or_just then
            local ann_color=heroic_or_just=='heroic' and COLOR_YELLOW or COLOR_MAGENTA
            local ann_string='The death of ' .. dfhack.TranslateName(dfhack.units.getVisibleName(unit)) .. ' has been deemed ' .. heroic_or_just
            dfhack.gui.makeAnnouncement(df.announcement_type.CITIZEN_DEATH,{RECENTER=true,A_DISPLAY=true,D_DISPLAY=true,PAUSE=true,DO_MEGA=true},unit.pos,ann_string,ann_color)
        else
            dfhack.gui.makeAnnouncement(df.announcement_type.CITIZEN_DEATH,{RECENTER=true,A_DISPLAY=true,D_DISPLAY=true,PAUSE=true,DO_MEGA=true},unit.pos,'Not heroic nor just; revival!',COLOR_YELLOW)
            dfhack.run_script('full-heal','-r','-unit',unit.id)
        end
    elseif is_lord_english(unit) then
        dfhack.gui.makeAnnouncement(df.announcement_type.CITIZEN_DEATH,{RECENTER=true,A_DISPLAY=true,D_DISPLAY=true,PAUSE=true,DO_MEGA=true},unit.pos,'Not heroic nor just; revival!',COLOR_LGREEN)
        dfhack.run_script('full-heal','-r','-unit',unit.id)
    elseif can_god_tier(unit) then
        local ann_string=dfhack.TranslateName(dfhack.units.getVisibleName(unit)) .. " is going god tier!"
        dfhack.gui.makeAnnouncement(df.announcement_type.CITIZEN_DEATH,{RECENTER=true,A_DISPLAY=true,D_DISPLAY=true,PAUSE=true,DO_MEGA=true},unit.pos,ann_string,COLOR_YELLOW)
        dfhack.run_script('full-heal','-r','-unit',unit.id)
        dfhack.run_script('add-syndrome','-syndrome','god tier','-target',unit.id)
    end
end
