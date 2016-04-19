local majyyk_colors={COLOR_LIGHTRED,COLOR_YELLOW,COLOR_BLUE,COLOR_GREEN,COLOR_MAGENTA,COLOR_BROWN}
local clockwork_majyyks=dfhack.matinfo.find('CLOCKWORK_MAJYYKS_NO_ALCHEMIZE').material
local clockwork_cur_color_idx=0
clockwork_majyyks.build_color[2]=0
clockwork_majyyks.tile_color[2]=0
local psiioniic_colors={COLOR_LIGHTRED,COLOR_LIGHTBLUE}
local optic_blast=dfhack.matinfo.find('MINDBLAST_NO_ALCHEMIZE').material
local optic_blast_cur_color_idx=0
optic_blast.build_color[2]=0
optic_blast.tile_color[2]=0
optic_blast.build_color[1]=0
optic_blast.tile_color[1]=0
optic_blast.basic_color[1]=0


local function clockwork_majyyks_color_change()
    clockwork_cur_color_idx=(clockwork_cur_color_idx%6)+1
    local clockwork_cur_color_f=majyyk_colors[clockwork_cur_color_idx]
    local clockwork_cur_color_b=majyyk_colors[(clockwork_cur_color_idx%6)+1]
    clockwork_majyyks.basic_color[0]=clockwork_cur_color_f
    clockwork_majyyks.basic_color[1]=clockwork_cur_color_b
    clockwork_majyyks.build_color[0]=clockwork_cur_color_f
    clockwork_majyyks.build_color[1]=clockwork_cur_color_b
    clockwork_majyyks.tile_color[0]=clockwork_cur_color_f
    clockwork_majyyks.tile_color[1]=clockwork_cur_color_b
end

local function mind_blast_color_change()
    optic_blast_cur_color_idx=(optic_blast_cur_color_idx%2)+1
    local optic_color=psiioniic_colors[optic_blast_cur_color_idx]
    clockwork_majyyks.basic_color[0]=optic_color
    clockwork_majyyks.build_color[0]=optic_color
    clockwork_majyyks.tile_color[0]=optic_color
end

local repeat_util=require('repeat-util')

repeat_util.scheduleUnlessAlreadyScheduled('Clockwork Majyyks',math.ceil(df.global.enabler.gfps/15),'frames',clockwork_majyyks_color_change) --EPILEPSY: the magic number on the left (15 by default) is the FPS of the clockwork majyyks scroll effect. You can reduce it to manageable levels by lowering that number or remove it entirely by removing this line.

repeat_util.scheduleUnlessAlreadyScheduled('Psiioniic Blast',5,'ticks',mind_blast_color_change)

function onUnload()
    repeat_util.cancel('Clockwork Majyyks')
    repeat_util.cancel('Psiioniic Blast')
end

dfhack.run_command('script',SAVE_PATH..'/raw/fortbent_onload.txt')

local eraseReport = function(unit,report)
 for i,v in ipairs(unit.reports.log.Combat) do
  if v == report then
   unit.reports.log.Combat:erase(i)
   break
  end
 end
end

local eventful=require('plugins.eventful')

local attackStrFuncs={} --table lookups are O(1), if elseif chains are O(n). This matters with the sheer amount of these things I have.

attackStrFuncs['teleports']=function(attackVerb,defendVerb,attackerId,defenderId,attackReportId,defendReportId)
    dfhack.run_script('fortbent/teleport_dest','-unit',attackerId)
    eraseReport(df.unit.find(attackerId),df.report.find(attackReportId))
end

attackStrFuncs['uses heal I']=function(attackVerb,defendVerb,attackerId,defenderId,attackReportId,defendReportId)
    dfhack.run_script('classes/add-experience','-unit',attackerId,'-amount',1)
end

attackStrFuncs['use heal I']=attackStrFuncs['uses heal I']

attackStrFuncs['uses heal II']=attackStrFuncs['uses heal I']

attackStrFuncs['use heal II']=attackStrFuncs['uses heal I']

attackStrFuncs['uses heal III']=attackStrFuncs['uses heal I']

attackStrFuncs['use heal III']=attackStrFuncs['uses heal I']

local defendStrFuncs={}

defendStrFuncs['heal']=function(attackVerb,defendVerb,attackerId,defenderId,attackReportId,defendReportId)
    dfhack.run_script('full-heal','-unit',defenderId)
end

defendStrFuncs['heals']=defendStrFuncs['heal']

defendStrFuncs['teleports']=function(attackVerb,defendVerb,attackerId,defenderId,attackReportId,defendReportId)
    dfhack.run_script('fortbent/teleport_dest','-unit',defenderId)
end

defendStrFuncs['die']=function(attackVerb,defendVerb,attackerId,defenderId,attackReportId,defendReportId)
    dfhack.run_script('fortbent/lord_english_laser',defenderId,'yes')
end

defendStrFuncs['dies']=defendStrFuncs['die']

