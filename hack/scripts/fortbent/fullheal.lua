--heal unit from all wounds and damage 

--warmist https://gist.github.com/warmist/8594614
function healunit(unit)
    if unit==nil then
		unit=dfhack.gui.getSelectedUnit()
	end
 
	if unit==nil then
		error("Failed to Heal unit. Unit not selected/valid")
	end
    for i=#unit.body.wounds-1,0,-1 do
    	unit.body.wounds[i]:delete()
    end
    unit.body.wounds:resize(0) 
	unit.body.blood_count=unit.body.blood_max
	--set flags for standing and grasping...
	unit.status2.limbs_stand_max=4
	unit.status2.limbs_stand_count=4
	unit.status2.limbs_grasp_max=4
	unit.status2.limbs_grasp_count=4
	--should also set temperatures, and flags for breath etc...
	unit.flags1.dead=false
	unit.flags2.calculated_bodyparts=false
	unit.flags2.calculated_nerves=false
	unit.flags2.circulatory_spray=false
	unit.flags2.vision_good=true
	unit.flags2.vision_damaged=false
	unit.flags2.vision_missing=false
	unit.counters.winded=0
	unit.counters.unconscious=0
	for k,v in pairs(unit.body.components) do
		for kk,vv in pairs(v) do
			if k == 'body_part_status' or k=='layer_status' then v[kk].whole = 0  else v[kk] = 0 end
		end
	end
end
healunit(df.unit.find(...))
