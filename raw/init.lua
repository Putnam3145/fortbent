local function clockwork_majyyks_color_change() script.start(function()
    local iteration_speed=math.ceil(df.global.enabler.gfps/20)
    local colors={COLOR_LIGHTRED,COLOR_YELLOW,COLOR_BLUE,COLOR_GREEN,COLOR_MAGENTA,COLOR_BROWN}
    local clockwork_majyyks=dfhack.matinfo.find('CLOCKWORK_MAJYYKS').material
    local clockwork_cur_color_idx=0
    clockwork_majyyks.build_color[2]=0
    clockwork_majyyks.tile_color[2]=0
    while loaded do --frames timer has to be manually canceled when world is unloaded
        script.sleep(iteration_speed,'frames')
        clockwork_cur_color_idx=(clockwork_cur_color_idx%6)+1
        local clockwork_cur_color_f=colors[clockwork_cur_color_idx]
        local clockwork_cur_color_b=colors[(clockwork_cur_color_idx%6)+1]
        clockwork_majyyks.basic_color[0]=clockwork_cur_color_f
        clockwork_majyyks.basic_color[1]=clockwork_cur_color_b
        clockwork_majyyks.build_color[0]=clockwork_cur_color_f
        clockwork_majyyks.build_color[1]=clockwork_cur_color_b
        clockwork_majyyks.tile_color[0]=clockwork_cur_color_f
        clockwork_majyyks.tile_color[1]=clockwork_cur_color_b
    end
end) end

loaded=true

clockwork_majyyks_color_change()

function onUnload()
    loaded=false
end

if not pcall(function() require('plugins.dfusion.friendship') end) then qerror("Friendship couldn't be installed! God tiers will be wonkier than usual.") end

friendship=require('plugins.dfusion.friendship').Friendship

friendship:install({'TROLL_ALTERNIA','TROLL_ALTERNIA','HUMAN','TROLL_BANDIT','HUMAN_BANDIT','HUMAN_HERO_OF_BREATH','HUMAN_HERO_OF_LIGHT','HUMAN_HERO_OF_TIME','HUMAN_HERO_OF_SPACE','HUMAN_HERO_OF_LIFE','HUMAN_HERO_OF_HOPE','HUMAN_HERO_OF_VOID','HUMAN_HERO_OF_HEART','HUMAN_HERO_OF_BLOOD','HUMAN_HERO_OF_MIND','HUMAN_HERO_OF_RAGE','HUMAN_HERO_OF_DOOM','TROLL_HERO_OF_BREATH','TROLL_HERO_OF_LIGHT','TROLL_HERO_OF_TIME','TROLL_HERO_OF_SPACE','TROLL_HERO_OF_LIFE','TROLL_HERO_OF_HOPE','TROLL_HERO_OF_VOID','TROLL_HERO_OF_HEART','TROLL_HERO_OF_BLOOD','TROLL_HERO_OF_MIND','TROLL_HERO_OF_RAGE','TROLL_HERO_OF_DOOM'})

local script=require('gui.script')

local eventful=require('plugins.eventful')