local function stealLife(unit)
	unit.body.blood_max = unit.body.blood_max-1000
	unit.body.blood_count = unit.body.blood_count-1000
end

stealLife(df.unit.find(...))
