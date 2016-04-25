-- Assigns claspects based on personality, attributes etc.
aspects={
	"BREATH", --1
	"LIGHT",
	"TIME",
	"SPACE",
	"LIFE",
	"HOPE",
	"VOID",
	"HEART",
	"BLOOD",
	"DOOM",
	"MIND",
	"RAGE"}
    
syndromeUtil=require('syndrome-util')

rng=dfhack.random.new()

function assignClaspect(unit,aspect,class)
	return pcall(function() 
        dfhack.run_script('classes/change-class','-unit',unit.id,'-class',class..'_OF_'..aspect)
        if unit.hist_figure_id then
            local hist_figure=df.historical_figure.find(unit.hist_figure_id)
            if hist_figure.info and hist_figure.info.kills then
                for k,v in pairs(hist_figure.info.kills.killed_count) do
                    pcall(function() dfhack.run_script('classes/add-experience','-unit',unit.id,'-amount',v) end)
                end
            end
        end
    end)
end

function unitAlreadyHasClaspect(unit)
    for k,c_syn in ipairs(unit.syndromes.active) do
        for kk,syn_class in ipairs(df.syndrome.find(c_syn.type).syn_class) do
            if syn_class.value=='IS_SBURBED' then return true end
        end
	end
    return false
end

debugScript=false

local sburbableRaces={ --why didn't i think of this sooner??
    HUMAN=true,
    TROLL_ALTERNIA=true,
    DWARF=true,
    ELF=true,
    SAIYAN=true, --adding more is zero risk
    FOUNDATION=true,
    GNOME_CIV=true,
    SUCCUBUS=true --masterwork is the only mod that isn't mine i have around lol
}

function creatureIsSburbable(unit)
    local race_id=df.creature_raw.find(unit.race).creature_id
    return sburbableRaces[race_id]
end

function unitDoesntNeedClaspect(unit)
	return not creatureIsSburbable(unit) or unitAlreadyHasClaspect(unit)
end

function round(num)
    return math.floor(num+.5) 
end

function getClass(unit)
    --it's a silly personality test
    local class_pers={}
    local traits=unit.status.current_soul.personality.traits
    local active=round(traits.ACTIVITY_LEVEL/2)
    local passive=50-active
    local male_lean=unit.sex==0 and 0 or 20
    local female_lean=unit.sex==1 and 20 or 0
    local male_exclusive=unit.sex==0 and 0 or 1
    local female_exclusive=unit.sex==1 and 0 or 1
    class_pers.HEIR=passive+round(traits.PERSEVERENCE/2)+male_lean --Equius demands things insistently and John follows instructions even when he thinks they're dumb.
    class_pers.SEER=passive+round(traits.CURIOUS/2)+female_lean
    class_pers.KNIGHT=active+round(traits.BRAVERY/2)+male_lean --Based more on the archetype of knight than the knights we've seen (Latula, Karkat, Dave)
    class_pers.WITCH=(active+round(traits.CHEER_PROPENSITY/2)+20)*female_exclusive --Damara was a happy girl before Meenah broke her, Jade and Feferi need no introduction.
    class_pers.MAID=(active+round(traits.GREGARIOUSNESS/2)+20)*female_exclusive --yeah this one's a bit of a stretch but whatever
    class_pers.PAGE=passive+math.abs(50-traits.CONFIDENCE)+male_lean --50-trait means that it'll weigh it both if they're confident and underconfident.
    class_pers.PRINCE=(active+math.abs(50-traits.VIOLENT)+20)*male_exclusive --destroy, violent, meh
    class_pers.ROGUE=passive+round(traits.FRIENDLINESS/2)+female_lean --rufioh, nepeta, roxy; yeah, friendliness is a constant there
    class_pers.THIEF=active+round(traits.GREED/2)+female_lean
    class_pers.SYLPH=passive+round(traits.ALTRUISM/2)+female_lean
    class_pers.BARD=(passive+round(traits.CRUELTY/2)+20)*male_exclusive --okay that might be a bit inappropriate, but you gotta work with what you have...
    class_pers.MAGE=active+round(traits.ABSTRACT_INCLINED/2)+male_lean
    --wow look at that I actually managed 6 active and 6 passive classes
    local total_weight=0
    for k,v in pairs(class_pers) do
        total_weight=total_weight+v
    end
    local balance=100/total_weight
    for k,v in pairs(class_pers) do
        v=round(v*balance)
    end
    local raffle={}
    for k,v in pairs(class_pers) do
        for i=(#raffle+1),(#raffle+1+v) do
            raffle[i]=k
        end
    end
    return raffle[rng:random(#raffle)+1]
end

function makeClaspect(unit,unitidx)
	local creatureAspect = rng:random(13)+1
    local aspect=aspects[creatureAspect]
    local class=getClass(unit)
    aspect=type(aspect)=='string' and aspect or type(aspect)=='table' and aspect.text or 'LIGHT' --light default
	local worked,err=assignClaspect(unit,aspect,class)
    if worked then
		return creatureAspect
	end
    print(err)
	return false
end

local pauseCounter=8

dfhack.onStateChange.claspect = function(code)
    if code==SC_WORLD_LOADED then
        assignAllClaspects()
    end
	if code==SC_PAUSED then
		pauseCounter=pauseCounter+1
		if pauseCounter>=10 then
			assignAllClaspects()
			pauseCounter=0
		end
	end
end

function assignAllClaspects()
	for k,unit in ipairs(df.global.world.units.active) do
		if not(unitDoesntNeedClaspect(unit)) then 
			makeClaspect(unit,k) 
		end
	end
end

require('repeat-util').scheduleUnlessAlreadyScheduled('Claspect Assignment',28,'days',assignAllClaspects)