local function getUnitSyndrome(syndrome)
    return df.syndrome.find(syndrome.type)
end

local function unitIsThiefOfLife(unit)
    for _,u_syndrome in ipairs(unit.syndromes) do
        local syndrome = getUnitSyndrome(u_syndrome)
        for _,symptom in ipairs(syndrome.ce) do
            if string.find(symptom.name,"thief of life") then return true end
        end
    end
    return false
end

local function giveLife(unit)
	if unitIsThiefOfLife(unit) then
		unit.body.blood_max = unit.body.blood_max+1000
		unit.body.blood_count = unit.body.blood_count+1000
	end
end

local function takeArg(arg) --shove it into the unit kill function, of course. What else could it mean. Seriously.
	local unit = df.global.world.units.all[arg]
	giveLife(unit)
end

giveLife(df.unit.find(...))
