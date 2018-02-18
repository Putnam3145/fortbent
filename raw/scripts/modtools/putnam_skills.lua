--@ module = true

skills={}

skillWorldIDs={}

local magicIdentifier=3145

local function unitHasSoul(unit)
    return (unit.status and unit.status.current_soul)
end

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
            skillWorldIDs[skill.name]=formForSkill.id
            df.global.musical_form_next_id=df.global.musical_form_next_id+1
        end
    end
end

function getSkillName(fakeSkill)
    local musicalForm=df.musical_form.find(fakeSkill.id)
    return musicalForm.name.unknown==magicIdentifier and musicalForm.name.first_name
end

function addSkills(tbl)
    for k,v in pairs(tbl) do
        skills[v.name]=v
    end
    insertSkillsIntoWorld()
end

function assignSkillToUnit(unit,skill)
    if not unitHasSoul(unit) then return false end
    if not unit.status.current_soul.performance_skills then
        unit.status.current_soul.performance_skills=df.unit_soul.T_performance_skills:new()
    end
    local skillAssignMusicalSkill=df.unit_musical_skill:new()
    local properSkill=skills[skill]
    skillAssignMusicalSkill.id=skillWorldIDs[skill]
    unit.status.current_soul.performance_skills.musical_forms:insert('#',skillAssignMusicalSkill)
end

function getSkillFromUnit(unit,skill)
    if not unitHasSoul(unit) or not unit.status.current_soul.performance_skills then return false end
    for k,v in ipairs(unit.status.current_soul.performance_skills.musical_forms) do
        if df.musical_form.find(v.id).name.first_name==skill then return v end
    end
    return false --not found
end

function getSkillsFromUnit(unit)
    local returnTable={}
    if not unitHasSoul(unit) or not unit.status.current_soul.performance_skills then return false end
    for k,v in ipairs(unit.status.current_soul.performance_skills.musical_forms) do
        if df.musical_form.find(v.id).name.unknown==magicIdentifier then table.insert(returnTable,v) end
    end
    return #returnTable>0 and returnTable or false
end

local function addSyndromesToUnit(syndromes,unit)
    for k,syndrome in ipairs(syndromes) do
        dfhack.run_script('modtools/add-syndrome','-target',unit.id,'-syndrome',syndrome,'-resetPolicy','DoNothing')
    end
end

local function addAttributesToUnit(attributes,unit)
    for k,v in ipairs(attributes) do
        if df.physical_attribute_type[v.name] then
            local unitPhysicalAttr=unit.body.physical_attrs[v.name]
            unitPhysicalAttr.value=math.max(0,unitPhysicalAttr.value+v.bonus)
            unitPhysicalAttr.max_value=math.max(0,unitPhysicalAttr.max_value+(v.bonus*2))
        elseif df.mental_attribute_type[v.name] then
            local unitMentalAttr=unit.status.current_soul.mental_attrs[v.name]
            unitMentalAttr.value=math.max(0,unitMentalAttr.value+v.bonus)
            unitMentalAttr.max_value=math.max(0,unitMentalAttr.max_value+(v.bonus*2))        
        else
            print('Unrecognized attribute! '..v.name)
        end
    end
end

local function addRealSkillsToUnit(realSkills,unit)
    for k,skill in ipairs(realSkills) do
        dfhack.run_script('modtools/skill-change','-unit',unit.id,'-value',skill.bonus,'-mode','add','-granularity','experience','-skill',skill.name)
    end
end

local function levelSkill(unit,skill,level) --local because all leveling should go through the much more proper channel of addExperienceToSkill
    if skill.levelfuncs and skill.levelfuncs[level] then 
        skill.levelfuncs[level](unit)
    end
    if skill.syndromes and skill.syndromes[level] then 
        addSyndromesToUnit(skill.syndromes[level],unit)
    end
    if skill.attributes and skill.attributes[level] then
        addAttributesToUnit(skill.attributes[level],unit)        
    end
    if skill.skills and skill.skills[level] then
        addRealSkillsToUnit(skill.skills[level],unit)
    end
end

function addExperienceToSkill(unit,skill,amount)
    --will add experience to unit and level up if it reaches a level up threshold defined in the data files
    --return false on failure, true on success
    local unitSkill=getSkillFromUnit(unit,skill)
    if not unitSkill then return false end --skills should only be explicitly added
    amount=math.floor(amount+0.5)
    unitSkill.experience=unitSkill.experience+amount
    local putnamSkill=skills[skill]
    local levelThreshold=putnamSkill.levelUpThresholds[unitSkill.rating+1] or 1/0 --[[IEEE 754 standard, so this is positive infinity, which, fun fact, lua counts as more than any integer.
      Like any clever hack, this is actually quite stupid, but I was feeling lazy.]]
    while unitSkill.experience>levelThreshold do
        unitSkill.experience=unitSkill.experience-levelThreshold
        levelSkill(unit,putnamSkill,unitSkill.rating+1)
        unitSkill.rating=unitSkill.rating+1
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
    if not unitHasSoul(unit) or not unit.status.current_soul.performance_skills then return false end --not actually a problem, anything with a skill will have those
    for k,v in ipairs(unit.status.current_soul.performance_skills.musical_forms) do
        local musicalForm=df.musical_form.find(v.id)
        if musicalForm.name.unknown==magicIdentifier and canGainExperienceWithCriterion(skills[musicalForm.name.first_name],criterion) then
            addExperienceToSkill(unit,musicalForm.name.first_name,amount)
        end
    end
end

function getAllUnitsWithSkillContainingString(str)
    local units={}
    for k,unit in ipairs(df.global.world.units.active) do
        for kk,musicSkill in ipairs(getSkillsFromUnit(unit)) do 
            if getSkillName(musicSkill):find(str) then table.insert(units,{unit=unit,skill=musicSkill.rating}) end
        end
    end
    return units
end