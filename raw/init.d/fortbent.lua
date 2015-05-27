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

repeat_util.scheduleUnlessAlreadyScheduled('Clockwork Majyyks',math.ceil(df.global.enabler.gfps/15),'frames',clockwork_majyyks_color_change)

repeat_util.scheduleUnlessAlreadyScheduled('Psiioniic Blast',5,'ticks',mind_blast_color_change)

function onUnload()
    repeat_util.cancel('Clockwork Majyyks')
    repeat_util.cancel('Psiioniic Blast')
end

dfhack.run_command('script',SAVE_PATH..'/raw/fortbent_onload.txt')

if not pcall(function() require('plugins.dfusion.friendship') end) then
    print("Friendship couldn't be installed! God tiers will be wonkier than usual.") 
else
    friendship=require('plugins.dfusion.friendship').Friendship

    friendship:install({'TROLL_ALTERNIA','TROLL_ALTERNIA','TROLL_BEFORUS','HUMAN','HUMAN_HERO_OF_BREATH','HUMAN_HERO_OF_LIGHT','HUMAN_HERO_OF_TIME','HUMAN_HERO_OF_SPACE','HUMAN_HERO_OF_LIFE','HUMAN_HERO_OF_HOPE','HUMAN_HERO_OF_VOID','HUMAN_HERO_OF_HEART','HUMAN_HERO_OF_BLOOD','HUMAN_HERO_OF_MIND','HUMAN_HERO_OF_RAGE','HUMAN_HERO_OF_DOOM','TROLL_HERO_OF_BREATH','TROLL_HERO_OF_LIGHT','TROLL_HERO_OF_TIME','TROLL_HERO_OF_SPACE','TROLL_HERO_OF_LIFE','TROLL_HERO_OF_HOPE','TROLL_HERO_OF_VOID','TROLL_HERO_OF_HEART','TROLL_HERO_OF_BLOOD','TROLL_HERO_OF_MIND','TROLL_HERO_OF_RAGE','TROLL_HERO_OF_DOOM'})
end

local eraseReport = function(unit,report)
 for i,v in ipairs(unit.reports.log.Combat) do
  if v == report then
   unit.reports.log.Combat:erase(i)
   break
  end
 end
end

local eventful=require('plugins.eventful')

local attackStrFuncs={}

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

defendStrFuncs['hopefill']=function(attackVerb,defendVerb,attackerId,defenderId,attackReportId,defendReportId)
    dfhack.run_script('add-thought','-unit',defenderId,'-emotion','Hope','-thought','Talked','-strength',25,'-severity',100,'-subthought',4)
    eraseReport(df.unit.find(defenderId),df.report.find(defendReportId))
end

defendStrFuncs['hopeless_I']=function(attackVerb,defendVerb,attackerId,defenderId,attackReportId,defendReportId)
    dfhack.run_script('add-thought','-unit',defenderId,'-emotion','Hopelessness','-thought','Attacked','-strength',25,'-severity',100)
    eraseReport(df.unit.find(defenderId),df.report.find(defendReportId))
end

defendStrFuncs['hopeless_II']=function(attackVerb,defendVerb,attackerId,defenderId,attackReportId,defendReportId)
    dfhack.run_script('add-thought','-unit',defenderId,'-emotion','Hopelessness','-thought','Attacked','-strength',100,'-severity',500)
    eraseReport(df.unit.find(defenderId),df.report.find(defendReportId))
end

defendStrFuncs['hopeless_III']=function(attackVerb,defendVerb,attackerId,defenderId,attackReportId,defendReportId)
    dfhack.run_script('add-thought','-unit',defenderId,'-emotion','Hopelessness','-thought','Attacked','-strength',100,'-severity',1000)
    eraseReport(df.unit.find(defenderId),df.report.find(defendReportId))
end

defendStrFuncs['hopeless_IV']=function(attackVerb,defendVerb,attackerId,defenderId,attackReportId,defendReportId)
    dfhack.run_script('add-thought','-unit',defenderId,'-emotion','Hopelessness','-thought','Attacked','-strength',100,'-severity',10000)
    eraseReport(df.unit.find(defenderId),df.report.find(defendReportId))
end

