-- Nothing for now. Ignore.

--[[
    Prongle is basically troll twitter, as shows in Hiveswap.
    These are some functions I wrote for dialogue in the Caledfwlch event script that I ended up scrapping because it's much easier to abstract than do writing in-character.
    However, in-character writing is a damn good idea for something that will actually show up to people on the regular. I might implement Prongle proper at some point with this in mind.
]]

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

local function capitalizeFirstLetterOfString(str)
    return str:sub(1,1):upper()..str:sub(2,-1)
end

local function getSwearinessLevel(unit)
    local decorum=50-getValue(unit,'DECORUM')
    local politeness=100-unit.status.current_soul.personality.traits.POLITENESS
    local thoughtlessness=unit.status.current_soul.personality.traits.THOUGHTLESSNESS
    if thoughtlessness>75 then 
        return politeness
    else
        thoughtlessness=math.floor(((100-thoughtlessness)/25)+0.5)
    end
    local stressLevel=math.log(unit.status.current_soul.personality.stress_level)
    if not stressLevel>0 then stressLevel=1 end
    stressLevel=math.max(1,math.floor(stressLevel+0.5))
    return ((politeness*stressLevel)+(decorum*thoughtlessnessLevel)/(stressLevel+thoughtlessnessLevel))
end
