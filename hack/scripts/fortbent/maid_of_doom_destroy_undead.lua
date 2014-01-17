local function destroyUndead(unit)
	if not unit.status.current_soul then
		unit.animal.vanish_countdown = 2
	end
end

local function takeArg(arg) --shove it into the unit kill function, of course. What else could it mean. Seriously.
	local unit = df.global.world.units.all[arg]
	destroyUndead(unit)
end

takeArg(tonumber(...))