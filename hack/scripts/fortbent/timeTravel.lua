--create unit at pointer or given location. Usage e.g. "spawnunit DWARF 0 Dwarfy"

--Made by warmist, but edited by Putnam for the dragon ball mod to be used in reactions

--note that it's extensible to any autosyndrome reaction to spawn anything due to this; to use in autosyndrome, you want \COMMAND spawnunit CREATURE caste_number name \LOCATION
--[[
args={...}
function getCaste(race_id,caste_id)
    local cr=df.creature_raw.find(race_id)
    return cr.caste[caste_id]
end
function genBodyModifier(body_app_mod)
    local a=math.random(0,#body_app_mod.ranges-2)
    return math.random(body_app_mod.ranges[a],body_app_mod.ranges[a+1])
end
function getBodySize(caste,time)
    --todo real body size...
    return caste.body_size_1[#caste.body_size_1-1] --returns last body size
end
function genAttribute(array)
    local a=math.random(0,#array-2)
    return math.random(array[a],array[a+1])
end
function norm()
    return math.sqrt((-2)*math.log(math.random()))*math.cos(2*math.pi*math.random())
end
function normalDistributed(mean,sigma)
    return mean+sigma*norm()
end
function clampedNormal(min,median,max)
    local val=normalDistributed(median,math.sqrt(max-min))
    if val<min then return min end
    if val>max then return max end
    return val
end
function makeSoul(unit,caste,cloneunit)
    local tmp_soul=df.unit_soul:new()
    tmp_soul.unit_id=unit.id
    tmp_soul.name:assign(unit.name)
    tmp_soul.race=unit.race
    tmp_soul.sex=unit.sex
    tmp_soul.caste=unit.caste
    --todo skills,preferences,traits.
    local attrs=caste.attributes
	local cloneattrs=cloneunit.status.current_soul.mental_attrs
    for k,v in pairs(attrs.ment_att_range) do
		local cloneattr=cloneattrs[k]
       tmp_soul.mental_attrs[k]={value=cloneattr.value,max_value=cloneattr.max_value}
    end
	local clonepersonality=cloneunit.status.current_soul.traits
    for k,v in pairs(tmp_soul.traits) do
        tmp_soul.traits[k]=clonepersonality[k]
    end
    unit.status.souls:insert("#",tmp_soul)
    unit.status.current_soul=tmp_soul
end
function CreateUnit(race_id,caste_id,cloneunit)
    local race=df.creature_raw.find(race_id)
    if race==nil then error("Invalid race_id") end
    local caste=getCaste(race_id,caste_id)
    local unit=df.unit:new()
    unit.race=race_id
    unit.caste=caste_id
    unit.id=df.global.unit_next_id
	df.global.unit_next_id=df.global.unit_next_id+1
	if caste.misc.maxage_max==-1 then
		unit.relations.old_year=-1
	else
		unit.relations.old_year=math.random(caste.misc.maxage_min,caste.misc.maxage_max)
	end
	unit.sex=caste.gender
    local body=unit.body
    
    body.body_plan=caste.body_info
    local body_part_count=#body.body_plan.body_parts
    local layer_count=#body.body_plan.layer_part
    --components
    unit.relations.birth_year=df.global.cur_year
    --unit.relations.birth_time=??
    
    --unit.relations.old_time=?? --TODO add normal age
    local cp=body.components
    cp.body_part_status:resize(body_part_count)
    cp.numbered_masks:resize(#body.body_plan.numbered_masks)
    for num,v in ipairs(body.body_plan.numbered_masks) do
        cp.numbered_masks[num]=v
    end
    
    cp.body_layer_338:resize(layer_count)
    cp.body_layer_348:resize(layer_count)
    cp.body_layer_358:resize(layer_count)
    cp.body_layer_368:resize(layer_count)
    cp.body_layer_378:resize(layer_count)
    local attrs=caste.attributes
    for k,v in pairs(attrs.phys_att_range) do
        local max_percent=attrs.phys_att_cap_perc[k]/100
        local cvalue=genAttribute(v)
        unit.body.physical_attrs[k]={value=cvalue,max_value=cvalue*max_percent}
        --unit.body.physical_attrs:insert(k,{new=true,max_value=genMaxAttribute(v),value=genAttribute(v)})
    end
 
    body.blood_max=getBodySize(caste,0) --TODO normal values
    body.blood_count=body.blood_max
    body.unk_494=0 --infection level
    unit.status2.body_part_temperature:resize(body_part_count)
    for k,v in pairs(unit.status2.body_part_temperature) do
        unit.status2.body_part_temperature[k]={new=true,whole=10067,fraction=0}
        
    end
    --------------------
    local stuff=unit.enemy
    stuff.body_part_878:resize(body_part_count) -- all = 3
    stuff.body_part_888:resize(body_part_count) -- all = 3
    stuff.body_part_relsize:resize(body_part_count) -- all =0
 
    --TODO add correct sizes. (calculate from age)
	local size=caste.body_size_2[#caste.body_size_2-1]
	body.physical_attr_tissues[0]=size
	body.physical_attr_tissues[1]=size
	body.physical_attr_tissues[2]=math.pow(size,0.666)
	body.physical_attr_tissues[3]=math.pow(size,0.666)
    body.physical_attr_tissues[4]=math.pow(size*10000,0.333)
	body.physical_attr_tissues[5]=math.pow(size*10000,0.333)
	
    stuff.were_race=race_id
    stuff.were_caste=caste_id
    stuff.normal_race=race_id
    stuff.normal_caste=caste_id
    stuff.body_part_8a8:resize(body_part_count) -- all = 1
    stuff.body_part_base_ins:resize(body_part_count) 
    stuff.body_part_clothing_ins:resize(body_part_count) 
    stuff.body_part_8d8:resize(body_part_count) 
    unit.recuperation.healing_rate:resize(layer_count) 
    --appearance
   
    local app=unit.appearance
    app:assign(cloneunit.appearance)
    
    makeSoul(unit,caste,cloneunit)
    
    df.global.world.units.all:insert("#",unit)
    df.global.world.units.active:insert("#",unit)
    --todo set weapon bodypart
	
	local num_inter=#caste.body_info.interactions
	unit.curse.anon_5:resize(num_inter)
	unit.curse.anon_6:resize(num_inter)
    return unit
end
function findRace(name)
	for k,v in pairs(df.global.world.raws.creatures.all) do
		if v.creature_id==name then
			return k
		end
	end
	qerror("Race:"..name.." not found!")
end

function getNemesis(unit)
	for k,v in ipairs(unit.general_refs) do
		if df.general_ref_is_nemesisst:is_instance(v) then return v end
	end
end

function PlaceUnit(unit,position,vanish_countdown)
vanish_countdown=vanish_countdown or 0
local pos=(not not position) and (position.x~=-30000) and position or copyall(df.global.cursor) or unit.pos
if pos.x==-30000 then
	qerror("Point your pointy thing somewhere")
end
	race=unit.race
	local u=CreateUnit(race,unit.caste or 0,unit)
	u.pos:assign(pos)
	u.name.first_name=unit.name.first_name
	for k,v in ipairs(u.name.words) do
		v=unit.name.words[k]
	end
	for k,v in ipairs(u.name.parts_of_speech) do
		v=unit.name.parts_of_speech[k]
	end
	u.name.has_name=true
	u.civ_id=unit.civ_id
	u.animal.vanish_countdown = vanish_countdown
 
	local desig,ocupan=dfhack.maps.getTileFlags(pos)
	if ocupan.unit then
		ocupan.unit_grounded=true
		u.flags1.on_ground=true
	else
		ocupan.unit=true
	end
    if getNemesis(unit) then u.general_refs:insert("#",{new=df.general_ref_is_nemesisst,nemesis_id=getNemesis(unit).nemesis_id}) end
end
function createFigure(trgunit)
    local hf=df.historical_figure:new()
    hf.id=df.global.hist_figure_next_id
    hf.race=trgunit.race
    hf.caste=trgunit.caste
    df.global.hist_figure_next_id=df.global.hist_figure_next_id+1
    hf.name.first_name=trgunit.name.first_name
    hf.name.has_name=true
 
 
    df.global.world.history.figures:insert("#",hf)
    return hf
end
function createNemesis(trgunit)
    local id=df.global.nemesis_next_id
    local nem=df.nemesis_record:new()
    nem.id=id
    nem.unit_id=trgunit.id
    nem.unit=trgunit
    nem.flags:resize(1)
    nem.flags[4]=true
    nem.flags[5]=true
    nem.flags[6]=true
    nem.flags[7]=true
    nem.flags[8]=true
    nem.flags[9]=true
    --[[for k=4,8 do
        nem.flags[k]=true
    end]]
    df.global.world.nemesis.all:insert("#",nem)
    df.global.nemesis_next_id=id+1
    trgunit.general_refs:insert("#",{new=df.general_ref_is_nemesisst,nemesis_id=id})
    trgunit.flags1.important_historical_figure=true
    local gen=df.global.world.worldgen
    nem.save_file_id=gen.next_unit_chunk_id;
    gen.next_unit_chunk_id=gen.next_unit_chunk_id+1
    gen.next_unit_chunk_offset=gen.next_unit_chunk_offset+1
    
    --[[ local gen=df.global.world.worldgen
    gen.next_unit_chunk_id
    gen.next_unit_chunk_offset
    ]]
    nem.figure=createFigure(trgunit)
end

local argPos
 
if #args>1 then
	argPos={}
	argPos.x=args[2]
	argPos.y=args[3]
	argPos.z=args[4]
end

local unit = (args[1]) and df.unit:find(tonumber(args[1])) or dfhack.gui.getSelectedUnit() or df.global.world.units.active[0]

PlaceUnit(unit,argPos,args[5]) --Creature (ID), caste (number), name, x,y,z for spawn.

]]

--commented out due to being broken in 0.40 for now