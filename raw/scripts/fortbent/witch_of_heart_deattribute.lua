local function deattribute(unit)
    local rng=dfhack.random.new()
    for _,attribute in ipairs(unit.status.current_soul.mental_attrs) do
		attribute.value = math.ceil(attribute.value*((rng:drandom1()+1)/2))
	end
end

deattribute(df.unit.find(...))
