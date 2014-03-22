local function killUnit(unit)
	unit.body.blood_count = 0
	unit.animal.vanish_countdown = 2 --Even if they're undead, the fool can still double-kill.
end

killUnit(df.unit.find(...))
