prongleThoughts={}

local function getHighestTraitFromList(unit,list)
    local highest=""
    local topNum=0
    for k,v in ipairs(list) do
        local trait=unit.status.current_soul.personality.traits[v]
        if trait>topNum then 
            highest=k
            topNum=trait
        end
    end
    return highest
end

local function getValue(unit,value)
    for k,v in ipairs(unit.status.current_soul.personality.values) do
        if df.value_type[v.type]==value then return v.strength end
    end
    if unit.civ_id>-1 then
        local entity=df.historical_entity.find(unit.civ_id)
        return entity.resources.values[value]+entity.resources.values_2[value]
    else
        return nil
    end
end

local function getPronoun(unit)
    if unit.status.current_soul then
        if unit.status.current_soul.sex==0 then
            return {'she','her','her','hers'}
        elseif unit.status.current_soul.sex==1 then
            return {'he','him','his','his'}
        else
            return {'they','them','their','theirs'}
        end
    else
        return {'it','it','its','its'}
    end
end

local function getSwearinessLevel(unit,personalityTrait,invertTrait,accountForThoughtlessness,accountForStress)
    local decorum=50-getValue(unit,'DECORUM')
    if not personalityTrait then
        personalityTrait='POLITENESS'
        invertTrait=true
        accountForThoughtlessness=true
        accountForStress=true
    end
    local swearyTrait=unit.status.current_soul.personality.traits[personalityTrait]
    if invertTrait then swearyTrait=100-swearyTrait end
    if personalityTrait=='POLITENESS' then
        local thoughtlessness=unit.status.current_soul.personality.traits.THOUGHTLESSNESS
        if thoughtlessness>75 then
            return swearyTrait
        elseif accountForThoughtlessness then
            thoughtlessnessLevel=math.floor(((100-thoughtlessness)/25)+0.5)
        end
        local stressLevel=accountForStress and math.log(unit.status.current_soul.personality.stress_level) or 1
        if not stressLevel>0 then stressLevel=1 end --"not n>0" instead of "n<=0" because math.log of a number less than 0 is indeterminate, which always returns false to comparisons.
        stressLevel=math.max(1,math.floor(stressLevel+0.5))
        return ((swearyTrait*stressLevel)+(decorum*thoughtlessnessLevel)/(stressLevel+thoughtlessnessLevel))
    elseif accountForThoughtlessness then
        local thoughtlessness=unit.status.current_soul.personality.traits.THOUGHTLESSNESS
        if thoughtlessness>75 then
            return swearyTrait
        elseif accountForThoughtlessness then
            thoughtlessnessLevel=math.floor(((100-thoughtlessness)/25)+0.5)
        end
        local stressLevel=accountForStress and math.log(unit.status.current_soul.personality.stress_level) or 1
        if not stressLevel>0 then stressLevel=1 end --"not n>0" instead of "n<=0" because math.log of a number less than 0 is indeterminate, which always returns false to comparisons.
        stressLevel=math.max(1,math.floor(stressLevel+0.5))
        return getSwearinessLevel(unit,'POLITENESS',true,true,true)+(((swearyTrait*stressLevel)+(decorum*thoughtlessnessLevel))/(stressLevel+thoughtlessnessLevel))/2
    else
        local stressLevel=accountForStress and math.log(unit.status.current_soul.personality.stress_level) or 1
        if not stressLevel>0 then stressLevel=1 end --"not n>0" instead of "n<=0" because math.log of a number less than 0 is indeterminate, which always returns false to comparisons.
        stressLevel=math.max(1,math.floor(stressLevel+0.5))
        return (getSwearinessLevel(unit,'POLITENESS',true,true,true)+(swearyTrait*stressLevel)+(decorum)/(1+stressLevel))/2
    end
end

local conflicts={
    values={
        ROMANCE={{'LOVE_PROPENSITY',1}},
        MERRIMENT={{'CHEER_PROPENSITY',1}},
        SELF_CONTROL={{'IMMODERATION',-1}},
        TRANQUILITY={{'VIOLENT',-1},{'EXCITEMENT_SEEKING',-1}},
        MARTIAL_PROWESS={{'VIOLENT',1}},
        PERSEVERENCE={{'PERSEVERENCE',1}},
        HARMONY={{'DISCORD',-1},{'FRIENDLINESS',1}},
        FRIENDSHIP={{'FRIENDLINESS',1}},
        DECORUM={{'POLITENESS',1}},
        POWER={{'CRUELTY',1}},
        STOICISM={{'PRIVACY',1}},
        ALTRUISM={{'SACRIFICE',1}},
        LAW={{'DUTIFULNESS',1}},
        LOYALTY={{'DUTIFULNESS',1}},
        INDEPENDENCE={{'DUTIFULNESS',-1}},
        ARTWORK={{'ART_INCLINED',-1},{'NATURE',-1}}
        },
    traits={
        LOVE_PROPENSITY={{'ROMANCE',1}},
        CHEER_PROPENSITY={{'MERRIMENT',1}},
        IMMODERATION={{'SELF_CONTROL',-1}},
        VIOLENT={{'TRANQUILITY',-1},{'MARTIAL_PROWESS',1}}
        EXCITEMENT_SEEKING={{'TRANQUILITY',-1}},
        PERSEVERENCE={{'PERSEVERENCE',1}}, --wow
        DISCORD={{'HARMONY',-1}}
        FRIENDLINESS={{'FRIENDSHIP',1},{'HARMONY',1}}
        POLITENESS={{'DECORUM',1}},
        CRUELTY={{'POWER',1}},
        PRIVACY={{'STOICISM',1}},
        SACRIFICE={{'ALTRUISM',1}},
        DUTIFULNESS={{'LAW',1},{'LOYALTY',1},{'INDEPENDENCE',-1}}
        ART_INCLINED={'ARTWORK',-1}
        NATURE={{'ARTWORK',-1}}
        }
}

