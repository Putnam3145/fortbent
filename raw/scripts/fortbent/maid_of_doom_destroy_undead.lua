local function destroyUndead(unit)
	if not unit.status.current_soul then
		unit.animal.vanish_countdown = 2
	end
end

destroyUndead(df.unit.find(...))
