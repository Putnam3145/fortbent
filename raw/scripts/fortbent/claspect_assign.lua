-- Assigns claspects based on personality, attributes etc.

local putnamSkills=dfhack.script_environment('modtools/putnam_skills')

dfhack.run_script('fortbent/classes')

local claspect_helpers=dfhack.script_environment('fortbent/claspects')

local aspects=claspect_helpers.aspects

local classes=claspect_helpers.classes

syndromeUtil=require('syndrome-util')

rng=dfhack.random.new()

local aspectCounts=claspect_helpers.make_new_aspect_table()

function assignClaspect(unit,aspect,class)
    putnamSkills.assignSkillToUnit(unit,class..' of '..aspect)
    if unit.hist_figure_id then
        local hist_figure=df.historical_figure.find(unit.hist_figure_id)
        if hist_figure and hist_figure.info and hist_figure.info.kills then
            for k,v in pairs(hist_figure.info.kills.killed_count) do
                local caste=df.creature_raw.find(hist_figure.info.kills.killed_race[k]).caste[hist_figure.info.kills.killed_caste[k]]
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
    aspectCounts[aspect]=aspectCounts[aspect]+1
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

function getUnitClaspect(unit)
    local unitSkills=putnamSkills.getSkillsFromUnit(unit)
    if not unitSkills then return false end
    for k,v in ipairs(unitSkills) do
        local skillString=putnamSkills.getSkillName(v)
        local aspectInString=claspect_helpers.getAspectInString(skillString)
        if aspectInString then
            return {class=claspect_helpers.getClassInString(skillString),aspect=aspectInString}
        end
    end
    return false --unit has no claspect
end

function unitDoesntNeedClaspect(unit)
	return not creatureIsSburbable(unit) or getUnitClaspect(unit)
end

function round(num)
    return math.floor(num+.5) 
end

function unitHasSoul(unit)
    return unit.status and unit.status.current_soul
end

function getLunarSway(unit)
    if not unitHasSoul(unit) then return 0 end
    local traits=unit.status.current_soul.personality.traits
    local lunar_sway=0
    lunar_sway=lunar_sway+(traits.CHEER_PROPENSITY-50)
    lunar_sway=lunar_sway-(traits.ANXIETY_PROPENSITY-50)
    lunar_sway=lunar_sway-(traits.DISDAIN_ADVICE-50)
    lunar_sway=lunar_sway+(traits.IMMODERATION-50)
    lunar_sway=lunar_sway-(traits.PRIVACY-50)
    return lunar_sway>0 and 0 or 1 --0 is prospit, 1 is derse
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
    class_pers.Heir=passive+round(traits.DUTIFULNESS/2)+male_lean
    class_pers.Seer=passive+round(50-traits.DEPRESSION_PROPENSITY)+female_lean
    class_pers.Knight=active+round(traits.CONFIDENCE/2)+male_lean
    class_pers.Witch=(active+round(traits.IMAGINATION/2)+20)*female_exclusive
    class_pers.Maid=(active+round(traits.DUTIFULNESS/2)+20)*female_exclusive
    class_pers.Page=passive+math.abs(50-traits.CONFIDENCE)+male_lean --50-trait means that it'll weigh it both if they're confident and underconfident.
    class_pers.Prince=(active+math.abs(50-traits.VIOLENT)+20)*male_exclusive
    class_pers.Rogue=passive+round(traits.GREED/2)+female_lean
    class_pers.Thief=active+round(traits.GREED/2)+female_lean
    class_pers.Sylph=passive+round(traits.IMAGINATION/2)+female_lean
    class_pers.Bard=(passive+round(traits.VIOLENT/2)+20)*male_exclusive
    class_pers.Mage=active+round(50-traits.DEPRESSION_PROPENSITY)+male_lean
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

local function boost_aspect(aspect_table,aspect,extreme_lean)
    local adjacent_aspects=claspect_helpers.get_adjacent_aspects(aspect)
    local opposite_aspect=claspect_helpers.get_opposite_aspect(aspect)
    local opposite_adjacent_aspects=claspect_helpers.get_adjacent_aspects(opposite_aspect)
    aspect_table[aspect]=aspect_table[aspect]+(extreme_lean and 6 or 4)
    aspect_table[opposite_aspect]=aspect_table[opposite_aspect]+2
    for k,adjacent_aspect in ipairs(adjacent_aspects) do
        aspect_table[adjacent_aspect]=aspect_table[adjacent_aspect]+(extreme_lean and 3 or 2)
    end
    for k,opposite_adjacent_aspect in ipairs(opposite_adjacent_aspects) do
        aspect_table[opposite_adjacent_aspect]=aspect_table[opposite_adjacent_aspect]+1
    end
end