defendStrFuncs['newlife']=function(attackVerb,defendVerb,attackerId,defenderId,attackReportId,defendReportId)
    dfhack.run_script('fortbent/auto_life','-unit',defenderId)
    eraseReport(df.unit.find(defenderId),df.report.find(defendReportId))
end

defendStrFuncs['eustress']=function(attackVerb,defendVerb,attackerId,defenderId,attackReportId,defendReportId)
    dfhack.run_script('fortbent/stress-change','-unit',defenderId,'-adjust','-amount',-30)
    eraseReport(df.unit.find(defenderId),df.report.find(defendReportId))
end

defendStrFuncs['distress']=function(attackVerb,defendVerb,attackerId,defenderId,attackReportId,defendReportId)
    dfhack.run_script('fortbent/stress-change','-unit',defenderId,'-adjust','-amount',500)
    eraseReport(df.unit.find(defenderId),df.report.find(defendReportId))
end

defendStrFuncs['distress_2']=function(attackVerb,defendVerb,attackerId,defenderId,attackReportId,defendReportId)
    dfhack.run_script('fortbent/stress-change','-unit',defenderId,'-adjust','-amount',500000)
    eraseReport(df.unit.find(defenderId),df.report.find(defendReportId))
end

defendStrFuncs['uninsane']=function(attackVerb,defendVerb,attackerId,defenderId,attackReportId,defendReportId)
    dfhack.run_script('fortbent/uninsane','-unit',defenderId)
    eraseReport(df.unit.find(defenderId),df.report.find(defendReportId))
end

defendStrFuncs['superdie']=function(attackVerb,defendVerb,attackerId,defenderId,attackReportId,defendReportId)
    dfhack.run_script('fortbent/lord_english_laser',defenderId)
    eraseReport(df.unit.find(defenderId),df.report.find(defendReportId))
end

defendStrFuncs['deskill']=function(attackVerb,defendVerb,attackerId,defenderId,attackReportId,defendReportId)
    dfhack.run_script('fortbent/witch_of_heart_deskill',defenderId)
    eraseReport(df.unit.find(defenderId),df.report.find(defendReportId))
end

defendStrFuncs['deattribute']=function(attackVerb,defendVerb,attackerId,defenderId,attackReportId,defendReportId)
    dfhack.run_script('fortbent/witch_of_heart_deattribute',defenderId)
    eraseReport(df.unit.find(defenderId),df.report.find(defendReportId))
end

defendStrFuncs['bloodloss']=function(attackVerb,defendVerb,attackerId,defenderId,attackReportId,defendReportId)
    dfhack.run_script('fortbent/remove_blood','-unit',defenderId,'-amount',2)
    eraseReport(df.unit.find(defenderId),df.report.find(defendReportId))
end

defendStrFuncs['doomstave']=function(attackVerb,defendVerb,attackerId,defenderId,attackReportId,defendReportId)
    dfhack.run_script('fortbent/stave_doom','-unit',defenderId)
    eraseReport(df.unit.find(defenderId),df.report.find(defendReportId))
end

defendStrFuncs['LECheck']=function(attackVerb,defendVerb,attackerId,defenderId,attackReportId,defendReportId)
    dfhack.run_script('fortbent/lord_english_check','-unit',attackerId)
    eraseReport(df.unit.find(defenderId),df.report.find(defendReportId))
end

defendStrFuncs['ageup']=function(attackVerb,defendVerb,attackerId,defenderId,attackReportId,defendReportId)
    dfhack.run_script('fortbent/age_change','-unit',defenderId,'-kill')
    eraseReport(df.unit.find(defenderId),df.report.find(defendReportId))
end

defendStrFuncs['agedown']=function(attackVerb,defendVerb,attackerId,defenderId,attackReportId,defendReportId)
    dfhack.run_script('fortbent/age_change','-unit',defenderId)
    eraseReport(df.unit.find(defenderId),df.report.find(defendReportId))
end

defendStrFuncs['insane']=function(attackVerb,defendVerb,attackerId,defenderId,attackReportId,defendReportId)
    dfhack.run_script('fortbent/cause_insanity','-unit',defenderId)
    eraseReport(df.unit.find(defenderId),df.report.find(defendReportId))
end

local bothStrFuncs={}

local function getClaspect(unit)
    for k,c_syn in ipairs(unit.syndromes.active) do
        local raw_syn=df.syndrome.find(c_syn.type)
        for kk,syn_class in ipairs(raw_syn.syn_class) do
            if syn_class.value=='IS_SBURBED' then
                local claspect=raw_syn.syn_name
                local of_numbers={claspect:find('_OF_')}
                local className=claspect:sub(0,of_numbers[1]-1)
                local aspectName=claspect:sub(of_numbers[2]+1,-1)
                return {class=className,aspect=aspectName}
            end
        end
	end
    return nil
end

local fraymotifs=dfhack.script_environment('fortbent/fraymotif')

