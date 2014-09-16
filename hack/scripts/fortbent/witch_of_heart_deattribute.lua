local function deattribute(unit)
    for _,attribute in ipairs(unit.status.current_soul.mental_attrs) do
		attribute.value = attribute.value/2
	end
end

deattribute(df.unit.find(...))