defendStrFuncs['enjoy']=function(attackVerb,defendVerb,attackerId,defenderId,attackReportId,defendReportId)
    dfhack.run_script('add-thought','-unit',defenderId,'-emotion','Joy','-thought','Talked','-strength',25,'-severity',50,'-subthought',4)
    eraseReport(df.unit.find(defenderId),df.report.find(defendReportId))
end

defendStrFuncs['enjoy2']=function(attackVerb,defendVerb,attackerId,defenderId,attackReportId,defendReportId)
    dfhack.run_script('add-thought','-unit',defenderId,'-emotion','Joy','-thought','Talked','-strength',25,'-severity',1000,'-subthought',4)
    eraseReport(df.unit.find(defenderId),df.report.find(defendReportId))
end

defendStrFuncs['caring']=function(attackVerb,defendVerb,attackerId,defenderId,attackReportId,defendReportId)
    dfhack.run_script('add-thought','-unit',defenderId,'-emotion','Caring','-thought','Talked','-strength',25,'-severity',100,'-subthought',4)
    eraseReport(df.unit.find(defenderId),df.report.find(defendReportId))
end

defendStrFuncs['caring2']=function(attackVerb,defendVerb,attackerId,defenderId,attackReportId,defendReportId)
    dfhack.run_script('add-thought','-unit',defenderId,'-emotion','Caring','-thought','Talked','-strength',25,'-severity',2000,'-subthought',4)
    eraseReport(df.unit.find(defenderId),df.report.find(defendReportId))
end

defendStrFuncs['bliss']=function(attackVerb,defendVerb,attackerId,defenderId,attackReportId,defendReportId)
    dfhack.run_script('add-thought','-unit',defenderId,'-emotion','Bliss','-thought','Talked','-strength',25,'-severity',50,'-subthought',4)
    eraseReport(df.unit.find(defenderId),df.report.find(defendReportId))
end

defendStrFuncs['agony']=function(attackVerb,defendVerb,attackerId,defenderId,attackReportId,defendReportId)
    dfhack.run_script('add-thought','-unit',defenderId,'-emotion','Agony','-thought','Attacked','-strength',25,'-severity',500,'-subthought',4)
    eraseReport(df.unit.find(defenderId),df.report.find(defendReportId))
end

defendStrFuncs['agony2']=function(attackVerb,defendVerb,attackerId,defenderId,attackReportId,defendReportId)
    dfhack.run_script('add-thought','-unit',defenderId,'-emotion','Agony','-thought','Attacked','-strength',25,'-severity',10000)
    eraseReport(df.unit.find(defenderId),df.report.find(defendReportId))
end

defendStrFuncs['hatred']=function(attackVerb,defendVerb,attackerId,defenderId,attackReportId,defendReportId)
    dfhack.run_script('add-thought','-unit',defenderId,'-emotion','Hatred','-thought','Attacked','-strength',25,'-severity',1000)
    eraseReport(df.unit.find(defenderId),df.report.find(defendReportId))
end

defendStrFuncs['hatred2']=function(attackVerb,defendVerb,attackerId,defenderId,attackReportId,defendReportId)
    dfhack.run_script('add-thought','-unit',defenderId,'-emotion','Hatred','-thought','Attacked','-strength',25,'-severity',20000)
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

--local bothStrFuncs={}

eventful.onInteraction.fortbent_stuff=function(attackVerb, defendVerb, attackerId, defenderId, attackReportId, defendReportId)
    local attackStr=attackVerb or ''
    local defendStr=defendVerb or ''
    local attackFunc=attackStrFuncs[attackStr]
    if attackFunc then attackFunc(attackVerb,defendVerb,attackerId,defenderId,attackReportId,defendReportId) end
    local defendFunc=defendStrFuncs[defendStr]
    if defendFunc then defendFunc(attackVerb,defendVerb,attackerId,defenderId,attackReportId,defendReportId) end
    --[[local bothFunc=bothStrFuncs[attackStr..'/'..defendStr]
    if bothFunc then bothFunc(attackVerb,defendVerb,attackerId,defenderId,attackReportId,defendReportId) end]]
end

local stateEvents={}

stateEvents[SC_MAP_LOADED]=function() eventful.enableEvent(eventful.eventType.INTERACTION,5) end

stateEvents[SC_WORLD_LOADED]=stateEvents[SC_MAP_LOADED]

function onStateChange(op)
    local stateChangeFunc=stateEvents[op]
    if stateChangeFunc then stateChangeFunc() end
end