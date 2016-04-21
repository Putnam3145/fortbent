-- A few events for modding.

--[[
    The eventTypes table describes what event types there are. Activation is done like so:
    enableEvent(eventTypes.ON_RELATIONSHIP_UPDATE,1)
]]

onUnitAction=onUnitAction or dfhack.event.new()

local actions_already_checked=actions_already_checked or {}

things_to_do_every_action=things_to_do_every_action or {}

actions_to_be_ignored_forever=actions_to_be_ignored_forever or {}

local function checkForActions()
    for _,something_to_do_to_every_action in pairs(things_to_do_every_action) do
        something_to_do_to_every_action[5]=something_to_do_to_every_action[5]+1 or 0
    end
    for k,unit in ipairs(df.global.world.units.active) do
        local unit_id=unit.id
        actions_already_checked[unit_id]=actions_already_checked[unit_id] or {}
        local unit_action_checked=actions_already_checked[unit_id]
        for _,action in ipairs(unit.actions) do
            local action_id=action.id
            if action.type~=-1 then
                for kk,something_to_do_to_every_action in pairs(things_to_do_every_action) do
                    if something_to_do_to_every_action[1] then 
                        if something_to_do_to_every_action[5]>1 or (unit_id==something_to_do_to_every_action[3] and action_id==something_to_do_to_every_action[4]) then
                            things_to_do_every_action[kk]=nil
                        else
                            something_to_do_to_every_action[1](unit_id,action,table.unpack(something_to_do_to_every_action[2]))
                        end
                    end
                end
                if not unit_action_checked[action_id] then
                    onUnitAction(unit_id,action)
                    unit_action_checked[action_id]=true
                end
            end
        end
    end
end

function doSomethingToEveryActionNextTick(unit_id,action_id,func,func_args) --func is thing to do, unit_id and action_id represent the action that gave the "order"
    actions_to_be_ignored_forever[unit_id]=actions_to_be_ignored_forever[unit_id] or {}
    if not actions_to_be_ignored_forever[unit_id][action_id] then
        table.insert(things_to_do_every_action,{func,func_args,unit_id,action_id,0})
    end
    actions_to_be_ignored_forever[unit_id][action_id]=true
end


onRelationshipUpdate=onRelationshipUpdate or dfhack.event.new()

current_relations_checked=current_relations_checked or {}

local function checkRelationshipUpdates()
    for k,v in ipairs(df.global.world.units.active) do
        local histfig=df.historical_figure.find(v.hist_figure_id)
        if not histfig or not histfig.info or not histfig.info.relationships then return end
        current_relations_checked[v.hist_figure_id]=current_relations_checked[v.hist_figure_id] or {}
        for kk,relationship in ipairs(histfig.info.relationships.list) do
            current_relations_checked[v.hist_figure_id][relationship.histfig_id]=current_relations_checked[v.hist_figure_id][relationship.histfig_id] or {}
            local thisHistFigRelations=current_relations_checked[v.hist_figure_id][relationship.histfig_id]
            for relation_type_index,relation_type in ipairs(relationship.anon_3) do
                thisHistFigRelations[relation_type]=thisHistFigRelations[relation_type] or relationship.anon_4[relation_type_index]
                if thisHistFigRelations[relation_type]~=relationship.anon_4[relation_type_index] then
                    onRelationshipUpdate(v.hist_figure_id,relationship.histfig_id,relation_type,thisHistFigRelations[relation_type],relationship.anon_4[relation_type_index])
                    --onRelationshipUpdate.example=function(histfig1_id,histfig2_id,relationship_type,old_value,new_value)
                    thisHistFigRelations[relation_type]=relationship.anon_4[relation_type_index]
                end
            end
        end
    end
end

local df_date={}

df_date.__eq=function(date1,date2)
    return date1.year==date2.year and date1.year_tick==date2.year_tick
end

df_date.__lt=function(date1,date2)
    if date1.year<date2.year then return true end
    if date1.year>date2.year then return false end
    if date1.year==date2.year then
        return date1.year_tick<date2.year_tick
    end
end

df_date.__le=function(date1,date2)
    if date1.year<date2.year then return true end
    if date1.year>date2.year then return false end
    if date1.year==date2.year then
        return date1.year_tick<=date2.year_tick
    end
end

onEmotion=onEmotion or dfhack.event.new()

last_check_time=last_check_time or {year=df.global.cur_year,year_tick=df.global.cur_year_tick}

setmetatable(last_check_time,df_date)

local function checkEmotions()
    for k,unit in ipairs(df.global.world.units.active) do
        if unit.status.current_soul then
            for _,emotion in ipairs(unit.status.current_soul.personality.emotions) do
                local emotion_date={year=emotion.year,year_tick=emotion.year_tick}
                setmetatable(emotion_date,df_date)
                if emotion_date>=last_check_time then
                    onEmotion(unit,emotion)
                end
            end
        end
    end
    last_check_time.year=df.global.cur_year
    last_check_time.year_tick=df.global.cur_year_tick
end

eventTypes={
    ON_RELATIONSHIP_UPDATE={name='relationCheck',func=checkRelationshipUpdates},
    ON_ACTION={name='onAction',func=checkForActions},
    ON_EMOTION={name='onEmotion',func=checkEmotions}
}

function enableEvent(event,ticks)
    ticks=ticks or 1
    require('repeat-util').scheduleUnlessAlreadyScheduled(event.name,ticks,'ticks',event.func)
end

function disableEvent(event)
    require('repeat-util').cancel(event.name)
end
