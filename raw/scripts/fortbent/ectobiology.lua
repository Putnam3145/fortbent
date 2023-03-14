-- Allows ectobiology.

-- where doing it man

-- where MAKING THIS HAPEN


local custom_relation_types={} --should probably put this into a separate file

custom_relation_types[413]={name='Moirail',color_fg=COLOR_RED,color_bg=COLOR_BLACK}

custom_relation_types[612]={name='Kismesis',color_fg=COLOR_BLACK,color_bg=COLOR_GREY}

custom_relation_types[1025]={name='Auspistice',color_fg=COLOR_BLACK,color_bg=COLOR_WHITE} --actually screw that one but whatever.

custom_relation_types['MOIRAIL']=413

custom_relation_types['KISMESIS']=612

custom_relation_types['AUSPISTICE']=1025

local function getNumberOfChildren(unit)
    local children=0
    for k,v in ipairs(df.historical_figure.find(unit.hist_figure_id).histfig_links) do
        if df.histfig_hf_link_childst:is_instance(v) then children=children+1 end
    end
    return children
end

local function hasCustomRelationship(histfig,relationship_type)
    local typeToLookFor=custom_relation_types[relationship_type]
    for k,v in ipairs(histfig.info.relationships.hf_visual) do
        for kk,vv in ipairs(v.attitude) do
            if vv==typeToLookFor then return v.histfig_id end
        end
    end
    return false
end

local function getSpouseOrLover(unit)
    local lover_unit=df.unit.find(unit.relationship_ids.Lover) or df.unit.find(unit.relationship_ids.Spouse)
    local return_table={lover=nil,kismesis=nil}
    local kismesis=hasCustomRelationship(df.historical_figure.find(unit.hist_figure_id),'KISMESIS')
    if kismesis then
        table.insert(return_table,{dfhack.TranslateName(dfhack.units.getVisibleName(lover_unit))..' (kismesis)',nil,kismesis})
    end
    if lover_unit then
        table.insert(return_table,{dfhack.TranslateName(dfhack.units.getVisibleName(lover_unit))..' (matesprit)',nil,lover_unit.hist_figure_id})
    else
        local hist_fig=df.historical_figure.find(unit.hist_figure_id)
        for k,v in ipairs(hist_fig.histfig_links) do
            if df.histfig_hf_link_spousest:is_instance(v) or df.histfig_hf_link_loverst:is_instance(v) then
                return_table.lover={dfhack.TranslateName(dfhack.units.getVisibleName(lover_unit))..' (matesprit)',nil,target_hf}
            end
        end
    end
    return return_table,(lover_unit or kismesis)
end

local function getCitizenList(lovers_only,species)
    local citizenTable={}
    if lovers_only then
        for k,u in ipairs(df.global.world.units.active) do
            if dfhack.units.isCitizen(u) and u.military.squad_id==-1 and (not species or u.race==species) then
                local spouseOrLover,hasSpouseOrLover=getSpouseOrLover(u)
                if hasSpouseOrLover then
                    table.insert(citizenTable,{dfhack.TranslateName(dfhack.units.getVisibleName(u))..' ('..getNumberOfChildren(u)..' children)',nil,u})
                end
            end
        end
    else
        for k,u in ipairs(df.global.world.units.active) do
            if dfhack.units.isCitizen(u) and u.military.squad_id==-1 and (not species or u.race==species) then
                table.insert(citizenTable,{dfhack.TranslateName(dfhack.units.getVisibleName(u))..' ('..getNumberOfChildren(u)..' children)',nil,u})
            end
        end
    end
    return citizenTable
end

local function getFemaleCasteWithSameMaxAge(unit)
    local curCaste=df.creature_raw.find(unit.race).caste[unit.caste]
    for k,caste in ipairs(df.creature_raw.find(unit.race).caste) do
        if caste.gender==0 and caste.misc.maxage_min==curCaste.misc.maxage_min and caste.misc.maxage_max==curCaste.misc.maxage_max then return k end
    end
end

local function ectobiologize(freeform)
    local script=require('gui.script')
    script.start(function()
    local citizens=getCitizenList(not freeform)
    if #citizens==0 then script.showMessage('Ectobiology',"Nobody is in a relationship! Best use freeform ectobiology.",COLOR_WHITE) return end
    if freeform then
        local ok1,name1,unit1_t=script.showListPrompt("Ectobiology","Choose first paradox ghost slime target.",COLOR_WHITE,citizens)
        if not ok1 then return end
        local unit1=unit1_t[3]
        local sameRaceCitizens=getCitizenList(not freeform,unit1.race)
        local ok2,name2,unit2_t=script.showListPrompt("Ectobiology","Choose second paradox ghost slime target.",COLOR_WHITE,citizens)
        if not ok2 then return end
        local unit2=unit2_t[3]
        unit1.pregnancy_timer=1
        unit1.pregnancy_genes=unit1.appearance.genes:new()
        unit1.pregnancy_spouse=unit2.hist_figure_id
        unit1.pregnancy_caste=unit2.caste
        dfhack.run_script('modtools/add-syndrome','-syndrome','temp desterilize','-target',unit1.id)
        if unit1.sex==1 then
            local normal_caste=unit1.enemy.normal_caste
            unit1.enemy.normal_caste=getFemaleCasteWithSameMaxAge(unit1)
            script.sleep(1,'ticks')
            unit1.enemy.normal_caste=normal_caste
        end
    else
        local ok1,name1,unit_t=script.showListPrompt("Ectobiology","Choose first genetic material giver.",COLOR_WHITE,citizens)
        if not ok1 then return false end
        local unit=unit_t[3]
        local lovers=getSpouseOrLover(unit)
        local ok2,name2,lover_t=script.showListPrompt("Ectobiology","Choose second genetic material giver.",COLOR_WHITE,lovers)
        if not ok2 then return false end
        unit.pregnancy_timer=1
        unit.pregnancy_genes=unit.appearance.genes:new()
        unit.pregnancy_spouse=lover_t[3]
        unit.pregnancy_caste=df.historical_figure.find(lover_t[3]).caste
        dfhack.run_script('modtools/add-syndrome','-syndrome','temp desterilize','-target',unit.id)
        if unit.sex==1 then
            local normal_caste=unit.enemy.normal_caste
            unit.enemy.normal_caste=getFemaleCasteWithSameMaxAge(unit)
            script.sleep(1,'ticks')
            unit.enemy.normal_caste=normal_caste
        end
    end
    end)
end

local utils=require('utils')

validArgs = validArgs or utils.invert({
 'freeform'
})

local args = utils.processArgs({...}, validArgs)

ectobiologize(args.freeform)
