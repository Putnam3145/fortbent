local function deskill(unit)
    local rng=dfhack.random.new()
    for _,skill in ipairs(unit.status.current_soul.skills) do
        if rng:random(2)<1 then
            skill.rating = skill.rating - 1
            skill.experience = 0
        end
	end
end

deskill(df.unit.find(...))
