-- Allows ectobiology.

-- where doing it man

-- where MAKING THIS HAPEN

local function getCitizenList()
    local citizenTable={}
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
    if freeform then
        
    else
        local citizens=getCitizenList()
        local ok,name,unit=script.showListPrompt("Unit Selection","Choose who you want to have a child.",COLOR_WHITE,tbl)
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