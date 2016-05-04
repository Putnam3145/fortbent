local function getGristValue(unit)
    local grist_value=(unit.body.blood_max/1000)
    grist_value=grist_value+unit.body.physical_attrs.STRENGTH.value/500
    grist_value=grist_value+unit.body.physical_attrs.AGILITY.value/500
    grist_value=grist_value+unit.body.physical_attrs.TOUGHNESS.value/800
    grist_value=grist_value+unit.body.physical_attrs.ENDURANCE.value/1000
    grist_value=grist_value+unit.status.current_soul.mental_attrs.WILLPOWER.value/1500
    grist_value=grist_value+unit.status.current_soul.mental_attrs.SPATIAL_SENSE.value/1000
    grist_value=grist_value+unit.status.current_soul.mental_attrs.KINESTHETIC_SENSE.value/1000
    grist_value=grist_value+unit.status.current_soul.mental_attrs.FOCUS.value/2000
    local skill_value={}
    skill_value[5]=function(rating) return rating^3 end
    skill_value[6]=function(rating) return rating^1.5 end
    skill_value[7]=function(rating) return rating^2 end
    skill_value[8]=function(rating) return rating^2.5 end
    for k,v in ipairs(unit.status.current_soul.skills) do
        local add_func=skill_value[df.job_skill.attrs[v.id].type] or (df.job_skill[v.id]=='SITUATIONAL_AWARENESS' and function(rating) return rating^2 end)
        grist_value=grist_value+(add_func and add_func(v.rating) or 0)
    end
    return math.floor(grist_value),(df.creature_raw.find(unit.race).caste[unit.caste].flags.MEGABEAST and 1 or 0)
end

local eventful=require('plugins.eventful')

eventful.enableEvent(eventful.eventType['UNIT_DEATH'],5)

eventful.onUnitDeath.grist=function(unit_id)
    pcall(function()
    local victim=df.unit.find(unit_id)
    local victim_grist_value,zilly_value=getGristValue(victim)
    local grist=dfhack.persistent.save({key='GRIST_'..df.historical_figure.find(df.incident.find(victim.counters.death_id).killer_hfid).civ_id})
    if grist.ints[1]<0 then grist.ints[1]=0 end
    if grist.ints[2]<0 then grist.ints[2]=0 end
    grist.ints[1]=grist.ints[1]+victim_grist_value
    grist.ints[2]=grist.ints[2]+zilly_value
    grist:save()
    end)
end

local function gristTorrent()
    local civ_id=df.global.gamemode==df.game_mode['DWARF'] and df.global.ui.civ_id or #df.global.world.units.active>0 and df.global.world.units.active[0].civ_id or nil
    if not civ_id then return end
    local civ=df.historical_entity.find(civ_id)
    local grist=dfhack.persistent.save({key='GRIST_'..civ_id})
    local rng=dfhack.random.new()
    local torrent_amount=rng:random(5,math.min(1000,#civ.hist_figures))
    if grist.ints[1]<0 then grist.ints[1]=0 end
    if grist.ints[2]<0 then grist.ints[2]=0 end
    grist.ints[1]=grist.ints[1]+torrent_amount
    dfhack.gui.showAnnouncement('You have torrented ' .. torrent_amount .. ' grist. You now have ' .. grist.ints[1] .. ' grist available.',COLOR_GREEN,true)
    grist:save()
end

local function getClaspect(unit)
    local persistTable=require('persist-table')
    local unitTable=persistTable.GlobalTable.roses.UnitTable[tostring(unit.id)]
    if not unitTable then return {class=nil,color=nil} end
    local unitClasses = persistTable.GlobalTable.roses.UnitTable[tostring(unit.id)]['Classes']
    if not unitClasses then return {class=nil,color=nil} end 
    local currentClass = unitClasses['Current']
    if not currentClass then return {class=nil,color=nil} end
    local classes = persistTable.GlobalTable.roses.ClassTable
    local currentClassName = currentClass['Name']
    if not unitClasses[currentClassName] then return {class=nil,color=nil} end
    local currentClassLevel = tonumber(unitClasses[currentClassName]['Level'])+1
    local ofLocations={currentClassName:find('_OF_')}
    local className=currentClassName:sub(1,1)..currentClassName:sub(2,ofLocations[1]-1):lower()
    local aspectName=currentClassName:sub(ofLocations[2]+1,ofLocations[2]+1)..currentClassName:sub(ofLocations[2]+2,-1):lower()
    return {class=className,aspect=aspectName,level=currentClassLevel}
end

local function experienceTorrent()
    local timeout_tick=1
    local stealy_void_hero=false
    local seery_doom_hero=false
    for k,v in ipairs(df.global.world.units.active) do
        if dfhack.units.isCitizen(v) then
            local claspect=getClaspect(v)
            if not seery_doom_hero and (claspect.aspect=='Doom' and (claspect.class=='Seer' or claspect.class=='Mage')) and claspect.level>5 then
                seery_doom_hero=v
            elseif not stealy_void_hero and claspect.aspect=='Void' and (claspect.class=='Rogue' or claspect.class=='Thief') and claspect.level>5 then
                stealy_void_hero=v
            end
            dfhack.timeout(math.floor(timeout_tick),'ticks',function() pcall(function() dfhack.run_script('classes/add-experience','-unit',v.id,'-amount',1) end) end)
            timeout_tick=timeout_tick+.5
        end
    end
    if stealy_void_hero and seery_doom_hero then
        dfhack.run_script('fortbent/caledfwlch_event','-void',stealy_void_hero.id,'-doom',seery_doom_hero.id)
    end
end

require('repeat-util').scheduleUnlessAlreadyScheduled('GristTorrent',7,'days',gristTorrent)

require('repeat-util').scheduleUnlessAlreadyScheduled('ExperienceTorrent',28,'days',experienceTorrent)