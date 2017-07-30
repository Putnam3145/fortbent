--@ module = true

local skills={}

local skillWorldIDs={}

local magicIdentifier=3145

local function insertSkillsIntoWorld()
    local skillAlreadyInWorld={}
    for k,v in ipairs(df.global.world.musical_forms.all) do
        if v.name.unknown==magicIdentifier then
            local skillName=v.name.first_name
            skillAlreadyInWorld[skillName]=true
            skillWorldIDs[skillName]=v.id
        end
    end
    for k,skill in pairs(skills) do
        if not skillAlreadyInWorld[skill.name] then
            local formForSkill=df.musical_form:new()
            formForSkill.id=df.global.musical_form_next_id
            formForSkill.name.has_name=true
            formForSkill.name.first_name=skill.name
            formForSkill.name.unknown=magicIdentifier
            df.global.world.musical_forms.all:insert('#',formForSkill)
            skillWorldIDs[skillName]=formForSkill.id
            df.global.musical_form_next_id=df.global.musical_form_next_id+1
        end
    end
end

function addSkills(tbl)
    for k,v in ipairs(tbl) do
        table.insert(skills,v)
    end
    insertSkillsIntoWorld()
end

function assignSkillToUnit(unit,skill)
    local skillAssignMusicalSkill=df.unit_musical_skill:new()
    skillAssignMusicalSkill.id=skillWorldIDs[skill.name]
    unit.status.current_soul.performance_skills.musical_forms:insert('#',skillAssignMusicalSkill)
end

function getSkillFromUnit(unit,skill)
    for k,v in ipairs(unit.status.current_soul.performance_skills.musical_forms) do
        if df.musical_form.find(v.id).name.first_name==skill.name then return v end
    end
    return false --not found
end

local function addSyndromesToUnit(syndromes,unit)
    for k,syndrome in ipairs(syndromes) do
        dfhack.run_script('modtools/add-syndrome','-target',unit.id,'-syndrome',syndrome,'-resetPolicy','-DoNothing')
    end
end

local function addAttributesToUnit(attributes,unit)
    for k,v in ipairs(attributes) do
        if df.physical_attribute_type[v.name] then
            local unitPhysicalAttr=unit.body.physical_attrs[v.name]
            math.max(0,unitPhysicalAttr.value=unitPhysicalAttr.value+v.bonus)
            math.max(0,unitPhysicalAttr.max_value=unitPhysicalAttr.max_value+(v.bonus*2))
        elseif df.mental_attribute_type[v.name] then
            local unitMentalAttr=unit.status.current_soul.mental_attrs[v.name]
            math.max(0,unitMentalAttr.value=unitMentalAttr.value+v.bonus)
            math.max(0,unitMentalAttr.max_value=unitMentalAttr.max_value+(v.bonus*2))        
        else
            print('Unrecognized attribute! '..v.name)
        end
    end
end

local function addRealSkillsToUnit(skills,unit)
    for k,skill in ipairs(skills) do
        dfhack.run_script('modtools/skill-change','-unit',unit.id,'-value',skill.bonus,'-mode','add','-granularity','experience','-skill',skill.name)
    end
end

local function levelSkill(unit,skill,level) --local because all leveling should go through the much more proper channel of addExperienceToSkill
    if type(skill)=='table' then
        skill.levelfuncs[level](unit)
        addSyndromesToUnit(skill.syndromes[level],unit)
        addAttributesToUnit(skill.attributes[level],unit)
        addRealSkillsToUnit(properSkill.skills[level],unit)
    elseif type(skill)=='userdata' and skill._type==df.unit_musical_skill then
        local properSkill=skills[df.musical_form.find(skill.id).name.first_name]
        properSkill.levelfuncs[level](unit)
        addSyndromesToUnit(properSkill.syndromes[level],unit)
        addAttributesToUnit(properSkill.attributes[level],unit)
        addRealSkillsToUnit(properSkill.skills[level],unit)
    end
end

function addExperienceToSkill(unit,skill,amount)
    --will add experience to unit and level up if it reaches a level up threshold defined in the data files
    --return false on failure, true on success
    local unitSkill
    if type(skill)=='table' then
        unitSkill=getSkillFromUnit(unit,skill)
    elseif type(skill)=='userdata' and skill._type==df.unit_musical_skill then
        unitSkill=skill
    end
    if not unitSkill then return false end --skills should only be explicitly added
    unitSkill.experience=unitSkill.experience+amount
    local levelThreshold=skill.levelUpThresholds[unitSkill.rating+1] or 1/0 --[[IEEE 754 standard, so this is positive infinity, which, fun fact, lua counts as more than any integer.
      Like any clever hack, this is actually quite stupid, but I was feeling lazy.]]
    if unitSkill.experience>levelThreshold then
        unitSkill.experience=unitSkill.experience-levelThreshold
        levelSkill(unit,skill,unitSkill.rating+1)
        addExperienceToSkill(unit,unitSkill,0) -- makes sure that, should the unit get enough experience to level multiple times, the unit will go through each level individually
    end
    return true
end

local function canGainExperienceWithCriterion(skill,criterion)
    for k,v in pairs(skill.experienceCriteria) do
        if v==criterion then return true end
    end
    return false
end

function addExperienceToAllSkillsWithLevelCriterion(unit,amount,criterion)
    for k,v in ipairs(unit.status.current_soul.performance_skills.musical_forms) do
        local musicalForm=df.musical_form.find(v.id)
        if musicalForm.name.unknown==magicIdentifier and canGainExperienceWithCriterion(skills[musicalForm.name],criterion) then
            addExperienceToSkill(unit,v,amount)
        end
    end
end
