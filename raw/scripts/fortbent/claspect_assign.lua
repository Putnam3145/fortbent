-- Assigns claspects based on personality, attributes etc.

local putnamSkills=dfhack.script_environment('modtools/putnam_skills')

local aspects=dfhack.script_environment('fortbent/claspects').aspects

local classes=dfhack.script_environment('fortbent/claspects').classes

syndromeUtil=require('syndrome-util')

rng=dfhack.random.new()

function assignClaspect(unit,aspect,class)
    putnamSkills.assignSkillToUnit(unit,class..' of '..aspect)
    if unit.hist_figure_id then
        local hist_figure=df.historical_figure.find(unit.hist_figure_id)
        if hist_figure and hist_figure.info and hist_figure.info.kills then
            for k,v in pairs(hist_figure.info.kills.killed_count) do
                local caste=df.creature_raw.find(hist_figure_info.kills.killed_race[k]).caste[hist_figure_info.kills.killed_caste[k]]
                local bodySizeInfo=caste.body_size_1
                local bodySize=bodySizeInfo[#bodySizeInfo-1]/500
                local strength=caste.attributes.phys_att_range.STRENGTH[3]/1000
                local agility=caste.attributes.phys_att_range.AGILITY[3]/1000
                local toughness=caste.attributes.phys_att_range.TOUGHNESS[3]/1000
                local endurance=caste.attributes.phys_att_range.ENDURANCE[3]/1000
                local willpower=caste.attributes.ment_att_range.WILLPOWER[3]/1500
                local spatial_sense=caste.attributes.ment_att_range.SPATIAL_SENSE[3]/1000
                local kinesthetic_sense=caste.attributes.ment_att_range.KINESTHETIC_SENSE[3]/1000
                local focus=caste.attributes.ment_att_range.FOCUS[3]/2000
                putnamSkills.addExperienceToAllSkillsWithLevelCriterion(unit,v*(bodySize+strength+agility+toughness+endurance+willpower+spatial_sense+kinesthetic_sense+focus),'sburb')
            end
        end
    end
    return unit,class..' of '..aspect
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
	return not creatureIsSburbable(unit) or putnamSkills.getSkillsFromUnit(unit)
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
    local male_exclusive=unit.sex==0 and 0.5 or 1
    local female_exclusive=unit.sex==1 and 0.5 or 1
    class_pers.Heir=passive+round(traits.PERSEVERENCE/2)+male_lean --Equius demands things insistently and John follows instructions even when he thinks they're dumb.
    class_pers.Seer=passive+round(traits.CURIOUS/2)+female_lean
    class_pers.Knight=active+round(traits.BRAVERY/2)+male_lean --Based more on the archetype of knight than the knights we've seen (Latula, Karkat, Dave)
    class_pers.Witch=(active+round(traits.CHEER_PROPENSITY/2)+20)*female_exclusive --Damara was a happy girl before Meenah broke her, Jade and Feferi need no introduction.
    class_pers.Maid=(active+round(traits.GREGARIOUSNESS/2)+20)*female_exclusive --yeah this one's a bit of a stretch but whatever
    class_pers.Page=passive+math.abs(50-traits.CONFIDENCE)+male_lean --50-trait means that it'll weigh it both if they're confident and underconfident.
    class_pers.Prince=(active+math.abs(50-traits.VIOLENT)+20)*male_exclusive --destroy, violent, meh
    class_pers.Rogue=passive+round(traits.FRIENDLINESS/2)+female_lean --rufioh, nepeta, roxy; yeah, friendliness is a constant there
    class_pers.Thief=active+round(traits.GREED/2)+female_lean
    class_pers.Sylph=passive+round(traits.ALTRUISM/2)+female_lean
    class_pers.Bard=(passive+round(traits.CRUELTY/2)+20)*male_exclusive --okay that might be a bit inappropriate, but you gotta work with what you have...
    class_pers.Mage=active+round(traits.ABSTRACT_INCLINED/2)+male_lean
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
	local creatureAspect = rng:random(12)+1
    local aspect=aspects[creatureAspect]
    local class=getClass(unit)
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

require('repeat-util').scheduleUnlessAlreadyScheduled('Claspect Assignment',100,'ticks',assignAllClaspects)