local function drain_aspect(aspect_table,aspect)
    local adjacent_aspects=claspect_helpers.get_adjacent_aspects(aspect)
    local opposite_aspect=claspect_helpers.get_opposite_aspect(aspect)
    local opposite_adjacent_aspects=claspect_helpers.get_adjacent_aspects(opposite_aspect)
    local non_adjacent_aspects=claspect_helpers.get_non_adjacent_aspects(aspect)
    aspect_table[aspect]=aspect_table[aspect]-3
    aspect_table[opposite_aspect]=aspect_table[opposite_aspect]-3
    for k,adjacent_aspect in ipairs(adjacent_aspects) do
        aspect_table[adjacent_aspect]=aspect_table[adjacent_aspect]-1
    end
    for k,opposite_adjacent_aspect in ipairs(opposite_adjacent_aspects) do
        aspect_table[opposite_adjacent_aspect]=aspect_table[opposite_adjacent_aspect]-1
    end
    for k,non_adjacent_aspect in ipairs(non_adjacent_aspects) do
        aspect_table[non_adjacent_aspect]=aspect_table[non_adjacent_aspect]+3
    end
end

local function boost_aspect_pair_by_personality_trait(aspect,trait,aspect_table)
    local opposite_aspect=claspect_helpers.get_opposite_aspect(aspect)
    if trait>80 then
        boost_aspect(aspect_table,aspect,true)
    elseif trait>60 then
        boost_aspect(aspect_table,aspect,false)
    elseif trait<40 then
        boost_aspect(aspect_table,opposite_aspect,false)
    elseif trait<20 then
        boost_aspect(aspect_table,opposite_aspect,true)
    else
        drain_aspect(aspect_table,aspect)
    end
end

aspectCounts.initialized=false

function getAspectPerc()
    if not aspectCounts.initialized then
        for k,unit in ipairs(df.global.world.units.active) do
            local claspect=getUnitClaspect(unit)
            if claspect then
                aspectCounts[claspect.aspect]=aspectCounts[claspect.aspect]+1
            end
        end
        aspectCounts.initialized=true
    end
    local percentageTable={}
    local total=0
    for k,v in pairs(aspectCounts) do
        if k~='initialized' then
            total=total+v
        end
    end
    if total==0 then return aspectCounts end
    for k,v in pairs(aspectCounts) do
        if k~='initialized' then
            percentageTable[k]=aspectCounts[k]/total
        end
    end
    return percentageTable
end

local function get_first_aspect_that_isnt_too_common(aspect_quiz_results,aspect_percentages)
    for k,v in ipairs(aspect_quiz_results) do
        if aspect_percentages[v.name]<(k/48)+(1/16) then --k/48+1/16 == ((k+3)/4)/12
            return v.name
        end
    end
end

function getAspect(unit)
    --[[i'm basically using the personality test but in dwarf fortress terms so here's the deal in this post
    http://katanahime.tumblr.com/post/168061341354/complete-explanation-for-extended-zodiac-aspect
    ]]
    local traits=unit.status.current_soul.personality.traits
    local aspect_tbl=claspect_helpers.make_new_aspect_table()
    boost_aspect_pair_by_personality_trait('Blood',traits.GREGARIOUSNESS,aspect_tbl)
    boost_aspect_pair_by_personality_trait('Blood',traits.SWAYED_BY_EMOTIONS,aspect_tbl)
    boost_aspect_pair_by_personality_trait('Light',traits.CURIOUS,aspect_tbl)
    boost_aspect_pair_by_personality_trait('Light',traits.ASSERTIVENESS,aspect_tbl)
    boost_aspect_pair_by_personality_trait('Space',traits.ABSTRACT_INCLINED,aspect_tbl)
    boost_aspect_pair_by_personality_trait('Time',traits.PERFECTIONIST,aspect_tbl)
    boost_aspect_pair_by_personality_trait('Heart',traits.VANITY,aspect_tbl)
    boost_aspect_pair_by_personality_trait('Heart',traits.THOUGHTLESSNESS,aspect_tbl)
    boost_aspect_pair_by_personality_trait('Hope',traits.HOPEFUL,aspect_tbl) -- :mspa:
    boost_aspect_pair_by_personality_trait('Hope',traits.PERSEVERENCE,aspect_tbl)
    boost_aspect_pair_by_personality_trait('Life',traits.ALTRUISM,aspect_tbl)
    boost_aspect_pair_by_personality_trait('Doom',traits.EMOTIONALLY_OBSESSIVE,aspect_tbl)
    local sortTable={}
    for k,v in pairs(aspect_tbl) do
        table.insert(sortTable,{name=k,value=v})
    end
    table.sort(sortTable,function(a,b) return a.value>b.value end)
    return get_first_aspect_that_isnt_too_common(sortTable,getAspectPerc())
end

local function constructListForScript(tbl)
    local returnTbl={}
    for k,v in pairs(tbl) do
        table.insert(returnTbl,{v,nil,{}})
    end
    return returnTbl
end

function makeClaspect(unit,unitidx)
    local ok,class,aspect
    local script=require('gui.script')
    script.start(function()
        if df.global.gametype==df.game_type.ADVENTURE_MAIN and unit==df.global.world.units.active[0] then
            ok,class=script.showListPrompt('Titles','Pick your class.',COLOR_WHITE,constructListForScript(classes))
            ok,aspect=script.showListPrompt('Titles','Pick your aspect.',COLOR_WHITE,constructListForScript(aspects))
            class=classes[class]
            aspect=aspects[aspect]
        else
            aspect=getAspect(unit)
            class=getClass(unit)
        end
        return assignClaspect(unit,aspect,class)
    end)
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

if ...=='-force' then
    assignAllClaspects()
end