local function getConflictingPersonalityTrait(unit,personalityTrait)
    local disputedTrait=unit.status.current_soul.personality.traits[personalityTrait]
    local thoughtlessness=unit.status.current_soul.personality.traits.THOUGHTLESSNESS
    if thoughtlessness>75 then
        return disputedTrait
    end
    thoughtlessnessLevel=math.floor(((100-thoughtlessness)/25)+0.5)
    local stressLevel=math.log(unit.status.current_soul.personality.stress_level)
    if not stressLevel>0 then stressLevel=1 end
    stressLevel=math.max(1,math.floor(stressLevel+0.5))
    local conflict=conflicts.traits[personalityTrait]
    local conflictLevel=0
    for k,v in ipairs(conflict) do
        if v[2]==1 then
            conflictLevel=conflictLevel+getValue(unit,v[1])
        else
            conflictLevel=conflictLevel+(100-getValue(unit,v[1]))
        end
    end
    return math.floor((((disputedTrait*stressLevel)+(conflictLevel*thoughtlessnessLevel))/(stressLevel+thoughtlessnessLevel+#conflict-1))+0.5)
end

local function getVaguenessLevel(unit,relatedToPerson)
    local personality=unit.status.current_soul.personality.traits
    if relatedToPerson
        return ((100-getConflictingPersonalityTrait(unit,'DISCORD'))+getConflictingPersonalityTrait(unit,'FRIENDLINESS')+(100-personality.ASSERTIVENESS))/3
    else
        return (getConflictingPersonalityTrait(unit,'PRIVACY')+(100-personality.CONFIDENCE)+(100-personality.ASSERTIVENESS))/3
    end
end

local function getDictionType(unit)
    local personality=unit.status.current_soul.personality.traits
    local mentalAttributes=unit.status.current_soul.mental_attrs
    local eloquence=getValue(unit,'ELOQUENCE')
    if eloquence>90 then
        if mentalAttributes.LINGUISTIC_ABILITY.value<750 and personality.pride>75 then
            return 'verysmart'
        end
        --NO.
    elseif
    --THIS
    else
    --IS.
    end
    --STUPID.
    --I'm not finishing this for a while, screw this, what's there already is just fine.
end

local function getIntensifier(unit,personalityTrait,invertTrait,relatedToPerson)
    local sweariness=getSwearinessLevel(unit)
    local dictionType=getDictionType(unit)
end

local function getPejorative(unit,personalityTrait,invertTrait,relatedToPerson)
    
end

local function capitalizeFirstLetterOfString(str)
    return str:sub(1,1):upper()..str:sub(2,-1)
end

prongleThoughts.Rain['DEFAULT']=function(unit,emotion)
    return 'It rained on me. I feel such ' .. df.emotion_type[emotion.type]:lower() .. '!'
end

prongleThoughts.Rain['GROUCHINESS']=function(unit,emotion)
    local sweariness=getSwearinessLevel(unit,'ANGER_PROPENSITY',false,false,true)
    local vagueness=getVaguenessLevel(unit,false)
    if vagueness>85 then
        local pejorative = sweariness > 60 and 'shitty' or 'bad'
        return 'Ugh. Pretty ' ..pejorative .. ' day so far.'
    else
        local intensifier = sweariness > 70 and 'fucking' or 'really'
        return "Rain is " .. intensifier .. " awful and I hate it."
    end
end

for k,v in pairs(prongleThoughts) do
    for kk,vv in ipairs(df.emotion_type) do
        if vv then
            v[vv]=v[vv] or v['DEFAULT']
        end
    end
end

function getStringForThought(unit,emotion)
    local str='I felt ' .. df.emotion_type[emotion.type] .. ' at ' .. df.unit_thought_type[emotion.thought] .. ' today.'
    local thoughtFuncTable=prongleThoughts[df.unit_thought_type[emotion.thought]]
    if thoughtFuncTable then
        local thoughtFunc=thoughtFuncTable[df.emotion_type[emotion.type]]
        if thoughtFunc then str=thoughtFunc(unit,emotion) end
    else
        
    end
    return str
end