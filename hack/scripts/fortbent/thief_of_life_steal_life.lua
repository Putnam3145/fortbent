local function stealLife(unit)
	unit.body.blood_max = unit.body.blood_max-1000
	unit.body.blood_count = unit.body.blood_count-1000
end

local function takeArg(arg)
	local unit = df.global.world.units.all[arg]
	stealLife(unit)
end

takeArg(tonumber(...))