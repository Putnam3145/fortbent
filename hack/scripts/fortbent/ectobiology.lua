-- Allows ectobiology.

-- where doing it man

-- where MAKING THIS HAPEN

local function getCitizenList(lovers_only)
    local citizenTable={}
    if lovers_only then
        for k,u in ipairs(df.global.world.units.active) do
            if dfhack.units.isCitizen(u) and (unit.relations.spouse_id~=-1 or unit.relations.lover_id~=-1) then
                table.insert(citizenTable,{dfhack.TranslateName(dfhack.getVisibleName(u)),nil,u})
            end
        end
    else
        for k,u in ipairs(df.global.world.units.active) do
            if dfhack.units.isCitizen(u) then
                table.insert(citizenTable,{dfhack.TranslateName(dfhack.getVisibleName(u)),nil,u})
            end
        end
    return citizenTable
end

local function getSpouseOrLover(unit)
    local lover_unit=df.unit.find(unit.relations.lover_id) or df.unit.find(unit.relations.spouse_id)
    if lover_unit then
        return lover_unit.hist_figure_id
    else
        local hist_fig=df.historical_figure.find(unit.hist_figure_id)
        for k,v in ipairs(hist_fig.histfig_links) do
            if df.histfig_hf_link_spousest:is_instance(v) or df.histfig_hf_link_loverst:is_instance(v) then
                return v.target_hf
            end
        end
    end
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
    if freeform then
        local ok1,name1,unit1=script.showListPrompt("Unit Selection","Choose first paradox ghost slime target.",COLOR_WHITE,citizens)
        local ok2,name2,unit2=script.showListPrompt("Unit Selection","Choose second paradox ghost slime target.",COLOR_WHITE,citizens)
        unit1.relations.pregnancy_timer=1
        unit1.relations.pregnancy_genes=unit.appearance.genes:new()
        unit1.relations.pregnancy_spouse=unit2.hist_figure_id
        unit1.relations.pregnancy_caste=unit2.caste
        dfhack.run_script('modtools/add-syndrome','-syndrome','temp desterilize','-target',unit.id)
        if unit1.sex==1 then
            local normal_caste=unit.enemy.normal_caste
            unit.enemy.normal_caste=getFemaleCasteWithSameMaxAge(unit)
            script.sleep(1,'ticks')
            unit.enemy.normal_caste=normal_caste
        end
    else
        local ok,name,unit=script.showListPrompt("Unit Selection","Choose first genetic material giver.",COLOR_WHITE,citizens)
        if unit.relations.spouse_id==-1 and unit.relations.lover_id==-1 then
            script.showMessage('Unit selection',"That person ain't in a relationship, you ninnywhipper! Use freeform ectobiology for your weird shipping shit.")
        else
            local lover=getSpouseOrLover(unit)
            unit.relations.pregnancy_timer=1
            unit.relations.pregnancy_genes=unit.appearance.genes:new()
            unit.relations.pregnancy_spouse=lover
            unit.relations.pregnancy_caste=df.historical_figure.find(lover).caste
            dfhack.run_script('modtools/add-syndrome','-syndrome','temp desterilize','-target',unit.id)
            if unit.sex==1 then
                local normal_caste=unit.enemy.normal_caste
                unit.enemy.normal_caste=getFemaleCasteWithSameMaxAge(unit)
                script.sleep(1,'ticks')
                unit.enemy.normal_caste=normal_caste
            end
        end
    end
    end)
end

local utils=require(utils)

validArgs = validArgs or utils.invert({
 'freeform'
})

local args = utils.processArgs({...}, validArgs)

ectobiologize(args.freeform)