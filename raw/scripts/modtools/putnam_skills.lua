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
    unit.status.current_soul.perfomance_skills.musical_forms:insert('#',skillAssignMusicalSkill)
    --yes, perfomance, not my typo
end

function getSkillFromUnit(unit,skill)
    for k,v in ipairs(unit.status.current_soul.perfomance_skills.musical_forms) do
        if df.musical_form.find(v.id).name.first_name==skill.name then return v end
    end
    return false --not found
end

local function levelSkill(unit,skill,level) --local because all leveling should go through the much more proper channel of addExperienceToSkill
    if type(skill)=='table' then
        skill.levelfuncs[level](unit)
    elseif type(skill)=='userdata' and skill._type==df.unit_musical_skill then
        skills[df.musical_form.find(skill.id).name.first_name].levelfuncs[level](unit)
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
    local levelThreshold=skill.levelUpThresholds[unitSkill.rating]
    if unitSkill.experience>levelThreshold then
        unitSkill.experience=unitSkill.experience-levelThreshold
        levelSkill(unit,skill,unitSkill.rating+1)
        addExperienceToSkill(unit,unitSkill,0) -- makes sure that, should the unit get enough experience to level multiple times, the unit will go through each level individually
    end
    return true
end

function addExperienceToAllSkillsWithLevelCriterion(unit,amount,criterion)
    for k,v in ipairs(unit.status.current_soul.perfomance_skills.musical_forms) do
        local musicalForm=df.musical_form.find(v.id)
        if musicalForm.name.unknown==magicIdentifier and canGainExperienceWithCriterion(skills[musicalForm.name],criterion) then
            addExperienceToSkill(unit,v,amount)
        end
    end
end