bothStrFuncs['uses a fraymotif/gets hit by a fraymotif']=function(attackVerb, defendVerb, attackerId, defenderId, attackReportId, defendReportId)
    eraseReport(df.unit.find(attackerId),df.report.find(attackReportId))
    eraseReport(df.unit.find(defenderId),df.report.find(defendReportId))
    local fraymotiferInfo={}
    fraymotiferInfo.tertiary={}
    local attacker=df.unit.find(attackerId)
    local wrapper=dfhack.script_environment('functions/wrapper')
    local targetList,numFound=wrapper.checkLocation(attacker,{5,5,5})
    local allies,num_civ=wrapper.checkTarget(attacker,targetList,'civ')
    fraymotiferInfo.primary=attacker
    for k,v in ipairs(allies) do
        if fraymotiferInfo.secondary then
            fraymotiferInfo.secondary=v
        else
            table.insert(fraymotiferInfo.tertiary,v)
        end
    end
    if not fraymotiferInfo then return false end
    --[[
    First fraymotif artist (the key in the persist, the attacker here) determines the affect (i.e shape) of the fraymotif.
    Second fraymotif artist (ints[0]) determines the effect of the fraymotif.
    Third-eighth fraymotif artists (ints[1]-ints[6]) add modifiers. Algorithm for that should be fairly self-explanatory.
    ]]
    local fraymotifInfo={}
    local primaryClaspect=getClaspect(fraymotiferInfo.primary)
    local secondaryClaspect=getClaspect(fraymotiferInfo.secondary)
    local tertiaryClaspects={}
    for k,v in ipairs(fraymotiferInfo.tertiary) do
        table.insert(tertiaryClaspects,getClaspect(v))
    end
    local fraymotifAffect=fraymotifs.fraymotifAffects[primaryClaspect.aspect][primaryClaspect.class]
    local fraymotifEffect=fraymotifs.fraymotifEffects[secondaryClaspect.aspect][secondaryClaspect.class]
    local fraymotifString=''
    local fraymotifStringUnfinished=true
    if type(fraymotifs.fraymotifNames[primaryClaspect.aspect][primaryClaspect.class][secondaryClaspect.aspect][secondaryClaspect.class])=='string' then --oh my god
        fraymotifStringFinished=false
        fraymotifString=fraymotifs.fraymotifNames[primaryClaspect.aspect][primaryClaspect.class][secondaryClaspect.aspect][secondaryClaspect.class] --oh. oh wow.
    end
    if fraymotifStringUnfinished then 
        fraymotifString=fraymotifs.fraymotifNames[primaryClaspect.aspect][primaryClaspect.class]..fraymotifs.fraymotifNames[secondaryClaspect.aspect][secondaryClaspect.class]
    end
    local fraymotifModifiers={}
    if fraymotifStringUnfinished then 
        for k,v in ipairs(tertiaryClaspects) do
            local adjectiveToUse=(k%6)+1
            table.insert(fraymotifModifiers,fraymotifs.fraymotifModifiers[v.aspect][v.class][adjectiveToUse])
            fraymotifString=fraymotifs.fraymotifAdjectives[v.aspect][v.class]..' '..fraymotifString
        end
    else
        for k,v in ipairs(tertiaryClaspects) do
            table.insert(fraymotifModifiers,fraymotifs.fraymotifModifiers[v.aspect][v.class])
        end
    end
    fraymotifAffect(fraymotiferInfo.primary,df.unit.find(defenderId),fraymotifEffect,fraymotifModifiers)
    local reportNum=dfhack.gui.makeAnnouncement(df.announcement_type.INTERACTION_ACTOR,copyall(fraymotiferInfo.primary.pos),'Fraymotif! ' .. fraymotifString..'!',COLOR_LIGHTBLUE)
    dfhack.gui.addCombatReport(fraymotiferInfo.primary,0,reportNum)
    dfhack.gui.addCombatReport(fraymotiferInfo.secondary,0,reportNum)
    for k,v in ipairs(fraymotiferInfo.tertiary) do
        dfhack.gui.addCombatReport(v,0,reportNum)
    end
end


eventful.onInteraction.fortbent_stuff=function(attackVerb, defendVerb, attackerId, defenderId, attackReportId, defendReportId)
    local attackStr=attackVerb or ''
    local defendStr=defendVerb or ''
    local attackFunc=attackStrFuncs[attackStr]
    if attackFunc then attackFunc(attackVerb,defendVerb,attackerId,defenderId,attackReportId,defendReportId) end
    local defendFunc=defendStrFuncs[defendStr]
    if defendFunc then defendFunc(attackVerb,defendVerb,attackerId,defenderId,attackReportId,defendReportId) end
    local bothFunc=bothStrFuncs[attackStr..'/'..defendStr]
    if bothFunc then bothFunc(attackVerb,defendVerb,attackerId,defenderId,attackReportId,defendReportId) end
end

local stateEvents={}

stateEvents[SC_MAP_LOADED]=function() eventful.enableEvent(eventful.eventType.INTERACTION,5) end

stateEvents[SC_WORLD_LOADED]=stateEvents[SC_MAP_LOADED]

function onStateChange(op)
    local stateChangeFunc=stateEvents[op]
    if stateChangeFunc then stateChangeFunc() end
end