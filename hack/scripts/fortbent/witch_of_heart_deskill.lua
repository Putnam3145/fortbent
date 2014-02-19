local function deskill(unit)
    for _,skill in ipairs(unit.status.current_soul.skills) do
		skill.rating = skill.rating - 1
		skill.experience = 0
	end
end

deskill(df.unit.find(...))
