local function killUnit(unit)
	unit.body.blood_count = 0
	unit.animal.vanish_countdown = 2 --Even if they're undead, the bastard can still double-kill.
end

local function takeArgAndShoveIt(arg) --shove it into the unit kill function, of course. What else could it mean. Seriously.
	local unit = df.global.world.units.active[arg]
	killUnit(unit)
end

if ... then takeArgAndShoveIt(tonumber(...)) end